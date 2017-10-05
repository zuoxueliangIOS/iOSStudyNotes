//
//  YPPhotosController.m
//  YPPhotoDemo
//
//  Created by YueWen on 16/7/14.
//  Copyright © 2017年 YueWen. All rights reserved.
//

#import "RITLPhotosViewController.h"
#import "RITLPhotosCell.h"
#import "RITLPhotoBottomReusableView.h"
#import "RITLPhotosViewModel.h"
#import "RITLPhotoConfig.h"
#import "RITLPhotoBrowseController.h"
#import "RITLPhotoBrowseViewModel.h"

#import "RITLPhotoPreviewController.h"

#import "RITLPhotoHandleManager.h"
#import "UIView+RITLFrameChanged.h"
#import "UIButton+RITLBlockButton.h"
#import "UIViewController+RITLPhotoAlertController.h"
#import <Masonry.h>

#import <objc/message.h>

static NSString * cellIdentifier = @"RITLPhotosCell";
static NSString * reusableViewIdentifier = @"RITLPhotoBottomReusableView";


#ifdef __IPHONE_10_0
@interface RITLPhotosViewController ()<UIViewControllerPreviewingDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UICollectionViewDataSourcePrefetching>
#else

#ifdef __IPHONE_9_0
@interface RITLPhotosViewController ()<UIViewControllerPreviewingDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>
#else
@interface RITLPhotosViewController ()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>
#endif
#endif

/// @brief 显示的集合视图
@property (nonatomic, strong) UICollectionView * collectionView;
/// @brief 底部的tabBar
@property (nonatomic, strong) UIView * bottomBar;
/// @brief 发送按钮
@property (strong, nonatomic) UIButton * sendButton;
/// @brief 显示数目
@property (strong, nonatomic) UILabel * numberOfLabel;
/// @brief 预览按钮
@property (strong, nonatomic) UIButton * bowerButton;

@end

@implementation RITLPhotosViewController


-(instancetype)initWithViewModel:(id<RITLPhotoCollectionViewModel>)viewModel
{
    if (self = [super init])
    {
       self.viewModel = viewModel;
    }

    return self;
}


+(instancetype)photosViewModelInstance:(id<RITLPhotoCollectionViewModel>)viewModel
{
    return [[self alloc]initWithViewModel:viewModel];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = self.viewModel.title;
    
    //绑定viewModel
    [self bindViewModel];

    //设置navigationItem
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissViewController)];

    //添加视图
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.bottomBar];
    
    
    //获得资源数
    NSUInteger items = [self.viewModel numberOfItemsInSection:0];
  
    if (items >= 1)
    {
        //滚动到最后一个
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:items - 1 inSection:0]atScrollPosition:UICollectionViewScrollPositionBottom animated:false];

        //重置偏移量
        [self.collectionView setContentOffset:CGPointMake(0, self.collectionView.contentOffset.y + 64)];
    }
    
    
    //进行autoLayout布局
    [self autoLayoutSubViews];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:false animated:true];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


 - (void)autoLayoutSubViews
{
    [self.bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.left.and.right.offset(0);
        
        //获得高度
        if (RITLPhotoIsiPhoneX) {
            
            make.height.mas_equalTo(83 - 5);
            
        }else {
            
            make.height.mas_equalTo(44);
        }
    }];
    
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.top.right.offset(0);
        make.bottom.equalTo(self.bottomBar.mas_top);
        
    }];
    
}



-(void)dealloc
{
    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;
    
#ifdef __IPHONE_10_0
    if ([UIDevice currentDevice].systemVersion.floatValue >= 10.0f)
    {
        _collectionView.prefetchDataSource = nil;
    }
    
#endif
    
#ifdef RITLDebug
    NSLog(@"Dealloc %@",NSStringFromClass([self class]));
#endif
}



