//
//  NTStatusTableViewCell.h
//  TableView
//
//  Created by MD101 on 14-10-10.
//  Copyright (c) 2014年 NT. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NTStatus;

@protocol NTStatusCellDelegate <NSObject>

@optional
- (void)OpenURL:(NSURL *)url;

@end

@interface NTStatusTableViewCell : UITableViewCell<NTStatusCellDelegate>

#pragma mark 資料
@property (nonatomic ,strong) NTStatus * status;

#pragma mark 單位高度
@property (nonatomic ,assign) CGFloat height;

@property (assign, nonatomic) id<NTStatusCellDelegate> delegate;

@end
