//
//  PrivatyJianCeTool.m
//  ZLTestP
//
//  Created by apple on 2017/11/17.
//  Copyright © 2017年 jtljia.com. All rights reserved.
//

#import "PrivatyJianCeTool.h"

@implementation PrivatyJianCeTool

/** 麦克风检测 */
+ (PrivatyJianCeTool *)shareInstance{
    static PrivatyJianCeTool * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}

/** 麦克风权限检测 */
+ (BOOL)maiKeFengJianCe{
    /** 请求获得麦克风权限 */
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
        NSLog(@"%@",granted ? @"麦克风准许":@"麦克风不准许");
    }];
    /** 检测麦克风权限 IOS8以上 */
    /*
     AVAudioSessionRecordPermissionUndetermined, // 还未决定，说明系统权限请求框还未弹出过
     AVAudioSessionRecordPermissionDenied, // 用户明确拒绝，不再弹出系统权限请求框
     AVAudioSessionRecordPermissionGranted // 用户明确授权
     */
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        AVAudioSession* sharedSession = [AVAudioSession sharedInstance];
        if ([sharedSession respondsToSelector:@selector(recordPermission)]) {
            AVAudioSessionRecordPermission permission = [sharedSession recordPermission];
            switch (permission) {
                case AVAudioSessionRecordPermissionUndetermined:
                    return NO; //NSLog(@"Undetermined");
                    break;
                case AVAudioSessionRecordPermissionDenied:
                    return NO;// NSLog(@"Denied");
                    break;
                case AVAudioSessionRecordPermissionGranted:
                    return YES;// NSLog(@"Granted");//允许
                    break;
                default:
                    break;
            }
        }
    }
    else{
        /** 检测麦克风权限 iOS7以前 */
        //int flag = 0;
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
        switch (authStatus) {
            case AVAuthorizationStatusNotDetermined:
                //没有询问是否开启麦克风
                return NO;//flag = 1;
                break;
            case AVAuthorizationStatusRestricted:
                //未授权，家长限制
                return NO;//flag = 0;
                break;
            case AVAuthorizationStatusDenied:
                //玩家未授权
                return NO;//flag = 0;
                break;
            case AVAuthorizationStatusAuthorized:
                //玩家授权
                return YES;//flag = 2;
                break;
            default:
                break;
        }
    }
    return YES;
}




@end
