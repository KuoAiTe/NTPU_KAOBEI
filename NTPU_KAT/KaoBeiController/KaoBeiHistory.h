//
//  KaoBeiHistory.h
//  NTPU_KAT
//
//  Created by KuoAiTe on 2014/6/2.
//  Copyright (c) 2014年 KuoAiTe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
@interface KaoBeiHistory : UIViewController <UITableViewDataSource,UITableViewDelegate>{
    NSMutableArray *HistoryData;
    UITableView *_tableView;
    sqlite3 *db;
}
@end
