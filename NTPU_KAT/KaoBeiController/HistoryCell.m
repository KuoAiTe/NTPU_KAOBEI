//
//  HistoryCell.m
//  NTPU_KAT
//
//  Created by KuoAiTe on 2014/8/23.
//  Copyright (c) 2014年 KuoAiTe. All rights reserved.
//

#import "HistoryCell.h"

@implementation HistoryCell

- (void)awakeFromNib
{
    // Initialization code
    if ([self respondsToSelector:@selector(setLayoutMargins:)]) {
        [self setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
