//
//  ZLLuYinManager.m
//  UEHTML
//
//  Created by apple on 2017/11/19.
//  Copyright © 2017年 ZL. All rights reserved.
//

#import "ZLLuYinManager.h"

@implementation ZLLuYinManager

+ (ZLLuYinManager *)shareInstance{
    static ZLLuYinManager * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
        
        // 0.1 创建录音文件存放路径
        instance.mp3PathStr = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"auto.mp3"];
//        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//        NSString *mp3 = [path stringByAppendingPathComponent:@"test.mp3"];
        instance.recordClient = [JZMp3RecordingClient sharedClient];
        /*
        NSLog(@"%@", path);
        NSURL *url = [NSURL URLWithString:path];
        // 0.2 创建录音设置
        NSMutableDictionary *recordSettings = [[NSMutableDictionary alloc] init];
        // 设置编码格式
        [recordSettings setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey: AVFormatIDKey];
        // 采样率
        [recordSettings setValue :[NSNumber numberWithFloat:11025.0] forKey: AVSampleRateKey];
        // 通道数
        [recordSettings setValue :[NSNumber numberWithInt:2] forKey: AVNumberOfChannelsKey];
        //音频质量,采样质量
        [recordSettings setValue:[NSNumber numberWithInt:AVAudioQualityMin] forKey:AVEncoderAudioQualityKey];
        // 1. 创建录音对象
        instance.recorder = [[AVAudioRecorder alloc] initWithURL:url settings:recordSettings error:nil];
        // 2. 准备录音(系统会分配一些录音资源)
        [instance.recorder prepareToRecord];
        */
    });
    return instance;
}

- (void)startRecord{
    [self startRecordNotice];
}
- (void)pauseRecord{
    [self.audioRecorder pause];
}
- (void)stopRecord{
    [self stopRecordNotice];
}
/** 开始录音 */
- (void)startRecordNotice{
        [self.recordClient setCurrentMp3File:self.mp3PathStr];
        [self.recordClient start];
}
/** 改变录音时间 */
- (void)changeRecordTime{
    
}
/** 停止录音 */
- (void)stopRecordNotice
{
    NSLog(@"----------结束录音----------");
    [self.recordClient stop];
    //[self.audioRecorder stop];
    //[self.timer1 invalidate];
    
}
/** 播放录音 */
- (void)playAudio{
    if (self.isZaiXianMP3 == YES) {
     /** 在线音频 */
        //创建播放器
        NSURL * url = [NSURL URLWithString:self.zaiXianMp3Url];
        AVPlayer *avPlayer = [[AVPlayer alloc] initWithURL:url];
        [avPlayer play];
    }
    else{
    /** 本地音频 */
        [self.audioPlayer play];
    }
}
/** 录音文件大小*/
- (long long )sizeOfRecord{
    long long size = [self fileSizeAtPath:self.mp3PathStr];
    return size/1024.0/1024.0;
    //NSString *fileSizeStr = [NSString stringWithFormat:@"%lld",fileSize];
}
/** NSData转化为base64字符串 */
- (NSString *)base64FromRecordNSData{
    NSData * mp3Data = [NSData dataWithContentsOfFile:self.mp3PathStr];
    return [self Base64StrWithMp3Data:mp3Data];
}
/** base64转化为NSData */
- (NSData *)dataFromBase64String{
    return nil;
}
/** 删除录音文件 */
-(void)deleteOldRecordFile{
    [self deleteOldRecordFileAtPath:self.mp3PathStr];
}



#pragma mark - 文件转换
// 二进制文件转为base64的字符串
- (NSString *)Base64StrWithMp3Data:(NSData *)data{
    if (!data) {
        NSLog(@"Mp3Data 不能为空");
        return nil;
    }
    //    NSString *str = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    NSString *str = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    return str;
}

// base64的字符串转化为二进制文件
- (NSData *)Mp3DataWithBase64Str:(NSString *)str{
    if (str.length ==0) {
        NSLog(@"Mp3DataWithBase64Str:Base64Str 不能为空");
        return nil;
    }
    NSData *data = [[NSData alloc] initWithBase64EncodedString:str options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSLog(@"Mp3DataWithBase64Str:转换成功");
    return data;
}

- (long long) fileSizeAtPath:(NSString*)filePath{
    
    NSFileManager* manager = [NSFileManager defaultManager];
    
    if ([manager fileExistsAtPath:filePath]){
        
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
        
    }
    
    return 0;
}
/** 删除录音 */
-(void)deleteOldRecordFileAtPath:(NSString *)pathStr{
    NSFileManager* fileManager=[NSFileManager defaultManager];
    
    BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:pathStr];
    if (!blHave) {
        NSLog(@"不存在");
        return ;
    }else {
        NSLog(@"存在");
        BOOL blDele= [fileManager removeItemAtPath:self.mp3PathStr error:nil];
        if (blDele) {
            NSLog(@"删除成功");
        }else {
            NSLog(@"删除失败");
        }
    }
}

