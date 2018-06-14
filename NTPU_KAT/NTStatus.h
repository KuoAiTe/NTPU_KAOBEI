//
//  NTStatus.h
//  TableView
//
//  Created by MD101 on 14-10-10.
//  Copyright (c) 2014年 NT. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NTStatus : NSObject
#pragma mark - 属性
@property (nonatomic ,copy) NSString * Id;//用戶ID

@property (nonatomic ,copy) NSString * comment_id;//評論ID

@property (nonatomic ,copy) NSString * userName;//用戶名字

@property (nonatomic ,copy) NSString * replyNo;//回應編號

@property (nonatomic ,copy) NSString * createAt;//發文時間

@property (nonatomic ,copy) NSString * message;//訊息內容

@property (nonatomic , copy)  NSString *isReply;//是否是回應

@property (nonatomic , copy)  NSString *imageURL;

@property (nonatomic , copy)  NSArray *message_tags;

@property (nonatomic , copy)  NSDictionary *attachments;

@property (nonatomic , assign) int image_width;

@property (nonatomic , assign) int image_height;

@property (nonatomic , assign) NSInteger like_count;

@property (nonatomic , assign) bool user_likes;


@property (nonatomic , assign) CGFloat height;

#pragma mark - 方法
#pragma mark 根据字典初始化微博对象
- (NTStatus * )initWithDictionary:(NSDictionary *)dic;

#pragma mark 初始化微博对象（静态方法）
+ (NTStatus *)statusWithDictionary:(NSDictionary *)dic;

@end
