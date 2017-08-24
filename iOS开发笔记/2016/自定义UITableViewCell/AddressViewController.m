//
//  AddressViewController.m
//  ZXMengGC
//
//  Created by apple on 14-3-3.
//  Copyright (c) 2014年 KingkongWolf. All rights reserved.
//

#import "AddressViewController.h"

@interface AddressViewController ()

@end

@implementation AddressViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //初始化数组
    self.addressArr = [[NSMutableArray alloc]init];
    
	//加载  列表视图
    [self loadTableView];
}

//加载列表视图
- (void)loadTableView
{
    self.addressArr = [AddressDataList findAll];
    NSLog(@"通讯录中的联系人个数：%d",self.addressArr.count);
    
    self.addressTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, SIZE_WIDTH, SIZE_HEIGHT - 64 - 49) style:UITableViewStylePlain];
    self.addressTable.delegate = self;
    self.addressTable.dataSource = self;
    self.addressTable.bounces = NO;
    //设置分割线
    [self.addressTable setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    [self.view addSubview:self.addressTable];
}

#pragma mark UITableViewDelegate
//返回行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.addressArr.count;

}
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;

}
*/
//返回行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return 90.0;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 40.0;

}
//返回底部视图
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{

    UIButton * btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(0, 0, SIZE_WIDTH, SIZE_HEIGHT);
    [btn setBackgroundImage:[UIImage imageNamed:@"yckgd_add"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(addAddressButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * identifer = @"address";
    UITableViewCell * cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:identifer];
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer];
    
        UILabel * zhiLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 10, 40, 25)];
        zhiLabel.textColor = [UIColor blackColor];
        zhiLabel.tag  = 1;
        [cell.contentView addSubview:zhiLabel];
        
        UILabel * zhiWu = [[UILabel alloc]initWithFrame:CGRectMake(60, 10, 100, 25)];
        zhiWu.tag = 2;
        zhiWu.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:zhiWu];
        
        UILabel * xingLabel = [[UILabel alloc]initWithFrame:CGRectMake(160, 10, 40, 25)];
        xingLabel.tag = 3;
        [cell.contentView addSubview:xingLabel];
        
        UILabel * nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(200, 10, 100, 25)];
        nameLabel.tag = 4;
        nameLabel.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:nameLabel];
        
        UILabel * dianhuaLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 50, 40, 25)];
        dianhuaLabel.tag = 5;
        [cell.contentView addSubview:dianhuaLabel];
        
        UILabel * phoneLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 50, 130, 25)];
        phoneLabel.tag = 6;
        [cell.contentView addSubview:phoneLabel];
        
        MyButton * messegeBtn = [MyButton buttonWithType:UIButtonTypeSystem];
        messegeBtn.tag = 7;
        [messegeBtn setFrame:CGRectMake(200, 50, 40, 25)];
        [messegeBtn setTitle:@"短信" forState:UIControlStateNormal];
        [cell.contentView addSubview:messegeBtn];
        
        MyButton * phoneBtn = [MyButton buttonWithType:UIButtonTypeSystem];
        phoneBtn.tag = 8;
        [phoneBtn setTitle:@"电话" forState:UIControlStateNormal];
        [phoneBtn setFrame:CGRectMake(250, 50, 40, 25)];
        [cell.contentView addSubview:phoneBtn];
        
    }

    UILabel * zhiLabel = (UILabel *)[cell viewWithTag:1];
    UILabel * zhiWu = (UILabel *)[cell viewWithTag:2];
    UILabel * xingLabel = (UILabel *)[cell viewWithTag:3];
    UILabel * nameLabel = (UILabel *)[cell viewWithTag:4];
    UILabel * dianLabel = (UILabel *)[cell viewWithTag:5];
    UILabel * phoneLabel = (UILabel *)[cell viewWithTag:6];
    MyButton * messegeBtn = (MyButton *)[cell viewWithTag:7];
    MyButton * phoneBtn = (MyButton *)[cell viewWithTag:8];
    //清除所有视图，避免显示混乱
    for (UIView * view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    AddressContent * addressContent = (AddressContent *)[self.addressArr objectAtIndex:indexPath.row];
    NSLog(@"每个联系人信息：职务：%@ 姓名：%@ 电话：%@",addressContent.zhiWu,addressContent.name,addressContent.phone);
    [zhiWu setText:addressContent.zhiWu];
    [nameLabel setText:addressContent.name];
    [phoneLabel setText:addressContent.phone];
    
    //UIButton 的延展 传入号码
    phoneBtn.telphone = addressContent.phone;
    messegeBtn.telphone = addressContent.phone;
    
    [zhiLabel setText:@"职务:"];
    [xingLabel setText:@"姓名:"];
    [dianLabel setText:@"电话:"];
    [messegeBtn addTarget:self action:@selector(messegeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [phoneBtn addTarget:self action:@selector(phoneBuutonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    cell.frame = CGRectMake(0, 0, SIZE_WIDTH, 90);
    //cell.contentView.frame = CGRectMake(0, 0, SIZE_WIDTH, 90);
    [cell.contentView addSubview:zhiWu];
    [cell.contentView addSubview:zhiLabel];
    [cell.contentView addSubview:xingLabel];
    [cell.contentView addSubview:nameLabel];
    [cell.contentView addSubview:dianLabel];
    [cell.contentView addSubview:phoneLabel];
    [cell.contentView addSubview:messegeBtn];
    [cell.contentView addSubview:phoneBtn];
    
    //设置选中后的样式
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

//删除单元格的方法
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        AddressContent * addressContent = (AddressContent *)[self.addressArr objectAtIndex:indexPath.row];
        //1.将数据从数据库中删除
        [AddressDataList deleteByPhone:addressContent.phone];
        //2.将数据在数组中删除
        [self.addressArr removeObjectAtIndex:indexPath.row];
        //3.将数据在单元格中删除
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

//发短信实现方法
- (void)messegeButtonAction:(MyButton *)sender
{
    NSLog(@"实现了发短信,联系人号码是：%@",sender.telphone);
    NSString * string = [NSString stringWithFormat:@"sms://%@",sender.telphone];
    //3、调用 SMS
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:string]];

}
//打电话按钮的实现方法
- (void)phoneBuutonAction:(MyButton *)sender
{

    NSLog(@"实现了打电话,联系人的号码是：%@",sender.telphone);
    /*
    //1.打电话 发短信
    一般在应用中拨打电话的方式是： 使用这种方式拨打电话时，当用户结束通话后，iphone界面会停留在电话界面。
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel://123456789"]];
    */
    //用如下方式，可以使得用户结束通话后自动返回到应用：
    UIWebView * callWebview =[[UIWebView alloc] init];
    NSString * phoneString = [NSString stringWithFormat:@"tel:%@",sender.telphone];
    NSURL *telURL =[NSURL URLWithString:phoneString];// 貌似tel:// 或者 tel: 都行
    [callWebview loadRequest:[NSURLRequest requestWithURL:telURL]];
    //记得添加到view上
    [self.view addSubview:callWebview];
    /*
     
     　还有一种私有方法：（可能不能通过审核）
     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"telprompt://10086"]];
     */


}

#pragma end mark


- (IBAction)addAddressBtn:(UIButton *)sender {
    [self addAddressButtonAction:sender];
}

- (void)addAddressButtonAction:(UIButton *)sender
{
    self.addAddressController = (AddfAddressController *)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"addAddressController"];
    self.addAddressController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    self.addAddressController.delegate = self;
    [self presentViewController:self.addAddressController animated:YES completion:^{
        
    }];

}

#pragma mark AddAddressControllerDelegate代理方法
- (void)addAddressController:(AddfAddressController *)controller withAddressContent:(AddressContent *)addressContent
{
    NSLog(@"AddressViewController执行了代理方法");
    NSLog(@"传入联系人信息：职务：%@  姓名:%@  手机：%@",addressContent.zhiWu,addressContent.name,addressContent.phone);
    
    BOOL isOK = [AddressDataList addZhiWu:addressContent.zhiWu withName:addressContent.name withPhone:addressContent.phone];
    NSLog(@"是否添加联系人成功：%d",isOK);

    if (!isOK) {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"亲，号码已存在！" message:Nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定!", nil];
        [self.view addSubview:alert];
        [alert show];
    }
    else
    {

        [self.addressArr addObject:addressContent];
        
        [self.addressTable reloadData];
    
    }

}

#pragma end mark

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
