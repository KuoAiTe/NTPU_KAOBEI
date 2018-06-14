//
//  KaoBeiHistory.h
//  NTPU_KAT
//
//  Created by KuoAiTe on 2014/6/2.
//  Copyright (c) 2014年 KuoAiTe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
@interface KaoBeiSearch : UIViewController <UITableViewDataSource,UITableViewDelegate>{
    UIView* loadingView;
    NSString *SearchUrl;
    NSString *SearchTitle;
    NSMutableArray *SearchResult;
    UITableView *_tableView;
    NSMutableData *receivedData;
}
-(void)StartWithURL:(NSString *)post_url AndTitle:(NSString *)title ;
@end
