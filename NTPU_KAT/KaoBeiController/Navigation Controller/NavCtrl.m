//
//  NavCtrl.m
//  NTPU_KAT
//
//  Created by KuoAiTe on 2014/11/15.
//  Copyright (c) 2014年 KuoAiTe. All rights reserved.
//

#import "NavCtrl.h"
@interface NavCtrl ()

@end

@implementation NavCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationBar setBarTintColor:RGBA(75,193,210,1)];
    //[self.navigationBar setBackgroundColor:RGBA(75,193,210,1)];
    self.navigationBar.translucent = YES;
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
