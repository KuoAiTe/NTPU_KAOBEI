//
//  CommentCell.m
//  XWQSBK
//
//  Created by renxinwei on 13-5-5.
//  Copyright (c) 2013年 renxinwei. All rights reserved.
//

#import "CommentCell.h"
@implementation CommentCell

- (void)awakeFromNib {
    //hide the view when the download starts
    self.facebookPictureView.startHandler = ^(DBFBProfilePictureView* view){
        view.layer.opacity = 0.0f;
    };
    //show the view when the download completes, or show the empty image
    self.facebookPictureView.completionHandler = ^(DBFBProfilePictureView* view, NSError* error){
        if(error) {
            view.showEmptyImage = YES;
            view.profileID = nil;
            //NSLog(@"Loading profile picture failed with error: %@", error);
        }
        [UIView animateWithDuration:0.8f animations:^{
            view.layer.opacity = 1.0f;
        }];
    };
     
    [DBFBProfilePictureView enableDiskCache:YES lifetime:500];
    
    self.selectionStyle=UITableViewCellSeparatorStyleNone;

    
    if ([self respondsToSelector:@selector(setLayoutMargins:)]) {
        [self setLayoutMargins:UIEdgeInsetsZero];
    }
    [_thumb setImage:[UIImage imageNamed:@"like-1.png"] forState:UIControlStateSelected];
    _thumb.frame = CGRectMake(DeviceWidth - 35 , 30 , 25, 25);
    _thumb.hidden=!FBSession.activeSession.isOpen;
    _thumb.layer.borderColor = [RGB(204, 204, 204) CGColor];
    _thumb.layer.borderWidth = 1;
    // message
    _message = [[TTTAttributedLabel alloc] init];
    _message.frame=CGRectMake(15,75,DeviceWidth - 30,1);
    _message.font = [UIFont systemFontOfSize:12];
    _message.textColor = [UIColor darkGrayColor];
    _message.lineBreakMode = NSLineBreakByWordWrapping;
    _message.numberOfLines = 0;
    _message.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    // Automatically detect links when the label text is subsequently changed
    _message.delegate = self;
    [self addSubview:_message];
    
}
- (IBAction)OpenURL:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(OpenURL:)]) {
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://fb.com/%@",_status.Id]];
        [_delegate OpenURL:URL];
    }
}
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    [self OpenURL:url];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}
-(void)refreshCell{
    CGFloat avatarX = 15;
    if([_status.isReply isEqualToString:@"YES"]){
        avatarX+=20;
        self.separatorInset = UIEdgeInsetsMake(0, 10000, 0, 0);
    }else if( [_status.isReply isEqualToString:@"LastReply"]){
        avatarX+=20;
        self.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }else{
        if([_status.isReply isEqualToString:@"FirstReply"] ){
            self.separatorInset = UIEdgeInsetsMake(0, 10000, 0, 0);
        }else{
            self.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        }
    }
    _facebookPictureView.profileID = _status.Id;
    _facebookPictureView.frame = CGRectMake(avatarX, 10, 45, 45);
    //名字
    
    [_authorName setTitle:_status.userName forState:UIControlStateNormal];
    [_authorName sizeToFit];
    _authorName.frame = CGRectMake(50 + avatarX, 3, MIN(_authorName.frame.size.width,DeviceWidth-100 -avatarX), 25);
    
    _floorLabel.text = _status.replyNo;
    _floorLabel.frame = CGRectMake(DeviceWidth-50, 10, 40, 10);
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior: NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
    NSString *numberString = [numberFormatter stringFromNumber: [NSNumber numberWithInteger: _status.like_count]];
    _like_count.text = [NSString stringWithFormat:@"%@ likes", numberString];
    _like_count.frame = CGRectMake(50 + avatarX, 25, DeviceWidth - 120, 20);
    
    
    // ---
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSDate *userPostDate = [dateFormatter dateFromString:_status.createAt];
    _created_time.text = [self retrivePostTime:userPostDate];
    _created_time.frame = CGRectMake(50 + avatarX, 40, DeviceWidth - 120, 20);
    
    [_thumb setSelected:_status.user_likes];
    if( _status.message.length > 0){
        
        [_message setText:_status.message];
        if([_status.message_tags count ] > 0){
            for (NSDictionary *tag in _status.message_tags) {
                NSUInteger loc = [[tag objectForKey:@"offset"] integerValue];
                NSUInteger length = [[tag objectForKey:@"length"] integerValue];
                NSString *object_id = [tag objectForKey:@"id"];
                NSRange range = NSMakeRange(loc,length);
                // Embedding a custom link in a substring
                [_message addTagToURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://fb.com/%@",object_id]] withRange:range];
                }
        }
        int message_width = DeviceWidth - 20 - avatarX;
        _message.frame=CGRectMake(avatarX,65,message_width,1);
        [_message sizeToFit];
    }else{
        [_message setText:@""];
        [_message sizeToFit];
    }
    
    _pictureView.image = nil;
    
    if(_status.imageURL.length > 0)
    {
        _pictureView.hidden = NO;
        int display_image_width = 290;
        if( _status.image_width > 0 && _status.image_height > 0 ){
            float image_height = (float)_status.image_height/_status.image_width * display_image_width;
            [_pictureView setFrame:CGRectMake(15, CGRectGetMaxY(_message.frame) + 10, display_image_width, image_height)];
        }
        [_pictureView setImageWithURL:[NSURL URLWithString:_status.imageURL] placeholderImage:[UIImage imageNamed:@"loading.jpeg"]  options:SDWebImageDelayPlaceholder progress:^(NSInteger receivedSize,NSInteger expectedSized){
        } completed:^(UIImage *image,NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
            [_pictureView addGestureRecognizer:tap];
        } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }else{
        _pictureView.hidden = YES;
        [_pictureView setNeedsDisplay];
    }

}
#pragma mark - Public methods

- (void)handleSingleTap:(UITapGestureRecognizer *)sender
{
    UIImage * image = ((UIImageView*)sender.view).image;
    QiuShiImageViewController *qiushiImageVC = [[QiuShiImageViewController alloc] initWithNibName:@"QiuShiImageViewController" bundle:nil];
    [qiushiImageVC setQiuShiImage:image];
    qiushiImageVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.window.rootViewController presentViewController:qiushiImageVC animated:YES completion:nil];
}

- (IBAction)thumbup:(id)sender {
    [_thumb setSelected:!_thumb.selected];
    bool flag = _thumb.selected;
    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"/%@/likes",_status.comment_id]
                                 parameters:nil
                                 HTTPMethod:(flag)?@"POST":@"DELETE"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              if(error==nil){
                                  if([result objectForKey:@"success"] && flag){
                                      _status.user_likes = TRUE;
                                      _status.like_count += 1;
                                      NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
                                      [numberFormatter setFormatterBehavior: NSNumberFormatterBehavior10_4];
                                      [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
                                      NSString *numberString = [numberFormatter stringFromNumber: [NSNumber numberWithInteger: _status.like_count]];
                                      _like_count.text = [NSString stringWithFormat:@"%@ likes", numberString];
                                  }else if([result objectForKey:@"success"] && !flag){
                                      _status.user_likes = FALSE;
                                      _status.like_count -=1;
                                      NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
                                      [numberFormatter setFormatterBehavior: NSNumberFormatterBehavior10_4];
                                      [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
                                      NSString *numberString = [numberFormatter stringFromNumber: [NSNumber numberWithInteger: _status.like_count]];
                                      _like_count.text = [NSString stringWithFormat:@"%@ likes", numberString];
                                      
                                  }
                              }
                          }];

}

