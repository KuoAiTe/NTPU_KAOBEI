//
//  CommentCell.h
//  XWQSBK
//
//  Created by renxinwei on 13-5-5.
//  Copyright (c) 2013年 renxinwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommentCell.h"
#import "XWCTView.h"
#import "NTStatus.h"
#import <FacebookSDK/FacebookSDK.h>
#import "QiuShiImageViewController.h"

#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "TTTAttributedLabel.h"
#import "DBFBProfilePictureView.h"
#import <QuartzCore/QuartzCore.h>

/**
 * @brief 评论cell
 */
@protocol CommentCellDelegate <NSObject>

@optional
- (void)OpenURL:(NSURL *)url;

@end

@interface CommentCell : UITableViewCell <XWCTViewDelegate,TTTAttributedLabelDelegate>
@property (assign, nonatomic) id<CommentCellDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIImageView *pictureView;
@property (weak, nonatomic) IBOutlet UIButton *thumb;
@property (strong, nonatomic) TTTAttributedLabel *message;
@property (weak, nonatomic) IBOutlet UIButton *authorName;
@property (weak, nonatomic) IBOutlet UILabel *floorLabel;
@property (weak, nonatomic) IBOutlet UILabel *like_count;
@property (weak, nonatomic) IBOutlet UILabel *created_time;
@property(strong) IBOutlet DBFBProfilePictureView* facebookPictureView;
@property (weak,nonatomic) NTStatus * status;

- (void)refreshCell;
@end
