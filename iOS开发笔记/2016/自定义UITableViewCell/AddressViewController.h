//
//  AddressViewController.h
//  ZXMengGC
//
//  Created by apple on 14-3-3.
//  Copyright (c) 2014年 KingkongWolf. All rights reserved.
//

#import "DoingComViewController.h"
#import "AddfAddressController.h"
#import "CommonHeader.h"
#import "AddressDataList.h"
#import "MyButton.h"

@interface AddressViewController : DoingComViewController<AddAddressControllerDelegate,UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) AddfAddressController * addAddressController;
@property (strong, nonatomic) NSMutableArray * addressArr;

@property (strong, nonatomic) UITableView * addressTable;

@end
