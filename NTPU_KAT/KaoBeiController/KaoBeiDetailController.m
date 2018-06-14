//
//  KaoBeiDetailController.m
//  NTPU_KAT
//
//  Created by KuoAiTe on 2014/5/29.
//  Copyright (c) 2014年 KuoAiTe. All rights reserved.
//

#import "KaoBeiDetailController.h"
#import <FacebookSDK/FacebookSDK.h>
@implementation KaoBeiDetailController{
    ASIHTTPRequest *_request;
    int LoadTime;
    bool updating;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

-(void)initViews{
    self.view.frame = self.view.bounds;
    //Facebook按鈕
    //留言預覽
    if(isLogin)
        _fbview = [[UITableView alloc] initWithFrame:CGRectMake(0,0,DeviceWidth,DeviceHeight -TabBarHeight - 55)];
    else
        _fbview = [[UITableView alloc] initWithFrame:CGRectMake(0,0,DeviceWidth,DeviceHeight -TabBarHeight )];
    _fbview.dataSource=self;
    _fbview.delegate=self;
    _fbview.separatorStyle=UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_fbview];
    
    if ([_fbview respondsToSelector:@selector(setSeparatorInset:)]) {
        [_fbview setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([_fbview respondsToSelector:@selector(setLayoutMargins:)]) {
        [_fbview setLayoutMargins:UIEdgeInsetsZero];
    }
    _fbview.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    [_fbview setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    // Keyboard
    if (isLogin){
        keyboardView = [[UIView alloc] initWithFrame:CGRectMake( 0,DeviceHeight - TabBarHeight - 55,DeviceWidth,55) ];
        btn_comment = [[UIButton alloc] initWithFrame:CGRectMake(255, keyboardView.frame.size.height - 43, 55, 30)];
        [btn_comment setTitle:@"發佈" forState:UIControlStateNormal];
        [btn_comment setTitleColor:[UIColor colorWithRed:150.0/256.0 green:150.0/256.0 blue:150.0/256.0 alpha:1.0] forState:UIControlStateNormal];
        [btn_comment setTitleColor:[UIColor colorWithRed:150.0/256.0 green:150.0/256.0 blue:150.0/256.0 alpha:1.0] forState:UIControlStateHighlighted];
        btn_comment.layer.borderColor = [RGB(204, 204, 204) CGColor];
        btn_comment.layer.borderWidth = 1;
        btn_comment.layer.cornerRadius = 2;
        btn_comment.layer.shadowOpacity = 0.5;
        btn_comment.layer.shadowColor = [RGBA(0,0,0,.08) CGColor];
        btn_comment.layer.shadowOffset = CGSizeMake(0.0, 1.0);
        btn_comment.layer.shadowRadius = 1;
        btn_comment.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        btn_comment.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [btn_comment addTarget:self action:@selector(comment_publish:) forControlEvents:UIControlEventTouchDown];
        
        post = [[UITextView alloc] initWithFrame:CGRectMake(10, 12, 240, 30)];
        post.text = @"留言⋯⋯";
        post.textColor = [UIColor lightGrayColor]; //optional
        post.layer.borderColor = [RGB(204, 204, 204) CGColor];
        post.layer.borderWidth = 1;
        post.layer.cornerRadius = 2;
        post.layer.shadowOpacity = 0.5;
        post.layer.shadowColor = [RGBA(0,0,0,.08) CGColor];
        post.layer.shadowOffset = CGSizeMake(0.0, 1.0);
        post.layer.shadowRadius = 1;
        post.delegate = self;
        [btn_comment setUserInteractionEnabled:NO];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0,DeviceWidth, 0.7)];
        line.backgroundColor = RGBA(0,0,0,0.15);
        [keyboardView addSubview:line];
        [keyboardView addSubview:post];
        [keyboardView addSubview:btn_comment];
        [self.view addSubview:keyboardView];
        [self keyBoardAutoSize];
    }

    
    // ------------------------------------
    
    UIButton *settingsView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [settingsView addTarget:self action:@selector(OpenFacebook) forControlEvents:UIControlEventTouchUpInside];
    [settingsView setBackgroundImage:[UIImage imageNamed:@"facebook.png"] forState:UIControlStateNormal];
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithCustomView:settingsView];
    [self.navigationItem setRightBarButtonItem:settingsButton];
    

}
-(void)initData{
    //評論相關
    LoadTime=0;
    CurrentCommentNo=0;
    //初始化高度
    _status = [[NSMutableArray alloc]init];
    isLogin = FBSession.activeSession.isOpen;
    params= [[NSMutableDictionary alloc] init];
    [params setObject:Access_Token forKey:@"access_token"];
    //設定標題
    [self setTitle:_data.title];
    [self WriteToHistory];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initData];
    NSLog(@"初始化initData完成");
    [self initViews];
    NSLog(@"初始化initViews完成");
    
    [self GetPostInfoAfter:@""];
    NSLog(@"資料抓取開始");
    if(!_data.created_time)
        [self updateArticle];
}
-(void)updateArticle{
    NSLog(@"更新文章");
    NSString *fbAccessToken = [[[FBSession activeSession] accessTokenData] accessToken];
    NSString *stringURL = [NSString stringWithFormat:@"https://api.facebook.com/method/fql.query?query=select%@likes,created_time%@from%@stream%@where%@post_id=%@%@%@&format=json&access_token=%@",@"%20",@"%20",@"%20",@"%20",@"%20",@"%27",_data.object_ID,@"%27",fbAccessToken];
    NSURL *url = [NSURL URLWithString:stringURL];
    _request = [ASIHTTPRequest requestWithURL:url];
    [_request setDelegate:self];
    [_request startAsynchronous];
    
}
- (void)requestFinished:(ASIHTTPRequest *)request{
    
    NSString *responseString = [request responseString];
    if(responseString.length > 3){
    responseString = [responseString substringWithRange:NSMakeRange(1, responseString.length-2)];
        NSDictionary *dic = [responseString objectFromJSONString];
        _data.user_likes =[[[dic objectForKey:@"likes"] objectForKey:@"user_likes"] integerValue];
        _data.like_count = [[[dic objectForKey:@"likes"] objectForKey:@"count"] integerValue];
        double time_stamp = [[dic objectForKey:@"created_time"] doubleValue] ;
        NSDate * postDate = [NSDate dateWithTimeIntervalSince1970:time_stamp];
        _data.created_time = postDate;
        // reloadTable
        
        NSLog(@"requestFinished");
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [_fbview reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }

}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 2){
        [self GetPostInfoAfter:AfterPos];
        [_fbview reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];

    }
}
- (void)requestFailed:(ASIHTTPRequest *)request

