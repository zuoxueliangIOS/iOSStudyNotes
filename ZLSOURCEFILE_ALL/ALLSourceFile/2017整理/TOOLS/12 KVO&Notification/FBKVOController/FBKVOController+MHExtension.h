//
//  FBKVOController+MHExtension.h
//  MHDevelopExample
//
//  Created by senba on 2017/6/16.
//  Copyright © 2017年 CoderMikeHe. All rights reserved.
//  FBKVOController

#import <KVOController/KVOController.h>

@interface FBKVOController (MHExtension)
/**
 *==========ZL注释start===========
 *1.添加观察者,返回Block，调用前@weakify(self);Block中调用@strongify(self);
 *
 *2.
 *3.观察者object
 *4.keyPath
 ===========ZL注释end==========*/
- (void)mh_observe:(nullable id)object keyPath:(NSString *_Nullable)keyPath block:(FBKVONotificationBlock _Nullable )block;
/**
 *==========ZL注释start===========
 *1.添加观察者,返回action
 *
 *2.
 *3.观察者object
 *4.keyPath
 ===========ZL注释end==========*/
- (void)mh_observe:(nullable id)object keyPath:(NSString *_Nullable)keyPath action:(SEL _Nullable )action;

@end
