//
//  RITLPhotoConfig.h
//  RITLPhotoDemo
//
//  Created by YueWen on 2016/12/29.
//  Copyright © 2017年 YueWen. All rights reserved.
//

#ifndef RITLPhotoConfig_h
#define RITLPhotoConfig_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

#ifdef __cplusplus
#define RITL_PHOTO_EXTERN extern "C" __attribute__((visibility ("default")))
#else
#define RITL_PHOTO_EXTERN extern __attribute__((visibility ("default")))
#endif




//**************RGB颜色转换（16进制->10进制）**************
#define RITLColorFromRGB(rgbValue)\
\
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 \
alpha:1.0]

#define RITLColorFromIntRBG(RED, GREEN, BLUE) [UIColor colorWithRed:RED/255.0 green:GREEN/255.0 blue:BLUE/255.0 alpha:1.0]


#define RITLPhotoSelectedName (@"RITLSelected")
#define RITLPhotoDeselectedName (@"RITLDeselected")

#define RITLPhotoBrowseBackImage ([UIImage imageNamed:@"RITLPhotoBack"])

#define RITLPhotoSelectedImage ([UIImage imageNamed:RITLPhotoSelectedName])
#define RITLPhotoDeselectedImage ([UIImage imageNamed:RITLPhotoDeselectedName])


#define RITLPhotoIsiPhoneX ([UIScreen mainScreen].bounds.size.height == 812 && [UIScreen mainScreen].bounds.size.width == 375)


//**************** 进行通用回调的block ***************
typedef void(^YPPhotoDidSelectedBlock)(NSArray <UIImage *> *);
typedef void(^YPPhotoDidSelectedBlockAsset)(NSArray <PHAsset *> *,NSArray <NSNumber *> *);


typedef void(^PhotoBlock)(void);
typedef void(^PhotoCompleteBlock0)(id);
typedef void(^PhotoCompleteBlock1)(id,id);
typedef void(^PhotoCompleteBlock2)(id,id,id,NSUInteger);
typedef void(^PhotoCompleteBlock4)(id,id,BOOL);
typedef void(^PhotoCompleteBlock5)(id,id,NSUInteger);
typedef void(^PhotoCompleteBlock6)(BOOL,NSUInteger);
typedef void(^PhotoCompleteBlock7)(id,id,id,id,NSUInteger);
typedef void(^PhotoCompleteBlock8)(BOOL,id);
typedef void(^PhotoCompleteBlock9)(BOOL);




//**************** 将图片大小转换为字符串的C函数
#define RITLPhotoStandard (1024.0)

static inline NSString * ritl_photo_sizeWithLength(NSNumber *length)
{
    //转换成Btye
    NSUInteger btye = length.unsignedIntegerValue;
    
    //如果达到MB
    if (btye > RITLPhotoStandard * RITLPhotoStandard)
    {
        return [NSString stringWithFormat:@"%.1fMB",btye / RITLPhotoStandard / RITLPhotoStandard];
    }
    
    
    else if (btye > RITLPhotoStandard)
    {
        return [NSString stringWithFormat:@"%.0fKB",btye / RITLPhotoStandard];
    }
    
    else
    {
        return [NSString stringWithFormat:@"%@B",@(btye)];
    }
    
    return @"";
}




#endif /* RITLPhotoConfig_h */
