//  GitHub: https://github.com/Tate-zwt/WTSDK
//  ViewController.m
//  WTSDK
//
//  Created by 张威庭 on 15/12/16.
//  Copyright © 2015年 zwt. All rights reserved.
//

#import "ViewController.h"
#import "WTConst.h"
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *introducingLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_introducingLabel settingLabelHeightofRowString:@"源码在WTSDK文件夹里，如果你觉得不错的话，麻烦在GitHub上面点个Star，thank you all!"];
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.x = 50;
    button.y = 100;
    button.width = 100;
    button.height = 30;
    button.titleLabel.font = [UIFont systemFontOfSize:12.0f];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [button border:[UIColor lightGrayColor] width:1.0f CornerRadius:5.0];
    [button setTitle:@"发送验证码" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)buttonAction:(UIButton *)sender{
    [sender startWithTime:60 title:@"发送验证码" countDownTitle:@"s后重新发送" mainColor: [UIColor whiteColor] countColor: [UIColor whiteColor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
