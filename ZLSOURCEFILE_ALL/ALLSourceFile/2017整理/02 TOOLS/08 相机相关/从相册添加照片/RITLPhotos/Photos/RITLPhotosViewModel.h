//
//  RITLPhotosViewModel.h
//  RITLPhotoDemo
//
//  Created by YueWen on 2016/11/29.
//  Copyright © 2017年 YueWen. All rights reserved.
//

#import "RITLPhotoBaseViewModel.h"
#import "RITLPhotoCollectionCellViewModel.h"
#import "RITLPhotoCollectionViewModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef PhotoCompleteBlock7 RITLPhotoDidTapHandleBlock;
typedef PhotoCompleteBlock6 RITLPhotoSendStatusBlock;

/// 选择图片的一级界面控制器的viewModel
@interface RITLPhotosViewModel : RITLPhotoBaseViewModel <RITLPhotoCollectionViewModel>

/// 当前显示的导航标题
@property (nonatomic, copy) NSString * navigationTitle;

/// 当前显示的组对象
@property (nonatomic, strong) PHAssetCollection * assetCollection;

/// 存储该组所有的asset对象的集合
@property (nonatomic, strong, readonly) PHFetchResult * assetResult;

/// 图片被点击进入浏览控制器的block
@property (nonatomic, copy)RITLPhotoDidTapHandleBlock photoDidTapShouldBrowerBlock;

/// 响应是否能够点击预览以及发送按钮的block
@property (nonatomic, copy)RITLPhotoSendStatusBlock photoSendStatusChangedBlock;

/// 点击预览进入浏览控制器的block，暂时使用photoDidTapShouldBrowerBlock替代
@property (nonatomic, copy)RITLPhotoDidTapHandleBlock pushBrowerControllerByBrowerButtonBlock;


/**
 通过点击浏览按钮弹出浏览控制器，触发pushBrowerControllerByBrowerButton
 */
- (void)pushBrowerControllerByBrowerButtonTap;


/// 资源数
- (NSUInteger)assetCount;

/// 请求当前图片对象
- (void)imageForIndexPath:(NSIndexPath *)indexPath
               collection:(UICollectionView *)collection
                 complete:(void(^)(UIImage *,PHAsset *,BOOL,NSTimeInterval)) completeBlock;


/**
 图片被选中的处理方法

 @param indexPath 
 */
- (BOOL)didSelectImageAtIndexPath:(NSIndexPath *)indexPath;


/**
 该位置的图片是否选中

 @param indexPath
 @return
 */
- (BOOL)imageDidSelectedAtIndexPath:(NSIndexPath *)indexPath;


@end

NS_ASSUME_NONNULL_END
