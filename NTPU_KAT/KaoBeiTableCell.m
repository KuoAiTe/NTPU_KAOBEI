//
//  UMTableViewCell.m
//  SWTableViewCell
//
//  Created by Matt Bowman on 12/2/13.
//  Copyright (c) 2013 Chris Wendel. All rights reserved.
//

#import "KaoBeiTableCell.h"

@implementation KaoBeiTableCell
- (void)awakeFromNib{
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
    
    if ([self respondsToSelector:@selector(setLayoutMargins:)]) {
        [self setLayoutMargins:UIEdgeInsetsZero];
    }
    
    self.Title = [[UILabel alloc] initWithFrame:CGRectMake(20,15,DeviceWidth - 40,100)];
    self.Title.numberOfLines=4;
    self.Title.font = [UIFont systemFontOfSize:13];
    self.Title.textColor = [UIColor darkGrayColor];
    // 回應數量
    _Like = [[UILabel alloc] initWithFrame:CGRectMake(10,CGRectGetMaxY(_Title.frame) + 5,DeviceWidth - 10,20)];
    _Like.numberOfLines=1;
    _Like.textAlignment=NSTextAlignmentLeft;
    _Like.font = [UIFont systemFontOfSize:13];
    [self addSubview:_Like];
    // 創建時間
    _created_time =[[UILabel alloc] initWithFrame:CGRectMake(0,CGRectGetMaxY(_Title.frame) + 5,DeviceWidth - 10,20)];
    _created_time.numberOfLines=1;
    _created_time.textAlignment=NSTextAlignmentRight;
    _created_time.font = [UIFont systemFontOfSize:13];
    _created_time.textColor=RGB(0,122,255);
    [self addSubview:_created_time];
    
    
    // 我的最愛
    self.Favorite = [[UIImageView alloc ]initWithImage:[UIImage imageNamed:@"favorite-2.png"]];
    self.Favorite.frame=CGRectMake(DeviceWidth - 25, 10, 17, 17);
    [self addSubview:self.Favorite];
    [self addSubview:self.Title];
}
-(void)setStatus:(ArticleObject *)Article{

    _Title.text = Article.shortmessage;
    CGSize a = [Article.shortmessage boundingRectWithSize:CGSizeMake(DeviceWidth - 40, 65)
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:13]} context:nil].size;
    
    _Title.frame = CGRectMake( 10,10, a.width,a.height);
    _Like.frame =CGRectMake(10,CGRectGetMaxY(_Title.frame) + 5,DeviceWidth - 10,20);
    _created_time.frame =CGRectMake(0,CGRectGetMaxY(_Title.frame) + 5,DeviceWidth - 15,20);
    uint LikeCount = (uint)Article.like_count;
    uint CommentCount = (uint)Article.comment_count;
    
    if(LikeCount < 30 ){
        _Like.text = [NSString stringWithFormat:@"%u likes / %u replies",LikeCount,CommentCount];
        _Like.textColor = RGB(160,160,160);
    }else if(LikeCount >= 30 && LikeCount < 100){
        _Like.text = [NSString stringWithFormat:@"%u likes / %u replies",LikeCount,CommentCount];
        _Like.textColor = RGB(3,155,155);
    }else if(LikeCount >= 100 && LikeCount < 200){
        _Like.text = [NSString stringWithFormat:@"%u likes / %u replies",LikeCount,CommentCount];
        _Like.textColor = RGB(255,0,0);
    }else if(LikeCount >= 200 && LikeCount < 300){
        _Like.text = [NSString stringWithFormat:@"爆 / %u replies",CommentCount];
        _Like.textColor = RGB(3, 166, 14);
    }else if(LikeCount >= 300 && LikeCount < 1000){
        _Like.text = [NSString stringWithFormat:@"爆 / %u replies",CommentCount];
        _Like.textColor = RGB(255,0,255);
    }else if(LikeCount >= 1000 ){
        _Like.text = [NSString stringWithFormat:@"爆 / %u replies",CommentCount];
        _Like.textColor = RGB(12,35,155);
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    _created_time.text = [self retrivePostTime:Article.created_time];
    //statement 將存放查詢結果
    sqlite3_stmt *statement =nil;
    NSString *querySQL = @"SELECT 1 FROM Favorite WHERE POST_ID = ?; ";
    if (sqlite3_prepare_v2(db, [querySQL UTF8String], -1, &statement, NULL) == SQLITE_OK) {
        sqlite3_bind_text(statement, 1, [Article.object_ID UTF8String], -1, SQLITE_TRANSIENT);
        if (sqlite3_step(statement) == SQLITE_ROW) {
            [_Favorite setHidden:NO];
        }else{
            [_Favorite setHidden:YES];
        }
        //使用完畢後將statement清空
        sqlite3_finalize(statement);
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
