//
//  NTStatusTableViewCell.m
//  TableView
//
//  Created by MD101 on 14-10-10.
//  Copyright (c) 2014年 NT. All rights reserved.
//

#import "NTStatusTableViewCell.h"
#import "NTStatus.h"
#import <FacebookSDK/FacebookSDK.h>
#import "XWCTView.h"
#define KColor(r,g,b)  [UIColor colorWithHue:r/255.0 saturation:g/255.0 brightness:b/255.0 alpha:1]
#define kStatusTableViewCellControlSpacing 10//間距
#define kStatusTableViewCellBackgroundColor KColor(251,251,251)
#define kStatusGrayColor KColor(50,50,50)
#define kStatusLightGrayColor KColor(120,120,120)

#define kStatusTableViewCellAvatarWidth 40 //頭像寬度
#define kStatusTableViewCellAvatarHeight kStatusTableViewCellAvatarWidth
#define kStatusTableViewCellUserNameFontSize 13
#define kStatusTableViewCellCreateAtFontSize 10
#define kStatusTableViewCellSourceFontSize 12
#define kStatusTableViewCellTextFontSize 13

@interface NTStatusTableViewCell(){

    FBProfilePictureView *_avatar;//頭像
    UIButton * _userName;
    UILabel * _creatrAt;
    UILabel * _likecount;
    XWCTView * _message;
    UILabel * _replyNo;
    UIImageView *_imageView;
}

@end

@implementation NTStatusTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initSubview];
        // Initialization code
        self.layoutMargins=UIEdgeInsetsZero;
    }
    return self;
}

#pragma mark 初始化视图
- (void)initSubview{
    //頭像
    _avatar = [[FBProfilePictureView alloc]init];
    
    [self addSubview:_avatar];
    
    //用户
    _userName = [[UIButton alloc]init];
    [_userName setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    _userName.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft; 
    _userName.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0f];
    [_userName addTarget:self action:@selector(OpenURL:) forControlEvents:UIControlEventTouchDown];

    [self addSubview:_userName];
    
    //讚數
    _likecount = [[UILabel alloc]init];
    _likecount.textColor = RGB(255,0,0);
    _likecount.font = [UIFont systemFontOfSize:kStatusTableViewCellCreateAtFontSize];
    [self addSubview:_likecount];
    
    //回應編號
    _replyNo = [[UILabel alloc]init];
    _replyNo.textColor = RGB(0,122,255);
    _replyNo.font = [UIFont systemFontOfSize:kStatusTableViewCellUserNameFontSize];
    [self addSubview:_replyNo];
    
    //日期
    _creatrAt = [[UILabel alloc]init];
    _creatrAt.textColor = [UIColor lightGrayColor];
    _creatrAt.font = [UIFont systemFontOfSize:kStatusTableViewCellCreateAtFontSize];
    [self addSubview:_creatrAt];
    
    //内容
    _message = [[XWCTView alloc]init];
    _message.backgroundColor = [UIColor whiteColor];
    [self addSubview:_message];
    
    //圖片
    _imageView = [[UIImageView alloc] init];
    [self addSubview:_imageView];
}



//1）.对于单行文本数据的显示调用+ (UIFont *)systemFontOfSize:(CGFloat)fontSize;方法来得到文本宽度和高度。
//2）.对于多行文本数据的显示调用- (CGRect)boundingRectWithSize:(CGSize)size options:(NSStringDrawingOptions)options attributes:(NSDictionary *)attributes context:(NSStringDrawingContext *)context ;方法来得到文本宽度和高度；同时注意在此之前需要设置文本控件的numberOfLines属性为0。
#pragma mark 設置文章
- (void)setStatus:(NTStatus *)status{
    _status=status;
    CGFloat avatarX = 10,avatarY = 10;
    if([status.isReply isEqualToString:@"YES"] || [status.isReply isEqualToString:@"LastReply"]){
        avatarX+=20;
    }
    CGRect avatarRect = CGRectMake(avatarX, avatarY, kStatusTableViewCellAvatarWidth, kStatusTableViewCellAvatarHeight);
    if(_avatar.profileID != status.Id){
        _avatar.profileID = nil;
        _avatar.profileID = status.Id;
    }
    _avatar.frame = avatarRect;
    
    [_userName setTitle:status.userName forState:UIControlStateNormal];
    [_userName sizeToFit];
    CGFloat userNameX = CGRectGetMaxX(_avatar.frame) + kStatusTableViewCellControlSpacing;
    CGFloat userNameY = avatarY;
    CGSize userNameSize = _userName.frame.size;
    CGRect userNameRect = CGRectMake(userNameX, userNameY - 8, MIN(userNameSize.width,DeviceWidth - avatarX -90), userNameSize.height);
    _userName.frame = userNameRect;
    
    CGSize likecount = [[NSString stringWithFormat:@"%d likes",status.like_count] sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:kStatusTableViewCellCreateAtFontSize]}];
    CGFloat likeX = userNameX;
    CGFloat likeY = 26;
    CGRect likecountRect = CGRectMake(likeX, likeY, likecount.width, likecount.height);
    _likecount.text = [NSString stringWithFormat:@"%d likes",status.like_count];
    _likecount.frame = likecountRect;
    
    CGSize createAtSize = [status.createAt sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:kStatusTableViewCellCreateAtFontSize]}];
    CGFloat createAtX = userNameX;
    CGFloat createAtY = CGRectGetMaxY(_avatar.frame) - createAtSize.height + 2;
    CGRect createAtRect = CGRectMake(createAtX, createAtY, createAtSize.width, createAtSize.height);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSDate *userPostDate = [dateFormatter dateFromString:status.createAt];
    _creatrAt.text = [self retrivePostTime:userPostDate];
    _creatrAt.frame = createAtRect;
    
    CGFloat replyNoX = DeviceWidth - kStatusTableViewCellControlSpacing;
    CGFloat replyNoY = avatarY;
    CGSize replyNoSize = [status.replyNo sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:kStatusTableViewCellUserNameFontSize]}];
    CGRect replyNoRect = CGRectMake(replyNoX - replyNoSize.width, replyNoY, replyNoSize.width, replyNoSize.height);
    _replyNo.text = status.replyNo;
    _replyNo.frame = replyNoRect;


    
    CGFloat textX = avatarX;
    CGFloat textY = CGRectGetMaxY(_avatar.frame) + kStatusTableViewCellControlSpacing;
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:status.message];
    int commentCTHeight = [XWCTView getAttributedStringHeightWithString:string WidthValue:DeviceWidth - 40];
        
    _message.delegate = self;
    _message.conetntString = _status.message;
    CGRect rect = CGRectMake(textX,textY,0,0);
    rect.size.width = DeviceWidth - 40;
    rect.size.height = commentCTHeight;
    _message.frame = rect;
    
    if(status.message_tags){
            
    }
    _height = CGRectGetMaxY(_message.frame) + kStatusTableViewCellControlSpacing;
    
        if([status.isReply isEqualToString:@"NO"] || [status.isReply isEqualToString:@"LastReply"]){
        self.selectionStyle=UITableViewCellSelectionStyleDefault;
    }else{
        self.selectionStyle=UITableViewCellSelectionStyleNone;
    }
    
}




- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
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
