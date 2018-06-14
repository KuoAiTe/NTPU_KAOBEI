//
//  KaoBeiDetailController.h
//  NTPU_KAT
//
//  Created by KuoAiTe on 2014/5/29.
//  Copyright (c) 2014年 KuoAiTe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArticleObject.h"
#import <sqlite3.h>
#import "NTStatus.h"
#import "NTStatusTableViewCell.h"
#import "WebViewController.h"
#import "AppDelegate.h"
#import "UIImageView+WebCache.h"
#import "QiuShiImageViewController.h"
#import "ASIHTTPRequest.h"
#import "JSONKit.h"
#import "ArticleCell.h"
#import "CommentCell.h"
#import "LoadingCell.h"
@protocol KaoBeiDetailDelegate <NSObject>

@optional
- (void)UPDATE;

@end


@interface KaoBeiDetailController : UIViewController <UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,UIGestureRecognizerDelegate,UIWebViewDelegate,NTStatusCellDelegate,ArticleCellDelegate,CommentCellDelegate>{
    NSInteger   count;
    UIView* keyboardView;
    UITableView *_fbview;
    UITextView* post;
    //讚數
    UIButton *btn_comment;
    bool isLogin;
    NSMutableDictionary* params ;
    NSMutableArray* Cresult;//CommentResult
    NSMutableArray* CommentArray;//CommentDictionary
    NSMutableArray *_status;//Cell資訊
    sqlite3 *db;
    UIView* loadingView;
    float KeyboardHeight;
    UILabel *lblLoading;
    UIViewController *nvctrl;
    int CurrentCommentNo;
    NSString *AfterPos;
    CGRect BTextFrame;
    
}

@property (assign, nonatomic) id<KaoBeiDetailDelegate> delegate;
@property (nonatomic,weak) ArticleObject *data;
@end

