//
//  UIViewController_MenuController.h
//  NTPU_KAT
//
//  Created by KuoAiTe on 2014/10/25.
//  Copyright (c) 2014年 KuoAiTe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RESideMenu.h"

#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
@interface MenuController : UIViewController
    
@property (strong, readonly, nonatomic) RESideMenu *sideMenu;
@end
