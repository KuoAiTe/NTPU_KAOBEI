//
//  LoadingCell.m
//  NTPU_KAT
//
//  Created by KuoAiTe on 2014/12/2.
//  Copyright (c) 2014年 KuoAiTe. All rights reserved.
//

#import "LoadingCell.h"

@implementation LoadingCell{
    
    UILabel *loadinglabel;
    UIActivityIndicatorView *activityView;
}

- (void)awakeFromNib {
    // Initialization code
    loadinglabel = [[UILabel alloc] init];
    loadinglabel.textColor = [UIColor whiteColor];
    activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    
    [self addSubview:loadinglabel];
    [self addSubview:activityView];

}
-(void)configure:(BOOL)loading{
    if(loading){
        loadinglabel.text = @"讀取中";
        [loadinglabel sizeToFit];
        loadinglabel.center = CGPointMake( DeviceWidth/2, 22);
        
        activityView.hidden=NO;
        activityView.frame = CGRectMake(loadinglabel.frame.origin.x - 20, 20, 5, 5);
        [activityView startAnimating];
        self.backgroundColor =RGB(135,216,223);
    }else{
        [activityView stopAnimating];
        loadinglabel.text = @"檢視更多留言";
        [loadinglabel sizeToFit];
        loadinglabel.center = CGPointMake( DeviceWidth/2, 22);
        self.backgroundColor = [UIColor lightGrayColor];
        activityView.hidden=YES;
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