{
    
    NSError *error = [request error];
    
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

-(void)WriteToHistory{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths objectAtIndex:0];
    NSString *database_path = [documents stringByAppendingPathComponent:DBNAME];
    
    if (sqlite3_open([database_path UTF8String], &db) != SQLITE_OK) {
        sqlite3_close(db);
        NSLog(@"數據打開失敗");
    }else{
        NSLog(@"OPEN Database Succeed!");
    }
    //stm將存放查詢結果
    sqlite3_stmt *statement =nil;
    NSString *sql=@"SELECT COUNT(*) FROM KaoBeiHistory;";
    if (sqlite3_prepare_v2(db, [sql UTF8String], -1, &statement, NULL) == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_ROW) {
            int sql_count = sqlite3_column_int(statement, 0);
            if( sql_count > 100 ){
                sql=@"DELETE FROM KaoBeiHistory WHERE date = ( select min(date) from KaoBeiHistory );";
                [self execSql:sql];
                
            }
        }
        //使用完畢後將statement清空
        sqlite3_finalize(statement);
    }
    [self execSql:sql];
    
    //stm將存放查詢結果
    NSString *MyString;
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    MyString = [dateFormatter stringFromDate:now];
    const char *nsql = "INSERT INTO KaoBeiHistory (title,body,POST_ID,date,page_name) VALUES(?,?,?,?,?);";
    if (sqlite3_prepare_v2(db, nsql, -1, &statement, NULL) == SQLITE_OK) {
        sqlite3_bind_text(statement, 1, [_data.title UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 2, [_data.message UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 3, [_data.object_ID UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 4, [MyString UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_text(statement, 5, [_data.page_name   UTF8String], -1, SQLITE_TRANSIENT);
        if (sqlite3_step(statement) != SQLITE_DONE) {
            NSLog(@"SQL execution failed: %s", sqlite3_errmsg(db));
        }
        
    }
    sqlite3_finalize(statement);
}
-(void)getNewComment:(id) sender{
    if([AfterPos length] !=0){
        [self GetPostInfoAfter:AfterPos];
    }
}

-(void)GetPostInfoAfter:(NSString*)after{
    updating=true;
    //開始截取資料
    NSString *GraphPath;
    if(LoadTime ==0){
        GraphPath= [[NSString stringWithFormat:@"%@/?fields=attachments,comments.filter(toplevel){comments,attachment,created_time,from,id,user_likes,like_count,message,message_tags,comment_count}",_data.object_ID]stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
    }else{
        GraphPath= [NSString stringWithFormat:@"%@/comments?fields=comments,message,from,user_likes,like_count,attachment,message_tags,comment_count,created_time&filter=toplevel&limit(25)&after=%@",_data.object_ID,after];
    }
    //NSString *GraphPath= [NSString stringWithFormat:@"%@/comments?fields=comments,message,from,user_likes,like_count,attachment,message_tags,comment_count,created_time&filter=toplevel&limit(25)&after=%@",POST_ID,after];
    NSMutableDictionary * query_params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          Access_Token,@"access_token",
                                          nil];
    //獲取文章資料
    [FBRequestConnection startWithGraphPath:GraphPath
                                 parameters:query_params
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              if(error!=nil){
                                  [self dialogWithTitle:@"讀取留言失敗" andMessage:@"請檢查網路連線設定\r\n ErrCode: -4"];
                                  NSLog(@"Graph:%@ Error:%@",GraphPath,error);
                                  return;
                              }
                              //NSLog(@"資料:%@",result);
                              //取得留言
                              if(LoadTime==0){
                                  Cresult  = [[result objectForKey:@"comments"] objectForKey:@"data"];
                                  if(!_data.attachments)
                                      _data.attachments = [result objectForKey:@"attachments"];
                                   
                              }else{
                                  Cresult  = [result objectForKey:@"data"];
                              }
                              
                              //評論初始化
                              CommentArray = [[NSMutableArray alloc] init];
                              //NSLog(@"Load Time:%d Graph:%@ Error:%@ AFter:%@",LoadTime,GraphPath,error,AfterPos);
                              ++LoadTime;
                              for (NSDictionary*comment in Cresult) {
                                  ++CurrentCommentNo;
                                  //新增留言
                                  NSMutableDictionary *temp =  [[NSMutableDictionary alloc] init];
                                  [temp setObject:[comment objectForKey:@"id" ] forKey:@"comment_id"];
                                  [temp setObject:[[comment objectForKey:@"from"] objectForKey:@"id" ]forKey:@"id"];
                                  [temp setObject:[[comment objectForKey:@"from"] objectForKey:@"name" ]forKey:@"name"];
                                  [temp setObject:[comment objectForKey:@"message"] forKey:@"message"];
                                  [temp setObject:[comment objectForKey:@"like_count"] forKey:@"like_count"];
                                  [temp setObject:[comment objectForKey:@"user_likes"] forKey:@"user_likes"];
                                  [temp setObject:[comment objectForKey:@"created_time"] forKey:@"created_time"];
                                  [temp setObject:[NSString stringWithFormat:@"#%d",CurrentCommentNo] forKey:@"REPLY_NO"];
                                  if([comment objectForKey:@"attachment"])
                                      [temp setObject:[comment objectForKey:@"attachment"] forKey:@"attachment"];
                                  if([comment objectForKey:@"message_tags"])
                                      [temp setObject:[comment objectForKey:@"message_tags"] forKey:@"message_tags"];
                                  
                                  int replies_count = [[comment objectForKey:@"comment_count"] intValue];
                                  if (replies_count > 0) {
                                      [temp setObject:@"FirstReply" forKey:@"isReply"];
                                  }else{
                                      [temp setObject:@"NO" forKey:@"isReply"];
                                  }
                                  [CommentArray addObject:temp];
                                  //如果底下有回覆的話
                                  if (replies_count > 0) {
                                      //存入每個reply資料
                                      int i=0;
                                      id replySet= [[comment objectForKey:@"comments"] objectForKey:@"data"];
                                      for( NSDictionary *reply in replySet ){
                                          ++i;
                                          NSMutableDictionary *reply_temp =  [[NSMutableDictionary alloc] init];
                                          [reply_temp setObject:[reply objectForKey:@"id" ]forKey:@"comment_id"];
                                          [reply_temp setObject:[[reply objectForKey:@"from"] objectForKey:@"id" ]forKey:@"id"];
                                          [reply_temp setObject:[[reply objectForKey:@"from"] objectForKey:@"name" ]forKey:@"name"];
                                          [reply_temp setObject:[reply objectForKey:@"message"] forKey:@"message"];
                                          [reply_temp setObject:[reply objectForKey:@"like_count"] forKey:@"like_count"];
                                          [reply_temp setObject:[reply objectForKey:@"user_likes"] forKey:@"user_likes"];
                                          [reply_temp setObject:[reply objectForKey:@"created_time"] forKey:@"created_time"];
                                          if( i != [replySet count]){
                                              [reply_temp setObject:@"YES" forKey:@"isReply"];
                                          }else{
                                              [reply_temp setObject:@"LastReply" forKey:@"isReply"];
                                          }
                                          [reply_temp setObject:[NSString stringWithFormat:@"#%d-%d",CurrentCommentNo,i+1] forKey:@"REPLY_NO"];
                                          if([reply objectForKey:@"attachment"])
                                              [reply_temp setObject:[reply objectForKey:@"attachment"] forKey:@"attachment"];
                                          if([reply objectForKey:@"message_tags"])
                                              [reply_temp setObject:[reply objectForKey:@"message_tags"] forKey:@"message_tags"];
                
                                          [CommentArray addObject:reply_temp];
                                      }
                                  }
                              }
                              [CommentArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                  [_status addObject:[NTStatus statusWithDictionary:obj]];
                              }];
                              
                              id next;
                              if(LoadTime==1)
                                  next = [[[result objectForKey:@"comments"]objectForKey:@"paging"] objectForKey:@"next"];
                              else
                                  next = [[result objectForKey:@"paging"] objectForKey:@"next"];
                              if(next){
                                  AfterPos =[[[[next componentsSeparatedByString:@"after="] lastObject]componentsSeparatedByString:@"&"]firstObject];
                              }else{
                                  AfterPos = @"";
                              }
                              NSLog(@"即將整理全部");
                              updating=false;
                              [_fbview reloadData];
                                                        }];
}

- (void)openImageView:(UITapGestureRecognizer*) sender {
    UIImage * image = ((UIImageView*)sender.view).image;
    QiuShiImageViewController *qiushiImageVC = [[QiuShiImageViewController alloc] initWithNibName:@"QiuShiImageViewController" bundle:nil];
    [qiushiImageVC setQiuShiImage:image];
    qiushiImageVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.view.window.rootViewController presentViewController:qiushiImageVC animated:YES completion:nil];
}

-(void)comment_publish :(id)sender{
    UIButton *clicked = (UIButton *)sender;
    [clicked setUserInteractionEnabled:NO];
    NSDictionary *postparams = [NSDictionary dictionaryWithObjectsAndKeys:
                            post.text, @"message",
                            nil
                            ];
    /* make the API call */
    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"%@/comments",_data.object_ID]
                                 parameters:postparams
                                 HTTPMethod:@"POST"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              /* handle the result */
                              if(error == nil){
                                  //將留言清空
                                  post.text =@"";
                                  //++CurrentCommentNo;
                                  //新增留言
                                  /*
                                  NSMutableDictionary *temp =  [[NSMutableDictionary alloc] init];
                                  [temp setObject:[result objectForKey::@"id"] forKey:@"comment_id"];
                                  [temp setObject:[[comment objectForKey:@"from"] objectForKey:@"id" ]forKey:@"id"];
                                  [temp setObject:[[comment objectForKey:@"from"] objectForKey:@"name" ]forKey:@"name"];
                                  [temp setObject:[comment objectForKey:@"message"] forKey:@"message"];
                                  [temp setObject:[comment objectForKey:@"like_count"] forKey:@"like_count"];
                                  [temp setObject:[comment objectForKey:@"user_likes"] forKey:@"user_likes"];
                                  [temp setObject:[comment objectForKey:@"created_time"] forKey:@"created_time"];
                                  [temp setObject:[NSString stringWithFormat:@"#%d",CurrentCommentNo] forKey:@"REPLY_NO"];
                                  if([comment objectForKey:@"attachment"])
                                      [temp setObject:[comment objectForKey:@"attachment"] forKey:@"attachment"];
                                  if([comment objectForKey:@"message_tags"])
                                      [temp setObject:[comment objectForKey:@"message_tags"] forKey:@"message_tags"];
                                  
*/
                                  [self dialogWithTitle:@"發佈成功" andMessage:@"此版本不會立即顯示留言\n請重新進入頁面確認"];
                              }else{
                                  NSLog(@"error:%@",error);
                                  [self dialogWithTitle:@"發佈失敗" andMessage:@"請檢查網路連線設定\r\n ErrCode: -4"];
                              }
                              
                              [clicked setUserInteractionEnabled:YES];
                          }];
}
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"留言⋯⋯"]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
    [textView becomeFirstResponder];
}
- (void)textViewDidChange:(UITextView *)textView
{
    CGFloat fixedWidth = textView.frame.size.width;
    CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = textView.frame;
    
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height>82?82.5:newSize.height);
    textView.frame = newFrame;
    _fbview.frame = CGRectMake(0, 0 ,DeviceWidth ,DeviceHeight - KeyboardHeight - newFrame.size.height - 25);
    keyboardView.frame = CGRectMake( 0 , CGRectGetMaxY(_fbview.frame),DeviceWidth , textView.frame.size.height + 25 );
    btn_comment.frame = CGRectMake(DeviceWidth - 65, keyboardView.frame.size.height - 43, 55, 30);
    if(textView.text.length == 0 ){
        [btn_comment setTitleColor:[UIColor colorWithRed:150.0/256.0 green:150.0/256.0 blue:150.0/256.0 alpha:1.0] forState:UIControlStateNormal];
        [btn_comment setUserInteractionEnabled:NO];
    }
    else{
        [btn_comment setTitleColor:[UIColor colorWithRed:10.0/256.0 green:150.0/256.0 blue:150.0/256.0 alpha:1.0] forState:UIControlStateNormal];

        [btn_comment setUserInteractionEnabled:YES];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"留言⋯⋯";
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
}
- (void) keyBoardAutoSize
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardHide:) name:UIKeyboardWillHideNotification object:nil];
    UITapGestureRecognizer *singleTapGR =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(tapAnywhereToDismissKeyboard:)];
    singleTapGR.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:singleTapGR];
}
- (void)tapAnywhereToDismissKeyboard:(UIGestureRecognizer *)gestureRecognizer {
    [keyboardView endEditing:YES];
}
#pragma mark 鍵盤隱藏
- (void)keyBoardHide:(NSNotification *) notif
{
    NSDictionary *info = [notif userInfo];
    NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
    KeyboardHeight =keyboardSize.height;
    [UIView animateWithDuration:0.25 animations:^{
        CGRect temp = _fbview.frame;
        temp.size.height =DeviceHeight - TabBarHeight- keyboardView.frame.size.height;
        _fbview.frame  =  temp;
        keyboardView.frame = CGRectMake(0 ,CGRectGetMaxY(_fbview.frame),DeviceWidth,keyboardView.frame.size.height);
    }];
    
    
}
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    NSLog(@"did click");
    [self OpenURL:url];
}

