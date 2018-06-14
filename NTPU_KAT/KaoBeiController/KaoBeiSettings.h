//
//  KaoBeiSettings.h
//  NTPU_KAT
//
//  Created by KuoAiTe on 2014/8/23.
//  Copyright (c) 2014年 KuoAiTe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
@interface KaoBeiSettings : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>{
    sqlite3 *db;
}

@end
