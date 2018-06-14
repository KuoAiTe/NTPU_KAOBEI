//
//  KaoBeiController.h
//  NTPU_KAT
//
//  Created by KuoAiTe on 2014/5/29.
//  Copyright (c) 2014年 KuoAiTe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIScrollView+PullLoad.h"
#import <sqlite3.h>
#import <FacebookSDK/FacebookSDK.h>
#import "ArticleObject.h"
#import <FacebookSDK/FacebookSDK.h>
#import "LoadingView.h"
#import "KaoBeiDetailController.h"
#import "KaoBeiTableCell.h"
#import "KaoBeiSearch.h"
#import "KaoBeiSettings.h"
@interface KaoBeiController : UIViewController
 <UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate,UIWebViewDelegate,UISearchBarDelegate,PullDelegate,KaoBeiDetailDelegate> {
    UITableView *_tableView;
    NSMutableArray* Result;
    UINavigationController *NavCtrl;
    NSInteger *UPDATE_COUNT;
    sqlite3 *db;
    BOOL searchMode;
    LoadingView *loadView;
}
@end
