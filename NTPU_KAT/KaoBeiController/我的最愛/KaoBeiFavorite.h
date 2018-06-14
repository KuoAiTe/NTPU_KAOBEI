//
//  KaoBeiFavorite.m
//  NTPU_KAT
//
//  Created by KuoAiTe on 2014/6/2.
//  Copyright (c) 2014年 KuoAiTe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
@interface KaoBeiFavorite : UIViewController <UITableViewDataSource,UITableViewDelegate>{
    NSMutableArray *FavoriteResult;
    UITableView *_tableView;
    sqlite3 *db;
}
@end
