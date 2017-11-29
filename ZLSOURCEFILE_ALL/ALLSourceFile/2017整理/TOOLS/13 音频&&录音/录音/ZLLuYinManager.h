//
//  ZLLuYinManager.h
//  UEHTML
//
//  Created by apple on 2017/11/19.
//  Copyright © 2017年 ZL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "JZMp3RecordingClient.h"

@interface ZLLuYinManager : NSObject<AVAudioRecorderDelegate,AVAudioPlayerDelegate>

/** 录音对象*/
@property(nonatomic ,strong) AVAudioRecorder *audioRecorder;
@property (nonatomic, copy) NSString *mp3PathStr;
@property (nonatomic, copy) NSString *zaiXianMp3Url;
@property (nonatomic, strong) NSTimer *timer1;
@property (nonatomic, assign) int countNum;
@property (nonatomic, strong) JZMp3RecordingClient *recordClient;
/** 录音对象*/
@property(nonatomic ,strong) AVAudioRecorder *recorder;
/** 播放对象*/
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
/** 是否是本地音频 */
@property (nonatomic, assign) BOOL isZaiXianMP3;

+ (ZLLuYinManager *)shareInstance;

/** 开始录音 */
- (void)startRecord;
/** 暂停录音 */
- (void)pauseRecord;
/** 结束录音 */
- (void)stopRecord;
/** 播放录音 */
- (void)playAudio;
/** 录音文件大小 MB*/
- (long long)sizeOfRecord;
/** NSData转化为base64字符串 */
- (NSString *)base64FromRecordNSData;
/** base64转化为NSData 未实现*/
- (NSData *)dataFromBase64String;
/** 删除录音文件 */
-(void)deleteOldRecordFile;



@end
