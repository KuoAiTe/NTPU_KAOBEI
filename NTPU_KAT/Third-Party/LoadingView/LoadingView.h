//
//  LoadingView.h
//  NTPU_KAT
//
//  Created by KuoAiTe on 2014/11/16.
//  Copyright (c) 2014年 KuoAiTe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingView : UIView{
    UIView *loadingView;
    UILabel *lblLoading;
}
-(void)show;
-(void)hide;
@end