#pragma mark ===================本地音乐播放器设置==================
#pragma mark - 播放器
/** audioPlayer 创建(懒加载) */
- (AVAudioPlayer *)audioPlayer
{
    if (!_audioPlayer) {
        //NSURL * url = [NSURL URLWithString:@"http://218.76.27.57:8080/chinaschool_rs02/135275/153903/160861/160867/1370744550357.mp3"];
        //NSString *path = [[NSBundle mainBundle]pathForResource:@"001" ofType:@"mp3"];
        //NSURL *url = [NSURL fileURLWithPath:path];
//        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//        NSString *mp3 = [path stringByAppendingPathComponent:@"auto.mp3"];
        NSURL *url = [NSURL URLWithString:self.mp3PathStr];
        _audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];
        _audioPlayer.delegate = self;
        // 设置播放属性
        _audioPlayer.numberOfLoops = 0; // 不循环
        [_audioPlayer prepareToPlay]; // 准备播放，加载音频文件到缓存
    }
    return _audioPlayer;
}

#pragma mark ===================录音机设置  废弃 开始==================
/**
 *  获得录音机对象
 *
 *  @return 录音机对象
 */
-(AVAudioRecorder *)audioRecorder{
    if (!_audioRecorder) {
        //创建录音文件保存路径
        NSURL *url=[NSURL URLWithString:self.mp3PathStr];
        //创建录音格式设置
        NSDictionary *setting=[self getAudioSetting];
        //创建录音机
        NSError *error=nil;
        
        _audioRecorder=[[AVAudioRecorder alloc]initWithURL:url settings:setting error:&error];
        _audioRecorder.delegate=self;
        _audioRecorder.meteringEnabled=YES;//如果要监控声波则必须设置为YES
        if (error) {
            NSLog(@"创建录音机对象时发生错误，错误信息：%@",error.localizedDescription);
            return nil;
        }
        /** 录音准备资源 */
        [_audioRecorder prepareToRecord];
        
    }
    return _audioRecorder;
}
/**
 *  取得录音文件设置
 *
 *  @return 录音设置
 */
-(NSDictionary *)getAudioSetting{
    //LinearPCM 是iOS的一种无损编码格式,但是体积较为庞大
    //录音设置
    NSMutableDictionary *recordSettings = [[NSMutableDictionary alloc] init];
    //录音格式 无法使用
    [recordSettings setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey: AVFormatIDKey];
    //采样率
    [recordSettings setValue :[NSNumber numberWithFloat:11025.0] forKey: AVSampleRateKey];//44100.0
    //通道数
    [recordSettings setValue :[NSNumber numberWithInt:2] forKey: AVNumberOfChannelsKey];
    //线性采样位数
    //[recordSettings setValue :[NSNumber numberWithInt:16] forKey: AVLinearPCMBitDepthKey];
    //音频质量,采样质量
    [recordSettings setValue:[NSNumber numberWithInt:AVAudioQualityMin] forKey:AVEncoderAudioQualityKey];
    
    return recordSettings;
}

//- (void)beginRecord
//{
//    NSLog(@"开始录音");
//    [self.recorder record]; // 直接录音, 需要手动停止
//    //    [self.recorder recordForDuration:3]; // 从当前执行这行代码开始录音, 录音5秒
//    //    [recorder recordAtTime:recorder.deviceCurrentTime + 2]; // 2s, 需要手动停止
//    //    [self.recorder recordAtTime:self.recorder.deviceCurrentTime + 2 forDuration:3]; // 2s  3s
//}
//
//- (void)pauseRecord {
//    NSLog(@"暂停录音");
//    [self.recorder pause];
//}
//
//- (void)stopRecord {
//    NSLog(@"停止录音");
//    [self.recorder stop];
//}
#pragma mark ===================录音设置 废弃结束==================

@end
