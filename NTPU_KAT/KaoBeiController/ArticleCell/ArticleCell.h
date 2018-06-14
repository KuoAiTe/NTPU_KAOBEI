//
//  ArticleCell.h
//  NTPU_KAT
//
//  Created by KuoAiTe on 2014/11/19.
//  Copyright (c) 2014年 KuoAiTe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArticleObject.h"
#import <sqlite3.h>
#import "XWCTView.h"
#import "TTTAttributedLabel.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "QiuShiImageViewController.h"
#import <FacebookSDK/FacebookSDK.h>

@protocol ArticleCellDelegate <NSObject>

@optional
- (void)OpenURL:(NSURL *)url;

@end

@interface ArticleCell : UITableViewCell <ArticleCellDelegate,XWCTViewDelegate,TTTAttributedLabelDelegate>{
    
    sqlite3 *db;
}

@property (assign, nonatomic) id<ArticleCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *author;
@property (weak, nonatomic) IBOutlet UILabel *like_count;
@property (weak, nonatomic) IBOutlet UILabel *created_time;
@property (weak, nonatomic) IBOutlet UIButton *favorite;
@property (weak, nonatomic) IBOutlet UIButton *thumb;
@property (weak, nonatomic) IBOutlet UIImageView *ImageView;

@property (weak, nonatomic) IBOutlet TTTAttributedLabel *message;
#pragma mark 資料
@property (nonatomic ,strong) ArticleObject * article;

+ (CGFloat)getCellHeight:(ArticleObject *) article;
- (void)setStatus:(ArticleObject *)article;
@end
