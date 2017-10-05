//
//  UploadImageZL.m
//  PinGu
//
//  Created by apple on 2017/10/5.
//  Copyright © 2017年 张小东. All rights reserved.
//

#import "UploadImageZL.h"
#import "AFNetworking.h"
//#import "SVProgressHUD.h"

static AFHTTPSessionManager *manager;


@implementation UploadImageZL




//为了防止内存泄露
+ (AFHTTPSessionManager *)sharedHttpSession
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [AFHTTPSessionManager manager];
        manager.requestSerializer.timeoutInterval = 10;
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
    });
    return manager;
}

#pragma mark 上传单张图片
+ (void)uploadImageWithPath:(NSString *)path image:(UIImage *)image params:(NSDictionary *)params success:(HttpUploadSuccessBlock)success failure:(HttpUploadFailureBlock)failure
{
    NSArray *array = [NSArray arrayWithObject:image];
    [self uploadImageWithPath:path photos:array params:params success:success failure:failure];
}

#pragma mark 上传图片
+ (void)uploadImageWithPath:(NSString *)path photos:(NSArray *)photos params:(NSDictionary *)params success:(HttpUploadSuccessBlock)success failure:(HttpUploadFailureBlock)failure
{
//    [SVProgressHUD showProgress:-1 status:@"正在上传,请稍等."];
    path = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    AFHTTPSessionManager *manager = [UploadImageZL sharedHttpSession];
    [manager POST:path parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        for (int i = 0; i < photos.count; i ++) {
            NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
            formatter.dateFormat=@"yyyyMMddHHmmss";
            NSString *str=[formatter stringFromDate:[NSDate date]];
            NSString *fileName=[NSString stringWithFormat:@"%@.jpg",str];
            NSData *imagedata01 = photos[i];
            UIImage *image = [UIImage imageWithData:imagedata01];
            NSData *imageData = UIImageJPEGRepresentation(image, 0.28);
            [formData appendPartWithFileData:imageData name:[NSString stringWithFormat:@"upload%d",i+1] fileName:fileName mimeType:@"image/jpeg"];
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
//        MyLog(@"uploadProgress is %lld,总字节 is %lld",uploadProgress.completedUnitCount,uploadProgress.totalUnitCount);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"上传图片返回信息：%@",responseObject);
        NSString *resultCode = [NSString stringWithFormat:@"%@",[responseObject objectForKey:@"result_code"]];
        NSString *resultInfo = [responseObject objectForKey:@"result_info"];
//        MyLog(@"resultInfo is %@",resultInfo);
        if ([resultCode isEqualToString:@"1"]) {
//            [SVProgressHUD showSuccessWithStatus:@"上传成功"];
            if (success == nil) return ;
            success(responseObject);
        }else {
//            [SVProgressHUD showErrorWithStatus:resultInfo];
            if (failure == nil) return ;
            failure();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        [SVProgressHUD showErrorWithStatus:@"上传失败"];
        NSLog(@"上传图片失败---网络连接失败");
        if (failure == nil) return ;
        failure();
    }];
}


@end
