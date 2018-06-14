//
//  ArticleCell.m
//  NTPU_KAT
//
//  Created by KuoAiTe on 2014/11/19.
//  Copyright (c) 2014年 KuoAiTe. All rights reserved.
//

#import "ArticleCell.h"
#import "NTStatus.h"
#import "WebViewController.h"
@implementation ArticleCell

- (void)awakeFromNib {
    if ([self respondsToSelector:@selector(setSeparatorInset:)]) {
        [self setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // SQL
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths objectAtIndex:0];
    NSString *database_path = [documents stringByAppendingPathComponent:DBNAME];
    
    if (sqlite3_open([database_path UTF8String], &db) != SQLITE_OK) {
        sqlite3_close(db);
        NSLog(@"數據打開失敗");
    }else{
        NSLog(@"OPEN Database Succeed!");
    }

    // Initialization code
    [_author addTarget:self action:@selector(OpenURL:) forControlEvents:UIControlEventTouchUpInside];
    // message
    //_message = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
    _message.frame=CGRectMake(15,75,DeviceWidth - 30,1);
    _message.font = [UIFont systemFontOfSize:12];
    _message.textColor = [UIColor darkGrayColor];
    _message.lineBreakMode = NSLineBreakByWordWrapping;
    _message.numberOfLines = 0;
    _message.enabledTextCheckingTypes = NSTextCheckingTypeLink;
    // Automatically detect links when the label text is subsequently changed
    _message.delegate = self;
    
    [self addSubview:_message];
    
    // favorite
    _favorite.layer.borderColor = [RGB(204, 204, 204) CGColor];
    _favorite.layer.borderWidth = 1;
    _favorite.layer.cornerRadius = 2;
    _favorite.layer.shadowOpacity = 0.5;
    _favorite.layer.shadowColor = [RGBA(0,0,0,.08) CGColor];
    _favorite.layer.shadowOffset = CGSizeMake(0.0, 1.0);
    _favorite.layer.shadowRadius = 1;
    _favorite.frame = CGRectMake(DeviceWidth - 35 , 10 , 25, 25);
    [_favorite setImage:[UIImage imageNamed:@"favorite.png"] forState:UIControlStateSelected];
    [_favorite addTarget:self action:@selector(favorite_add) forControlEvents:UIControlEventTouchDown];
    
    // thumb
    _thumb.layer.borderColor = [RGB(204, 204, 204) CGColor];
    _thumb.layer.borderWidth = 1;
    _thumb.layer.cornerRadius = 2;
    _thumb.layer.shadowOpacity = 0.5;
    _thumb.layer.shadowColor = [RGBA(0,0,0,.08) CGColor];
    _thumb.layer.shadowOffset = CGSizeMake(0.0, 1.0);
    _thumb.layer.shadowRadius = 1;
    _thumb.frame = CGRectMake(DeviceWidth - 35 , 40 , 25, 25);
    [_thumb setImage:[UIImage imageNamed:@"like-1.png"] forState:UIControlStateSelected];
    
    [_thumb addTarget:self action:@selector(thumbup) forControlEvents:UIControlEventTouchDown];
    _thumb.hidden=!FBSession.activeSession.isOpen;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)OpenURL: (id) sender{
    if (_delegate && [_delegate respondsToSelector:@selector(OpenURL:)]) {
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://fb.com/%@",[_article.object_ID componentsSeparatedByString:@"_"][0]]];
        [_delegate OpenURL:URL];
    }
}
- (void)setStatus:(ArticleObject *)article{
    _article = article;
    if(_article.page_name)
        [self.author setTitle:_article.page_name forState:UIControlStateNormal];
    if( _article.like_count){
        NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setFormatterBehavior: NSNumberFormatterBehavior10_4];
        [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
        NSString *numberString = [numberFormatter stringFromNumber: [NSNumber numberWithInteger: _article.like_count]];
        _like_count.text = [NSString stringWithFormat:@"%@ likes", numberString];
    }
    if(_article.created_time){
        self.created_time.text = [self retrivePostTime:_article.created_time ];
    }
    [_thumb setSelected:_article.user_likes];
    if(_article.message){
        /*NSAttributedString *string = [[NSAttributedString alloc] initWithString:_article.message];
        int commentCTHeight = [XWCTView getAttributedStringHeightWithString:string WidthValue:DeviceWidth - 40];

        self.message.delegate = self;
        self.message.conetntString = _article.message;
        CGRect rect = self.message.frame;
        rect.size.width = DeviceWidth - 40;
        rect.size.height = commentCTHeight;
        self.message.frame = rect;*/
        
        // ---

        // Delegate methods are called when the user taps on a link (see `TTTAttributedLabelDelegate` protocol)

        [_message setText:_article.message];
        [_message sizeToFit];;
        
    }
    id imageResult = _article.attachments;
    //NSLog(@"sss:%@",imageResult);
    _ImageView.image=nil;
    if(imageResult){
        imageResult = [[imageResult objectForKey:@"data"]objectAtIndex:0];
        if(imageResult && [[imageResult objectForKey:@"type"]isEqualToString:@"photo"]) {
            imageResult = [[imageResult objectForKey:@"media"]objectForKey:@"image"];
            NSString *imageUrl = [imageResult objectForKey:@"src"];
            int height = (int)[[imageResult objectForKey:@"height"] integerValue];
            int width = (int)[[imageResult objectForKey:@"width"] integerValue];
            float image_height = (float)height/width * 290;
            
            [_ImageView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"loading.jpeg"]  options:SDWebImageDelayPlaceholder progress:^(NSInteger receivedSize,NSInteger expectedSized){
            } completed:^(UIImage *image,NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
                [_ImageView addGestureRecognizer:tap];
            } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [_ImageView setFrame:CGRectMake(15, CGRectGetMaxY(_message.frame)+ 10, 290, image_height)];

                
            
        }else if(imageResult && [[imageResult objectForKey:@"type"]isEqualToString:@"share"]) {
            imageResult = [[imageResult objectForKey:@"media"]objectForKey:@"image"];
            NSString *imageUrl = [imageResult objectForKey:@"src"];
            int height = (int)[[imageResult objectForKey:@"height"] integerValue];
            int width = (int)[[imageResult objectForKey:@"width"] integerValue];
            float image_height = (float)height/width * 290;
            
            [_ImageView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"loading.jpeg"]  options:SDWebImageDelayPlaceholder progress:^(NSInteger receivedSize,NSInteger expectedSized){
            } completed:^(UIImage *image,NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
                [_ImageView addGestureRecognizer:tap];
            } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [_ImageView setFrame:CGRectMake(15, CGRectGetMaxY(_message.frame)+ 10, 290, image_height)];
            
            
            
        }else if(imageResult && [[imageResult objectForKey:@"type"]isEqualToString:@"video_share_youtube"]) {
            imageResult = [[imageResult objectForKey:@"media"]objectForKey:@"image"];
            NSString *imageUrl = [imageResult objectForKey:@"src"];
            int height = (int)[[imageResult objectForKey:@"height"] integerValue];
            int width = (int)[[imageResult objectForKey:@"width"] integerValue];
            float image_height = (float)height/width * 290;
            
            [_ImageView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"loading.jpeg"]  options:SDWebImageDelayPlaceholder progress:^(NSInteger receivedSize,NSInteger expectedSized){
            } completed:^(UIImage *image,NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
                [_ImageView addGestureRecognizer:tap];
            } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [_ImageView setFrame:CGRectMake(15, CGRectGetMaxY(_message.frame)+ 10, 290, image_height)];
            
            
            
        }else if(imageResult && [[imageResult objectForKey:@"type"]isEqualToString:@"album"]){
            /*
            imageResult = [[imageResult objectForKey:@"subattachments"] objectForKey:@"data"];
            UIScrollView *articleAlbum=[[UIScrollView alloc]initWithFrame:CGRectMake(10,BTextFrame.origin.y+BTextFrame.size.height+10,310,180)];
            articleAlbum.showsHorizontalScrollIndicator=NO;
            articleAlbum.showsVerticalScrollIndicator=NO;
            BTextFrame = CGRectMake(15, BTextFrame.origin.y+BTextFrame.size.height+190, 0, 0);
            
            __block int x_pos=0;
            for(NSDictionary *photo in imageResult){
                if([[photo objectForKey:@"type"] isEqualToString:@"photo"]){
                    NSLog(@"photo:%@",photo);
                    UIImageView *articleImage=[[UIImageView alloc]initWithFrame:CGRectMake(0,0,200,180)];
                    NSString *imageUrl = [[[photo objectForKey:@"media"] objectForKey:@"image"] objectForKey:@"src"];
                    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                        articleImage.image = [UIImage imageWithData:data];
                        articleImage.userInteractionEnabled =YES;
                        articleImage.exclusiveTouch=YES;
                        articleImage.layer.borderColor = [RGB(0,0,0) CGColor];
                        articleImage.layer.borderWidth = 1;
                        UITapGestureRecognizer *singleTap =  [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openImageView:)];
                        singleTap.delegate=self;
                        [articleImage addGestureRecognizer:singleTap];
                        int height = (int)[[[[photo objectForKey:@"media"] objectForKey:@"image"] objectForKey:@"height"] integerValue];
                        int width = (int)[[[[photo objectForKey:@"media"] objectForKey:@"image"] objectForKey:@"width"] integerValue];
                        float image_width = (float)width/height * 180;
                        
                        [articleImage setFrame:CGRectMake(x_pos, 0, image_width, 180)];
                        
                        x_pos +=image_width;
                        articleAlbum.contentSize=CGSizeMake(x_pos, 180);
                        
                        [articleAlbum addSubview:articleImage];
                        
                    }];
                }*/
            }
            
        }
    //stm將存放查詢結果
    sqlite3_stmt *statement =nil;
    NSString *sql=[NSString stringWithFormat:@"SELECT COUNT(*) FROM Favorite WHERE POST_ID = '%@';",_article.object_ID];
    if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_ROW) {
            int sql_count = sqlite3_column_int(statement, 0);\
            if(sql_count == 0){
                [_favorite setSelected:NO];
            }else{
                [_favorite setSelected:YES];
            }
            
        }
        //使用完畢後將statement清空
        sqlite3_finalize(statement);
    }
}
- (void)handleSingleTap:(UITapGestureRecognizer *)sender
{
    UIImage * image = ((UIImageView*)sender.view).image;
    QiuShiImageViewController *qiushiImageVC = [[QiuShiImageViewController alloc] initWithNibName:@"QiuShiImageViewController" bundle:nil];
    [qiushiImageVC setQiuShiImage:image];
    qiushiImageVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.window.rootViewController presentViewController:qiushiImageVC animated:YES completion:nil];
}
- (void)thumbup{
    [_thumb setSelected:!_thumb.selected];
    bool flag = _thumb.selected;
    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"/%@/likes",_article.object_ID]
                                 parameters:nil
                                 HTTPMethod:(flag)?@"POST":@"DELETE"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              if(error==nil){
                                  if([result objectForKey:@"success"] && flag){
                                      _article.user_likes = TRUE;
                                      _article.like_count += 1;
                                      NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
                                      [numberFormatter setFormatterBehavior: NSNumberFormatterBehavior10_4];
                                      [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
                                      NSString *numberString = [numberFormatter stringFromNumber: [NSNumber numberWithInteger: _article.like_count]];
                                      _like_count.text = [NSString stringWithFormat:@"%@ likes", numberString];
                                  }else if([result objectForKey:@"success"] && !flag){
                                      _article.user_likes = FALSE;
                                      _article.like_count -=1;
                                      NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
                                      [numberFormatter setFormatterBehavior: NSNumberFormatterBehavior10_4];
                                      [numberFormatter setNumberStyle: NSNumberFormatterDecimalStyle];
                                      NSString *numberString = [numberFormatter stringFromNumber: [NSNumber numberWithInteger: _article.like_count]];
                                      _like_count.text = [NSString stringWithFormat:@"%@ likes", numberString];
                                      
                                  }
                              }
                          }];
    
}
-(void) favorite_add {
    if(!_favorite.selected){
        //stm將存放查詢結果
        sqlite3_stmt *statement =nil;
        //stm將存放查詢結果
        NSString *MyString;
        NSDate *now = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
        MyString = [dateFormatter stringFromDate:now];
        const char *nsql = "INSERT INTO Favorite (title,body,POST_ID,date,page_name) VALUES(?,?,?,?,?);";
        if (sqlite3_prepare_v2(db, nsql, -1, &statement, NULL) == SQLITE_OK) {
            sqlite3_bind_text(statement, 1, [_article.title UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 2, [_article.message UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 3, [_article.object_ID UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 4, [MyString UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 5, [_article.page_name UTF8String], -1, SQLITE_TRANSIENT);
            if (sqlite3_step(statement) != SQLITE_DONE) {
                NSLog(@"SQL execution failed: %s", sqlite3_errmsg(db));
            }
            
        }
        sqlite3_finalize(statement);
        [_favorite setSelected:YES];
    }else{
        NSString *sql=[NSString stringWithFormat:@"DELETE FROM Favorite WHERE POST_ID='%@'",_article.object_ID];
        [self execSql:sql];
        [_favorite setSelected:NO];
    }
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
    unsigned int unitFlags = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitSecond;
    
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

-(void)execSql:(NSString *)sql
{
    char *err;
    if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
        sqlite3_close(db);
        NSLog(@"失敗操作數據:%@",sql);
        NSLog(@"錯誤:%s",err);
    }else{
        NSLog(@"成功操作數據:%@",sql);
    }
}
+ (CGFloat)getCellHeight:(ArticleObject *) article
{
    CGFloat height = 90;
    if(article.message){
        CGSize sizeOfText = [article.message boundingRectWithSize: CGSizeMake( DeviceWidth-30,CGFLOAT_MAX)
                                                    options: (NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                 attributes: [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:12]
                                                                                         forKey:NSFontAttributeName]
                                                    context: nil].size;
        
        height += ceil(sizeOfText.height);
    }
    id imageResult = article.attachments;
    if(imageResult){
        imageResult = [[imageResult objectForKey:@"data"]objectAtIndex:0];
        if(imageResult && [imageResult objectForKey:@"media"]) {
            imageResult = [[imageResult objectForKey:@"media"]objectForKey:@"image"];
            int h = (int)[[imageResult objectForKey:@"height"] integerValue];
            int w = (int)[[imageResult objectForKey:@"width"] integerValue];
            float image_height = (float)h/w * 290 + 10;
            height+=image_height;
        }
    }
    return height;
}

@end