- (void)bindViewModel
{
    if ([self.viewModel isMemberOfClass:[RITLPhotosViewModel class]])
    {
        RITLPhotosViewModel * viewModel = self.viewModel;
        
        __weak typeof(self) weakSelf = self;
        
        // 跳转至预览视图
        viewModel.photoDidTapShouldBrowerBlock = ^(PHFetchResult * result,NSArray <PHAsset *> * allAssets,NSArray <PHAsset *> * allPhotoAssets,PHAsset * asset,NSUInteger index){
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            /// 创建viewModel
            RITLPhotoBrowseViewModel * viewModel = [RITLPhotoBrowseViewModel new];
            
            /// 设置所有的属性
            viewModel.allAssets = allAssets;
            viewModel.allPhotoAssets = allPhotoAssets;
            viewModel.currentIndex = index;
            
            //记录刷新当前的视图
            viewModel.ritl_BrowerWillDisAppearBlock = ^{
              
                [strongSelf.collectionView reloadData];
                
                // 检测发送按钮可用性
                ((void(*)(id,SEL))objc_msgSend)(strongSelf.viewModel,NSSelectorFromString(@"ritl_checkPhotoSendStatusChanged"));
                
            };
            
            //进入一个浏览控制器
            [strongSelf.navigationController pushViewController:[RITLPhotoBrowseController photosViewModelInstance:viewModel] animated:true];
            
        };
        
        // 发送数目标签响应变化
        viewModel.photoSendStatusChangedBlock = ^(BOOL enable,NSUInteger count){
          
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            strongSelf.bowerButton.enabled = enable;
            strongSelf.sendButton.enabled = enable;
            
            //设置标签数目
            [strongSelf updateNumbersForSelectAssets:count];
        };
        
        
        // 弹出警告框
        viewModel.warningBlock = ^(BOOL result,NSUInteger maxCount){
          
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            [strongSelf presentAlertController:maxCount];
        };
        
        // 模态弹出
        viewModel.dismissBlock = ^{
          
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            [strongSelf dismissViewController];
        };
    }
}



#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.viewModel.numberOfSection;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.viewModel numberOfItemsInSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RITLPhotosCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if ([self.viewModel isMemberOfClass:[RITLPhotosViewModel class]])
    {
        RITLPhotosViewModel * viewModel = self.viewModel;
        
        // 获得图片对象
        [viewModel imageForIndexPath:indexPath collection:collectionView complete:^(UIImage * _Nonnull image, PHAsset * _Nonnull asset, BOOL isImage,NSTimeInterval durationTime) {
            
            cell.imageView.image = image;
            
            cell.chooseControl.hidden = !isImage;
            
            // 如果不是图片
            if (!isImage)
            {
                cell.messageView.hidden = isImage;
                cell.messageLabel.text =  [RITLPhotoHandleManager timeStringWithTimeDuration:durationTime];
            }
    
        }];

        
        // 响应选择
        cell.chooseImageDidSelectBlock = ^(RITLPhotosCell * cell){
          
            // 修改数据源成功
            if([viewModel didSelectImageAtIndexPath:indexPath])
            {
                // 修改UI
                [cell cellSelectedAction:[viewModel imageDidSelectedAtIndexPath:indexPath]];
            }
        };
    }
    

    
#ifdef __IPHONE_9_0
    
    if ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f)
    {
        NSUInteger item = indexPath.item;
        
        //获得当前的资源对象
        PHAsset * asset = [((RITLPhotosViewModel *)self.viewModel).assetResult objectAtIndex:item];
        
        BOOL isPhoto = (asset.mediaType == PHAssetMediaTypeImage);
        
        //确定为图片并且3D Touch可用
        if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable && isPhoto == true)
        {
            [self registerForPreviewingWithDelegate:self sourceView:cell];
        }
    }

#endif
    
    return cell;
}


//设置footerView
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    RITLPhotoBottomReusableView * resuableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:reusableViewIdentifier forIndexPath:indexPath];

    resuableView.numberOfAsset = ((RITLPhotosViewModel *)self.viewModel).assetCount;
    
    return resuableView;
}


