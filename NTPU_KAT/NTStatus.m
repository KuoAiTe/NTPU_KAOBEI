//
//  NTStatus.m
//  TableView
//
//  Created by MD101 on 14-10-10.
//  Copyright (c) 2014年 NT. All rights reserved.
//

#import "NTStatus.h"

@implementation NTStatus

- (NTStatus *)initWithDictionary:(NSDictionary *)dic{

    if (self  = [super init]) {
        self.isReply = [dic[@"isReply"] copy];
        self.replyNo = [dic[@"REPLY_NO"] copy];
        self.Id = [dic[@"id"] copy];
        self.comment_id = [dic[@"comment_id"] copy];
        self.userName = [dic[@"name"] copy];
        self.createAt = [dic[@"created_time"] copy];
        self.message = [dic[@"message"] copy];
        self.like_count = [[dic[@"like_count"]copy] integerValue];
        self.message_tags = [dic[@"message_tags"] copy];
        self.attachments = [dic[@"attachments"] copy];
        id media = [dic objectForKey:@"attachment"];
        if([media objectForKey:@"type"]  && [[media objectForKey:@"type"] isEqualToString:@"photo"]){
            media = [[media objectForKey:@"media"]objectForKey:@"image"];
            _imageURL = [media objectForKey:@"src"];
            _image_height = (int)[[media objectForKey:@"height"] integerValue];
            _image_width = (int)[[media objectForKey:@"width"] integerValue];
        }
        CGFloat avatarX=15;
        if([self.isReply isEqualToString:@"YES"] || [self.isReply isEqualToString:@"LastReply"]){
            avatarX+=20;
        }
        CGFloat height = 75;
        CGSize sizeOfText = [self.message boundingRectWithSize: CGSizeMake( DeviceWidth - 20 - avatarX,CGFLOAT_MAX)
                                                          options: (NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                       attributes: [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:12]
                                                                                               forKey:NSFontAttributeName]
                                                          context: nil].size;
        
        height += ceil(sizeOfText.height);
        if(self.imageURL.length)
        {
            int display_image_width = 290;
            float image_height = (float)self.image_height/self.image_width * display_image_width;
            
            //NSLog(@"init-1 url:%@ %d/%d 最後高度:%f",self.imageURL,self.image_height,self.image_width,height);
            height+=image_height + 10;
            //NSLog(@"init-2 url:%@ %d/%d 最後高度:%f",self.imageURL,self.image_height,self.image_width,height);
        }
        self.height = height;
    }
    return self;

}


+(NTStatus *)statusWithDictionary:(NSDictionary *)dic{

    NTStatus * status = [[NTStatus alloc]initWithDictionary:dic];
    
    return status;

}

@end