#pragma mark 鍵盤跑出
- (void)keyBoardShow:(NSNotification *) notif
{

    NSDictionary *info = [notif userInfo];
    NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
    KeyboardHeight =keyboardSize.height;
    [UIView animateWithDuration:0.25 animations:^{
            CGRect temp = _fbview.frame;
            temp.size.height   =DeviceHeight-  KeyboardHeight -keyboardView.frame.size.height;
            _fbview.frame  =  temp;
            keyboardView.frame = CGRectMake(0 , CGRectGetMaxY(_fbview.frame) ,DeviceWidth,keyboardView.frame.size.height);
        }];

    
}
#pragma mark 刪除observer
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_request clearDelegatesAndCancel];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

#pragma mark 評論數量
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0) return 1;
    else if(section == 1) return [_status count];
    // 讀取更多留言
    else if(section == 2) return (AfterPos.length !=0 || updating);
    return 0;
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

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;

    if (indexPath.section == 0) {
        static NSString * identifier = @"AtCell";
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"ArticleCell" owner:self options:nil] firstObject];
            ((ArticleCell *)cell).message.delegate=self;
            ((ArticleCell *)cell).delegate=self;
        }
        [((ArticleCell *)cell) setStatus:self.data];
    }else if(indexPath.section == 1){
        static NSString * identifier = @"CMCell";
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"CommentCell" owner:self options:nil] lastObject];
            ((CommentCell *)cell).delegate = self;
        }
        ((CommentCell *)cell).status=_status[indexPath.row];
        [((CommentCell *)cell) refreshCell];
        
    }else if(indexPath.section == 2){
        static NSString * identifier = @"LdingCell";
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"LoadingCell" owner:self options:nil] lastObject];
            
        }
        [((LoadingCell *)cell) configure:updating];
    }
    
    return cell;
}
-(void)dialogWithTitle:(NSString*)Title andMessage:(NSString*)Message{
    
    UIAlertView *message= [[UIAlertView alloc] initWithTitle:Title
                                        message:Message
                                       delegate:self
                              cancelButtonTitle:@"確定"
                              otherButtonTitles:nil, nil, nil];
    [message show];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title =_data.title;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // Remove progress view
    // because UINavigationBar is shared with other ViewControllers
    self.title =@"";
    if (_delegate && [_delegate respondsToSelector:@selector(UPDATE)]) {
        [_delegate UPDATE];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 代理方法
#pragma mark 重新设置行高
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = 0;
    if (indexPath.section == 0) {
        height =  [ArticleCell getCellHeight:self.data];
    }
    else if (indexPath.section == 1){
        height = ((NTStatus*)_status[indexPath.row]).height ;
    }else{
        height = 44;
    }
    return height;
}

-(void)OpenFacebook{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No network connection"
                                                    message:@"You must be connected to the internet to use this app."
                                                   delegate:self
                                          cancelButtonTitle:@"使用safari"
                                          otherButtonTitles:@"內建",nil];
    [alert show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://fb.com/%@/posts/%@",[_data.object_ID componentsSeparatedByString:@"_"][0],[_data.object_ID componentsSeparatedByString:@"_"][1] ]];
    if(buttonIndex == 0){
        [[UIApplication sharedApplication] openURL:URL];
    }else if(buttonIndex == 1){
        WebViewController *webView = [[WebViewController alloc] init];
        [webView startWithURL:URL];
        [self.navigationController pushViewController:webView animated:YES];
    }
}
-(void)OpenURL:(NSURL *)URL{
    WebViewController *webView = [[WebViewController alloc] init];
    [webView startWithURL:URL];
    [self.navigationController pushViewController:webView animated:YES];
}
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange{
    WebViewController *webView = [[WebViewController alloc] init];
    [webView startWithURL:URL];
    [self.navigationController pushViewController:webView animated:YES];
    return NO;
}
@end