#pragma mark - <UICollectionViewDelegateFlowLayout>
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.viewModel sizeForItemAtIndexPath:indexPath inCollection:collectionView];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return [self.viewModel referenceSizeForFooterInSection:section inCollection:collectionView];
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return [self.viewModel minimumLineSpacingForSectionAtIndex:section];
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return [self.viewModel minimumInteritemSpacingForSectionAtIndex:section];
}

#pragma mark <UICollectionViewDelegate>

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.viewModel shouldSelectItemAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.viewModel didSelectItemAtIndexPath:indexPath];
}


- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    //是否显示选中标志
    [((RITLPhotosCell *)cell) cellSelectedAction:[((RITLPhotosViewModel *)self.viewModel) imageDidSelectedAtIndexPath:indexPath]];
}


#pragma mark - <UICollectionViewDataSourcePrefetching>

#ifdef __IPHONE_10_0

- (void)collectionView:(UICollectionView *)collectionView prefetchItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
    [self.viewModel prefetchItemsAtIndexPaths:indexPaths];
}

- (void)collectionView:(UICollectionView *)collectionView cancelPrefetchingForItemsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
    [self.viewModel cancelPrefetchingForItemsAtIndexPaths:indexPaths];
}


#endif



#pragma mark - <UIViewControllerPreviewingDelegate>

#ifdef  __IPHONE_9_0

//#warning 会出现内存泄露，临时不使用
- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    //获取当前cell的indexPath
    NSIndexPath * indexPath = [self.collectionView indexPathForCell:(RITLPhotosCell *)previewingContext.sourceView];
    
    NSUInteger item = indexPath.item;
    
    //获得当前的资源
    PHAsset * asset = [((RITLPhotosViewModel *)self.viewModel).assetResult objectAtIndex:item];
    
    if (asset.mediaType != PHAssetMediaTypeImage)
    {
        return nil;
    }
    
    RITLPhotoPreviewController * viewController = [RITLPhotoPreviewController previewWithShowAsset:asset];
    
    return viewController;
}


- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    //获取当前cell的indexPath
    NSIndexPath * indexPath = [self.collectionView indexPathForCell:(RITLPhotosCell *)previewingContext.sourceView];
    
    
    [self.viewModel didSelectItemAtIndexPath:indexPath];
}
#endif



#pragma mark - Getter Function
-(UICollectionView *)collectionView
{
    if(_collectionView == nil)
    {
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, self.ritl_width, self.ritl_height - 44) collectionViewLayout:[[UICollectionViewFlowLayout alloc]init]];
        
        //protocol
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        
#ifdef __IPHONE_10_0
        if ([UIDevice currentDevice].systemVersion.floatValue >= 10.0f)
        {
            _collectionView.prefetchDataSource = self;
        }
        
#endif
        
        //property
        _collectionView.backgroundColor = [UIColor whiteColor];
        
        //register View
        [_collectionView registerClass:[RITLPhotosCell class] forCellWithReuseIdentifier:cellIdentifier];
        [_collectionView registerClass:[RITLPhotoBottomReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:reusableViewIdentifier];
    }
    
    return _collectionView;
}

-(UIView *)bottomBar
{
    if (_bottomBar == nil)
    {
        _bottomBar = [[UIView alloc]initWithFrame:CGRectMake(0, self.ritl_height - 44, self.ritl_width, 44)];
        
        //add subviews
        [_bottomBar addSubview:self.sendButton];
        [_bottomBar addSubview:self.numberOfLabel];
        [_bottomBar addSubview:self.bowerButton];
    }
    
    return _bottomBar;
}

