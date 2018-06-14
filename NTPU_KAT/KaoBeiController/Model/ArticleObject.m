//
//  ArticleModel.m
//  ohey
//
//  Created by KuoAiTe on 2014/11/14.
//  Copyright (c) 2014年 AnonyMonkey. All rights reserved.
//

#import "ArticleObject.h"
@implementation ArticleObject

- (id)initArticleObjectWith:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        // 文章編號 Article_ID
        //self.ArticleID = [[dictionary objectForKey:@"id"] integerValue];
        // 告白內容 Article_Message
        self.page_name = [Settings stringForKey:@"page_name"];
        self.message = [dictionary objectForKey:@"message"] ;
        NSInteger rangesize = 100;
        if([self.message length] < 100)
            rangesize = [self.message length];
        self.shortmessage = [[self.message substringToIndex:rangesize] stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"];
        self.title = [self.shortmessage  stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
        self.like_count = [[[[dictionary  objectForKey:@"likes"] objectForKey:@"summary"] objectForKey:@"total_count"] intValue];
        self.comment_count = [[[[dictionary  objectForKey:@"comments"] objectForKey:@"summary"] objectForKey:@"total_count"] intValue];
        self.object_ID = [dictionary objectForKey:@"id"];
        self.POST_ID = [self.object_ID componentsSeparatedByString:@"_"][1];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        NSDate *userPostDate = [dateFormatter dateFromString:[dictionary objectForKey:@"created_time"]];
        self.attachments = [dictionary objectForKey:@"attachments"];
        self.created_time = userPostDate;
        self.user_likes = FALSE;
        //NSLog(@"%@",dictionary);
    }
    
    return self;
}
@end
