//
//  KZPhotoManager.h
//  工具类
//
//  Created by MR.Huang on 16/1/18.
//  Copyright © 2016年 MR.Huang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface KZPhotoManager : NSObject
{
    UIImagePickerController *pickerController;
    void (^saveImageCallBack)(UIImage *image);
    void (^saveVideoURLCallBack)(NSURL *videoURL);
    void (^(saveVideoDataCallBack))(NSData * videoData);
    void (^(saveVideoFirstImageCallBack))(UIImage *videoFirstImage);
    
}


+ (void)getImage:(void (^)(UIImage *image))img showIn:(UIViewController *)controller AndActionTitle:(NSString *)title;

+ (void)getVideo:(void (^)(NSURL * videoURL))vURL withData:(void (^)(NSData * videoData)) vData withFirstImage:(void (^)(UIImage *firstimage))fristImage showIn:(UIViewController *) controller AndActionTitle:(NSString *)title;

@end