-(UIButton *)bowerButton
{
    if (_bowerButton == nil)
    {
        _bowerButton = [[UIButton alloc]initWithFrame:CGRectMake(5, 5, 60, 30)];
        
        [_bowerButton setTitle:@"预览" forState:UIControlStateNormal];
        [_bowerButton setTitle:@"预览" forState:UIControlStateDisabled];
        
        [_bowerButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_bowerButton setTitleColor:[[UIColor blackColor] colorWithAlphaComponent:0.25] forState:UIControlStateDisabled];
        
        [_bowerButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_bowerButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        
        _bowerButton.showsTouchWhenHighlighted = true;
        
        //默认不可点击
        _bowerButton.enabled = false;
        
        __weak typeof(self) weakSelf = self;
        
        [_bowerButton controlEvents:UIControlEventTouchUpInside handle:^(UIControl * _Nonnull sender) {
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            //跳转至预览视图
            ((void(*)(id,SEL))objc_msgSend)(strongSelf.viewModel,NSSelectorFromString(@"pushBrowerControllerByBrowerButtonTap"));
            
        }];
        
        
    }
    return _bowerButton;
}




-(UIButton *)sendButton
{
    if (_sendButton == nil)
    {
        _sendButton = [[UIButton alloc]initWithFrame:CGRectMake(_bottomBar.ritl_width - 50 - 5, 0, 50, 40)];
        _sendButton.center = CGPointMake(_sendButton.center.x, _bottomBar.center.y - _bottomBar.ritl_originY);
        
        [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
        [_sendButton setTitle:@"发送" forState:UIControlStateDisabled];
        
        [_sendButton setTitleColor:RITLColorFromRGB(0x2dd58a) forState:UIControlStateNormal];
        [_sendButton setTitleColor:[RITLColorFromRGB(0x2DD58A) colorWithAlphaComponent:0.25] forState:UIControlStateDisabled];
        
        [_sendButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_sendButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        
        _sendButton.showsTouchWhenHighlighted = true;
        
        //默认为不可点击
        _sendButton.enabled = false;
        
        __weak typeof(self) weakSelf = self;
        
        [_sendButton controlEvents:UIControlEventTouchUpInside handle:^(UIControl * _Nonnull sender) {
           
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            NSLog(@"发送!");
            
            // 选择完毕
            [((RITLPhotosViewModel *)strongSelf.viewModel) photoDidSelectedComplete];
            
        }];
        
    }
    
    return _sendButton;
}

-(UILabel *)numberOfLabel
{
    if (_numberOfLabel == nil)
    {
        _numberOfLabel = [[UILabel alloc]initWithFrame:CGRectMake(_sendButton.ritl_originX - 20, 0, 20, 20)];
        _numberOfLabel.center = CGPointMake(_numberOfLabel.center.x, _sendButton.center.y);
        _numberOfLabel.backgroundColor = RITLColorFromRGB(0x2dd58a);
        _numberOfLabel.textAlignment = NSTextAlignmentCenter;
        _numberOfLabel.font = [UIFont boldSystemFontOfSize:14];
        _numberOfLabel.text = @"";
        _numberOfLabel.hidden = true;
        _numberOfLabel.textColor = [UIColor whiteColor];
        _numberOfLabel.layer.cornerRadius = _numberOfLabel.ritl_width / 2.0;
        _numberOfLabel.clipsToBounds = true;
    }
    
    return _numberOfLabel;
}


-(RITLPhotosViewModel *)viewModel
{
    if (!_viewModel)
    {
        _viewModel = [RITLPhotosViewModel new];
    }
    
    return _viewModel;
}



-(void)dismissViewController
{
    return [super dismissViewControllerAnimated:true completion:nil];
}




@end



@implementation RITLPhotosViewController (updateNumberOfLabel)

-(void)updateNumbersForSelectAssets:(NSUInteger)number
{
    BOOL hidden = (number == 0);
    
    _numberOfLabel.hidden = hidden;
    
    if (!hidden)
    {
        _numberOfLabel.text = [NSString stringWithFormat:@"%@",@(number)];
        
        //设置放射以及动画
        _numberOfLabel.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
        
        [UIView animateWithDuration:0.3 animations:^{
          
            _numberOfLabel.transform = CGAffineTransformIdentity;
            
        }];
    }
}


@end
