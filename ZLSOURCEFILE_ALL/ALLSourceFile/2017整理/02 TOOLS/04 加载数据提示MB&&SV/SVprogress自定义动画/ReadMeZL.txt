
//在APPdelegate中添加下面方法并调用
#pragma mark ===================ZL加载动画开始==================
#pragma mark --- SVProgressHUD 偏好设置
- (void)svPreferrenceConf{
    
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleLight];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD setBackgroundColor:[UIColor clearColor]];
    [SVProgressHUD setMinimumDismissTimeInterval:CGFLOAT_MAX];
    [SVProgressHUD setInfoImage:[UIImage imageWithGIFNamed:@"loading02"]];
    [[SVProgressHUD sharedView] setImageViewSize:CGSizeMake(70, 70)];
}
#pragma mark ===================ZL加载动画结束==================