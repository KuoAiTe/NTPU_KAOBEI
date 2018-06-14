//
//  MainController.m
//  NTPU_KAT
//
//  Created by KuoAiTe on 2014/11/15.
//  Copyright (c) 2014年 KuoAiTe. All rights reserved.
//

#import "MainController.h"
#import "KaoBeiController.h"
#import "KaoBeiHistory.h"
#import "KaoBeiFavorite.h"
#import "NavCtrl.h"
#import "SettingCtrl.h"
#import <CoreImage/CoreImage.h>
@interface MainController ()

@end

@implementation MainController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _CurrentView  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DeviceWidth, DeviceHeight - TabBarHeight -(StatusBarCurHeight - StatusBarHeight))];
        _TarBar = [[UIView alloc] initWithFrame:CGRectMake(0, DeviceHeight - TabBarHeight-(StatusBarCurHeight - StatusBarHeight), DeviceWidth, TabBarHeight)];
        _ViewControllers = [[NSArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [_TarBar setBackgroundColor:RGBA(244,244,244,0.7)];
    [self.view addSubview:_CurrentView];
    [self.view addSubview:_TarBar];
    UIToolbar *_blurToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, DeviceWidth, TabBarHeight)];
    [_blurToolbar setAlpha:0.2];
    [_blurToolbar setBackgroundColor:[UIColor whiteColor]];
    [_TarBar addSubview:_blurToolbar];
    //瀏覽專頁
    KaoBeiController *ctl1 = [[KaoBeiController alloc] init];
    NavCtrl *nav1 = [[NavCtrl alloc] initWithRootViewController:ctl1];
    
    
    KaoBeiFavorite* ctl2 = [[KaoBeiFavorite alloc] init];
    NavCtrl *nav2 = [[NavCtrl alloc] initWithRootViewController:ctl2];
    
    KaoBeiHistory *ctl3 = [[KaoBeiHistory alloc] init];
    NavCtrl *nav3 = [[NavCtrl alloc] initWithRootViewController:ctl3];
    
    SettingCtrl *ctl4 = [[SettingCtrl alloc] init];
    NavCtrl *nav4 = [[NavCtrl alloc] initWithRootViewController:ctl4];
    
    
    self.ViewControllers = @[nav1,nav2,nav3,nav4];
    
    [_CurrentView addSubview:nav1.view];
    //设置TabBar的button按钮
    for (int i = 0; i < _ViewControllers.count; i++) {
        UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
        b.frame= CGRectMake(DeviceWidth/_ViewControllers.count*i, 0, DeviceWidth/_ViewControllers.count, 49);
        b.tag = 9999 + i;
        [b setImage:[UIImage imageNamed:[NSString stringWithFormat:@"menu-%d.png",i]] forState:UIControlStateNormal];
        [b setImage:[UIImage imageNamed:[NSString stringWithFormat:@"menu-%d-highlight.png",i]] forState:UIControlStateHighlighted];
        [b setImage:[UIImage imageNamed:[NSString stringWithFormat:@"menu-%d-highlight.png",i]] forState:UIControlStateSelected];
        if( i == 0)
           [b setSelected:YES];
        [b addTarget:self action:@selector(changeNav:) forControlEvents:UIControlEventTouchUpInside];
        [_TarBar addSubview:b];
    }
}

NSInteger preTag = 9999;
- (void)changeNav:(UIButton *)b
{
    UIButton * preBtn = (UIButton *)[self.view viewWithTag:preTag];
    preTag = b.tag;
    [preBtn setSelected:NO];
    [b setSelected:YES];
    UINavigationController *nav = self.ViewControllers[b.tag-9999];
    for (UIView *obj in _CurrentView.subviews)
    {
        [obj removeFromSuperview];
    }
    [_CurrentView addSubview:nav.view];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 狀態欄顏色

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(BOOL)shouldAutorotate
{
    return NO;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    _CurrentView.frame = CGRectMake(0, 0, DeviceWidth, DeviceHeight - TabBarHeight -(StatusBarCurHeight - StatusBarHeight));
    _TarBar.frame = CGRectMake(0, DeviceHeight - TabBarHeight-(StatusBarCurHeight - StatusBarHeight), DeviceWidth, TabBarHeight);
}
@end
