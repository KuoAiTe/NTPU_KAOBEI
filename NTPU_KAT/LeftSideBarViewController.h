//
//  LeftSideBarViewController.h
//  XWQSBK
//
//  Created by Ren XinWei on 13-4-28.
//  Copyright (c) 2013年 renxinwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SideBarSelectedDelegate.h"

/**
 * @brief 左边侧拉栏
 */
@protocol SideBarSelectedDelegate;

@interface LeftSideBarViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    
}
@property (assign, nonatomic) id<SideBarSelectedDelegate> delegate;
@property (retain, nonatomic) IBOutlet UIButton *sideSettingButton;
@property (retain, nonatomic) IBOutlet UIButton *sideFaceButton;
@property (retain, nonatomic) IBOutlet UIButton *sideJoinQBButton;
@property (retain, nonatomic) IBOutlet UIButton *sideTitleButton;
@property (retain, nonatomic) IBOutlet UITableView *sideMenuTableView;

- (IBAction)faceTitleView:(id)sender;
- (IBAction)sideSettingButtonClicked:(id)sender;

@end