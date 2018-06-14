//
//  RootController.m
//  NTPU_KAT
//
//  Created by KuoAiTe on 2014/7/5.
//  Copyright (c) 2014年 KuoAiTe. All rights reserved.
//

#import "RootController.h"
#import "KaoBeiController.h"
#import "LoginUIViewController.h"
#import "KaoBeiHistory.h"
#import "AppDelegate.h"
#import "KaoBeiController.h"
#import "KaoBeiSettings.h"

@implementation RootController{
    KaoBeiController *KaoBeiviewController;
    UILabel *profilePictureName;
    FBProfilePictureView *profilePictureView;
}

- (BOOL)shouldAutorotate
{
    return NO;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    KaoBeiviewController= [[KaoBeiController alloc] init];
    //self.navigationController setRo
    [self pushViewController:KaoBeiviewController animated:NO];
    KaoBeiviewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu-icon.png" ]  style:UIBarButtonItemStylePlain
                                                                                            target:self action:@selector(showMenu)];
}

#pragma mark -
#pragma mark Button actions

- (void)showMenu
{
    if (!_sideMenu) {
        RESideMenuItem *homeItem = [[RESideMenuItem alloc] initWithTitle:@"主畫面" action:^(RESideMenu *menu, RESideMenuItem *item) {
            [menu hide];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:KaoBeiviewController];
            navigationController.navigationBar.barTintColor = [UIColor whiteColor];
            [menu setRootViewController:navigationController];
        }];
        RESideMenuItem *exploreItem = [[RESideMenuItem alloc] initWithTitle:@"瀏覽紀錄" action:^(RESideMenu *menu, RESideMenuItem *item) {
            [menu hide];
            
            KaoBeiHistory* history = [KaoBeiHistory alloc];
            [history.view setBackgroundColor:[UIColor whiteColor]];
            
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:history];
            history.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
            UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu-icon.png" ]  style:UIBarButtonItemStylePlain
                                                                              target:self action:@selector(showMenu)];
            history.navigationItem.leftBarButtonItem = leftButtonItem;
            [menu setRootViewController:navigationController];
        }];
        RESideMenuItem *activityItem = [[RESideMenuItem alloc] initWithTitle:@"我的最愛" action:^(RESideMenu *menu, RESideMenuItem *item) {
            [menu hide];
            KaoBeiHistory* history = [KaoBeiHistory alloc];
            [history.view setBackgroundColor:[UIColor whiteColor]];
            
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:history];
            
            UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu-icon.png" ]  style:UIBarButtonItemStylePlain
                                                                              target:self action:@selector(showMenu)];
            history.navigationItem.leftBarButtonItem = leftButtonItem;

            [menu setRootViewController:navigationController];
            
        }];
        RESideMenuItem *profileItem = [[RESideMenuItem alloc] initWithTitle:@"頁面設定" action:^(RESideMenu *menu, RESideMenuItem *item) {
            [menu hide];
            
            KaoBeiSettings *SetCtrl = [[KaoBeiSettings alloc] init];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:SetCtrl];
            
            UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu-icon.png" ]  style:UIBarButtonItemStylePlain
                                                                              target:self action:@selector(showMenu)];
            SetCtrl.navigationItem.leftBarButtonItem = leftButtonItem;
            
            [menu setRootViewController:navigationController];
            
        }];
        RESideMenuItem *helpCenterItem = [[RESideMenuItem alloc] initWithTitle:@"關於我們" action:^(RESideMenu *menu, RESideMenuItem *item) {
            [menu hide];
            NSLog(@"Item %@", item);
        }];
        RESideMenuItem *logOutItem = [[RESideMenuItem alloc] initWithTitle:@"Log out" action:^(RESideMenu *menu, RESideMenuItem *item) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Confirmation" message:@"Are you sure you want to log out?" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Log Out", nil];
            [alertView show];
        }];
        
        _sideMenu = [[RESideMenu alloc] initWithItems:@[homeItem, exploreItem, activityItem, profileItem, helpCenterItem, logOutItem]];
        _sideMenu.verticalOffset = IS_WIDESCREEN ? 110 : 76;
        _sideMenu.hideStatusBarArea = [AppDelegate OSVersion] < 7;
    }
    
    [_sideMenu show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
