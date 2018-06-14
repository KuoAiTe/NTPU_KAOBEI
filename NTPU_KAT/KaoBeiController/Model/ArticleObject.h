//
//  ArticleModel.h
//  ohey
//
//  Created by KuoAiTe on 2014/11/14.
//  Copyright (c) 2014年 AnonyMonkey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArticleObject : NSObject

@property (nonatomic,assign) NSInteger ArticleID;               // 評論數量      Comment_Count

@property (nonatomic,copy) NSString *title;                   // 告白內容      Article_Message
@property (nonatomic,copy) NSString *message;                   // 告白內容      Article_Message
@property (nonatomic,copy) NSString *shortmessage;              // 告白內容      Article_Message

@property (nonatomic,copy) NSString *POST_ID;
@property (nonatomic,copy) NSString *object_ID;
@property (nonatomic,copy) NSString *page_name;

@property (nonatomic,retain) NSDictionary *attachments;

@property (nonatomic,copy) NSDate *created_time;         // 發布時間      Publish_Time
@property (nonatomic,assign) NSInteger comment_count;           // 評論數量      Comment_Count
@property (nonatomic,assign) NSInteger favorite_count;          // 喜愛數量      Favorite_Count
@property (nonatomic,assign) NSInteger like_count;              // 按讚數量      Like_Count
@property (nonatomic,assign) NSInteger user_likes;
@property (nonatomic,assign) NSUInteger Message_Height;         //              Message_Height
@property (nonatomic,assign) NSUInteger Article_Height;         // 文章高度      Article_Height

- (id)initArticleObjectWith:(NSDictionary *)dictionary;

@end
