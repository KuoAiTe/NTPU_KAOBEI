//
//  LoadingView.m
//  NTPU_KAT
//
//  Created by KuoAiTe on 2014/11/16.
//  Copyright (c) 2014年 KuoAiTe. All rights reserved.
//

#import "LoadingView.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@implementation LoadingView
-(void)baseInit{
    loadingView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DeviceWidth, DeviceHeight)];
    loadingView.backgroundColor = [UIColor colorWithWhite:0. alpha:0.6];
    loadingView.layer.cornerRadius = 5;
    [self addSubview:loadingView];
    UIImageView *loadcow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cow.png"]];
    loadcow.frame=CGRectMake(0, 0,64, 64);
    loadcow.center =CGPointMake(loadingView.frame.size.width / 2.0, NavHeight + StatusBarHeight + BodyHeight /2 - 30);
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/  ];
    rotationAnimation.duration = 1.5;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = INFINITY;
    
    [loadcow.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    
    
    lblLoading = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 150, 60)];
    lblLoading.center = CGPointMake(loadingView.frame.size.width / 2.0,  NavHeight + StatusBarHeight + BodyHeight /2 + 25);
    lblLoading.text = @"讀取中，請稍後";
    lblLoading.textColor = [UIColor whiteColor];
    lblLoading.backgroundColor = [UIColor clearColor];
    lblLoading.font = [UIFont fontWithName:lblLoading.font.fontName size:15];
    lblLoading.textAlignment = NSTextAlignmentCenter;
    lblLoading.numberOfLines = 0;
    [loadingView addSubview:lblLoading];
    
    [self addSubview:loadcow];

}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self baseInit];
    }
    return self;
}
-(void)show{
    [UIView animateWithDuration:1.0f animations:^{
        self.alpha = 1;
    } completion:^(BOOL completed) {
    }];
}
-(void)hide{
    [UIView animateWithDuration:0.4f animations:^{
        self.alpha = 0;
    } completion:^(BOOL completed) {
    }];
}
@end
