//
//  UIButton+CircleLineButton.m
//  NTPU_KAT
//
//  Created by KuoAiTe on 2014/10/25.
//  Copyright (c) 2014年 KuoAiTe. All rights reserved.
//

#import "UIButton+CircleLineButton.h"

@interface CircleLineButton ()

@property (nonatomic, strong) CAShapeLayer *circleLayer;
@property (nonatomic, strong) UIColor *color;
@end

@implementation CircleLineButton

- (void)drawCircleButton:(UIColor *)color
{
    self.color = color;
    
    [self setTitleColor:color forState:UIControlStateNormal];
    
    self.circleLayer = [CAShapeLayer layer];
    
    [self.circleLayer setBounds:CGRectMake(0.0f, 0.0f, [self bounds].size.width,
                                           [self bounds].size.height)];
    [self.circleLayer setPosition:CGPointMake(CGRectGetMidX([self bounds]),CGRectGetMidY([self bounds]))];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    
    [self.circleLayer setPath:[path CGPath]];
    
    [self.circleLayer setStrokeColor:[color CGColor]];
    
    [self.circleLayer setLineWidth:2.0f];
    [self.circleLayer setFillColor:[[UIColor clearColor] CGColor]];
    
    [[self layer] addSublayer:self.circleLayer];
}

- (void)setHighlighted:(BOOL)highlighted
{
    if (highlighted)
    {
        self.titleLabel.textColor = [UIColor whiteColor];
        [self.circleLayer setFillColor:self.color.CGColor];
    }
    else
    {
        [self.circleLayer setFillColor:[UIColor clearColor].CGColor];
        self.titleLabel.textColor = self.color;
    }
}

@end