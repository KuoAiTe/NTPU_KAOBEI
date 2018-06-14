//
//  KaoBei_Controller.h
//  NTPU_KAT
//
//  Created by KuoAiTe on 2014/5/28.
//  Copyright (c) 2014年 KuoAiTe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIScrollView+PullLoad.h"

@interface KaoBei_Controller : UIViewController <UITableViewDataSource,UITableViewDelegate,PullDelegate> {
    UITableView *_tableView;
    NSInteger   count;
    NSMutableArray* Result;
    NSString* Next;
    UINavigationController *NavCtrl;
    IBOutlet UINavigationBar *NavBar;
}


@end
