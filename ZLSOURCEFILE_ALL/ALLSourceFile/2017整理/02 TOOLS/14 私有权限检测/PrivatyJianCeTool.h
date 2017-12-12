//
//  PrivatyJianCeTool.h
//  ZLTestP
//
//  Created by apple on 2017/11/17.
//  Copyright © 2017年 jtljia.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface PrivatyJianCeTool : NSObject

/** 单例创建 */
+ (instancetype)shareInstance;
/** 麦克风检测 */
+ (BOOL)maiKeFengJianCe;



@end
