//
//  QiuShiImageViewController.h
//  XWQSBK
//
//  Created by renxinwei on 13-5-10.
//  Copyright (c) 2013年 renxinwei's MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XWImagePreviewView.h"

/**
 * @brief 全屏显示静态图片，gif图片，拖拉放大缩小，保存图片至本地（gif会保存成静态）
 */
@interface QiuShiImageViewController : UIViewController <XWImagePreviewViewDelegate>
{
    XWImagePreviewView *_previewView;
    NSString *_qiushiImageURL;
    UIImage *_image;
}

- (void)setQiuShiImage:(UIImage *) image;

@end
