//
//  WebViewController.h
//  NTPU_KAT
//
//  Created by KuoAiTe on 2014/11/17.
//  Copyright (c) 2014年 KuoAiTe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController<UIWebViewDelegate>

-(void)startWithURL:(NSURL *)URL;
@end