#pragma mark 時間與Facebook時間轉換
-(NSString*)retrivePostTime:(NSDate*)userPostDate {
    NSDate *currentDate = [NSDate date];
    NSTimeInterval distanceBetweenDates = [currentDate timeIntervalSinceDate:userPostDate];
    
    NSTimeInterval theTimeInterval = distanceBetweenDates;
    
    // Get the system calendar
    NSCalendar *sysCalendar = [NSCalendar currentCalendar];
    
    // Create the NSDates
    NSDate *date1 = [[NSDate alloc] init];
    NSDate *date2 = [[NSDate alloc] initWithTimeInterval:theTimeInterval sinceDate:date1];
    
    // Get conversion to months, days, hours, minutes
    unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSSecondCalendarUnit;
    
    NSDateComponents *conversionInfo = [sysCalendar components:unitFlags fromDate:date1  toDate:date2  options:0];
    
    NSString *returnDate;
    if ([conversionInfo month] > 0) {
        returnDate = [NSString stringWithFormat:@"%ld 個月以前",(long)[conversionInfo month]];
    }else if ([conversionInfo day] > 0){
        returnDate = [NSString stringWithFormat:@"%ld 天以前",(long)[conversionInfo day]];
    }else if ([conversionInfo hour]>0){
        returnDate = [NSString stringWithFormat:@"%ld 小時以前",(long)[conversionInfo hour]];
    }else if ([conversionInfo minute]>0){
        returnDate = [NSString stringWithFormat:@"%ld 分鐘以前",(long)[conversionInfo minute]];
    }else{
        returnDate = [NSString stringWithFormat:@"%ld 秒以前",(long)[conversionInfo second]];
    }
    return returnDate;
}


@end
