//
//  RootController.h
//  NTPU_KAT
//
//  Created by KuoAiTe on 2014/7/5.
//  Copyright (c) 2014年 KuoAiTe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <sqlite3.h>
#import "RESideMenu.h"

#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
@interface RootController : UINavigationController{
    sqlite3 *db;
}

@property (strong, readonly, nonatomic) RESideMenu *sideMenu;
@end
