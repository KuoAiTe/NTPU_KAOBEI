//
//  KaoBeiController.m
//  NTPU_KAT
//
//  Created by KuoAiTe on 2014/5/29.
//  Copyright (c) 2014年 KuoAiTe. All rights reserved.
//

#import "KaoBeiController.h"
#define Reload 0
#define PullUp 2
#define Update 3
@interface KaoBeiController ()
    @property (strong, nonatomic) UISearchBar *searchBar;
@end

@implementation KaoBeiController
BOOL updating=false;

BOOL needRefresh=true;
NSInteger RowCount;
NSInteger newCellHeight=44.0f;
NSInteger currentSelection=-1;
UIAlertView *message;
BOOL isKeyboardVisible ;
NSString *Next_Token;
//NSString *Access_Token=@"access_token?client_id=511407152280214&client_secret=61621b666f55abcbdd7abcccb136d24e";
NSMutableDictionary* params ;
NSIndexPath *last_page;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)initTableView{
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view setOpaque:YES];
    // Searchbar 44 狀態欄60
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, DeviceWidth, DeviceHeight - NavHeight - StatusBarHeight  - TabBarHeight - TabBarHeight +112 )];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.pullDelegate = self;
    _tableView.canPullDown = YES;
    _tableView.canPullUp =  NO;
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, DeviceWidth, 44)];
    _searchBar.delegate = self;

    _tableView.tableHeaderView = _searchBar;
    if(![[Settings valueForKey:@"page_name"] isEqualToString:@"靠北北大"])
    {
        _tableView.tableHeaderView = nil;
    }else{
        _tableView.tableHeaderView = _searchBar;
    }
    [self setUpForDismissKeyboard];
    
    [self.view addSubview:_tableView];
    
}

-(void)initLoadingView{
    loadView = [[LoadingView alloc] initWithFrame:CGRectMake(0,0,100,100)];
    [self.view addSubview:loadView];
}
-(void)initData{
    Result = [[NSMutableArray alloc]init];
    params= [[NSMutableDictionary alloc] init];
    [params setObject:Access_Token forKey:@"access_token"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths objectAtIndex:0];
    NSString *database_path = [documents stringByAppendingPathComponent:DBNAME];
    
    if (sqlite3_open([database_path UTF8String], &db) != SQLITE_OK) {
        sqlite3_close(db);
        NSLog(@"數據打開失敗");
    }else{
        NSLog(@"OPEN Database Succeed!");
        [self execSql:@"CREATE TABLE IF NOT EXISTS KaoBeiHistory (ID INTEGER PRIMARY KEY AUTOINCREMENT ,page_name TEXT,title TEXT,body TEXT, POST_ID TEXT ,date DATETIME)"];
        [self execSql:@"CREATE TABLE IF NOT EXISTS Favorite (ID INTEGER PRIMARY KEY AUTOINCREMENT ,page_name TEXT,title TEXT,body TEXT, POST_ID TEXT ,date DATETIME)"];
    }

}
- (void)viewDidLoad
{
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // 建立 Facebook 傳遞參數
    [self initData];
    [self initTableView];
    [self initLoadingView];
    [self UpdateWithStatus:Reload];
}
-(void)UPDATE{
    [_tableView beginUpdates];
    [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:last_page ] withRowAnimation:UITableViewRowAnimationAutomatic];
    [_tableView endUpdates];
}
-(void)UpdateWithStatus:(int)status{
    if(status != Update) needRefresh = true;
    if(updating ) return;
    updating=YES;
    static int update_count = 50;
    NSString *graph_path;
    if(status == Reload ){
        [loadView show];
        _tableView.scrollEnabled=NO;
        graph_path = [NSString stringWithFormat:@"/%@/posts/?fields=id,from,message,attachments,likes.limit(1).summary(true),comments.summary(true).limit(1)&limit=%d",[Settings stringForKey:@"page_id"],update_count];
    }else{
        if(Next_Token.length == 0) return;
        graph_path = [NSString stringWithFormat:@"/%@/posts/?fields=id,from,message,attachments,likes.limit(1).summary(true),comments.summary(true).limit(1)&limit=%d&until=%@",[Settings stringForKey:@"page_id"],update_count,Next_Token];
    }
    
    NSLog(@"開始進入刷新 狀態:%d",status);
    
    NSLog(@"成功進入update %d /%d /%d %@",RowCount,[Result count],status,graph_path);
    [FBRequestConnection startWithGraphPath:graph_path
                                 parameters:params
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              NSLog(@"讀取完畢 error:%@",error);
                              NSMutableArray *data = (NSMutableArray *)[result data];
                              if(data) {
                                  if( status == Reload){
                                      //重新整理刪除所有物件
                                      [Result removeAllObjects];
                                  }
                                  NSMutableArray *indexPathSet = [[NSMutableArray alloc] init];
                                  for(unsigned int i=0; i< [data count]; i++) {
                                      NSDictionary * a = [data objectAtIndex:i];
                                      ArticleObject * row = [[ArticleObject alloc] initArticleObjectWith:a];
                                      if( [row.title length] > 0){
                                          [Result addObject:row];
                                          [indexPathSet addObject:[NSIndexPath indexPathForRow:[Result count]-1 inSection:0]];
                                      }
                                  }
                                  
                                  Next_Token = [[[[result objectForKey:@"paging"] objectForKey:@"next"] componentsSeparatedByString:@"until=" ] lastObject];
                                  [loadView hide];
                                  _tableView.scrollEnabled=YES;
                                  if(status == Reload){
                                      NSLog(@"下拉重新刷新");
                                    [_tableView reloadData];
                                  }else{
                                      NSLog(@"自動更新");
                                      [_tableView beginUpdates];
                                      [_tableView insertRowsAtIndexPaths:indexPathSet withRowAnimation:UITableViewRowAnimationNone];
                                      [_tableView endUpdates];
                                  }
                              }else{
                                  if( status != 3)
                                      [self dialogWithTitle:@"Whoops!" andMessage:@"無法讀取留言，請重新連線"];
                              }
                              [_tableView stopLoadWithState:PullDownLoadState];
                              [_tableView stopLoadWithState:PullUpLoadState];
                              if(status == Reload)
                                  [_tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
                              updating=false;
                              needRefresh=false;
                          }];
}
- (void)setUpForDismissKeyboard {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}



-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *cleanedString = [searchBar.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding ];
    NSString *url=[NSString stringWithFormat:@"http://www.ntpusu.com/NTPUKaobei/?search=%@",cleanedString];
    cleanedString = (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,(CFStringRef)cleanedString,CFSTR(""),kCFStringEncodingUTF8));
    
    KaoBeiSearch* search = [[KaoBeiSearch alloc] init];
    [search StartWithURL:url AndTitle:cleanedString];
    [self.navigationController pushViewController:search animated:YES];
    [_searchBar resignFirstResponder];
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    RowCount = [Result count];
    return RowCount;
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([Result count] - indexPath.row < 20 && !updating) {
        NSLog(@"開始自動讀取 %d/%d",RowCount,[Result count]);
        [self UpdateWithStatus:Update];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    NSInteger row = [indexPath row];
    static NSString * identifier = @"KBCell";
    cell = [_tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"KaoBeiTableCell" owner:self options:nil] lastObject];
    }
    if(row < Result.count){
        [((KaoBeiTableCell*)cell) setStatus:[Result objectAtIndex:row]];
    }
    return cell;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ArticleObject *Article = [Result objectAtIndex:indexPath.row];
    CGSize a = [Article.shortmessage boundingRectWithSize:CGSizeMake(DeviceWidth - 40, 65)
options:NSStringDrawingUsesLineFragmentOrigin
attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:13]} context:nil].size;
    return a.height + 36;
}

#pragma mark UIScrollView PullDelegate

- (void)scrollView:(UIScrollView*)scrollView loadWithState:(LoadState)state {
    if (state == PullDownLoadState) {
        [self performSelector:@selector(PullDownLoadEnd) withObject:nil afterDelay:0];
    }
    else {
        [self performSelector:@selector(PullUpLoadEnd) withObject:nil afterDelay:0];
    }
}

- (void)PullDownLoadEnd {
    NSLog(@"下拉刷新");
    [self UpdateWithStatus:Reload];
}

- (void)PullUpLoadEnd {
    NSLog(@"上拉讀取更多");
    [self UpdateWithStatus:PullUp];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(isKeyboardVisible){
        [_searchBar resignFirstResponder];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    if (indexPath != nil){
        if(indexPath.row < [Result count]){
            KaoBeiDetailController *detailView = [[KaoBeiDetailController alloc] init];
            detailView.data= [Result objectAtIndex:indexPath.row];
            detailView.delegate=self;
            last_page = indexPath;
            [self.navigationController pushViewController:detailView animated:YES];
        }
    }
    
}

- (void) dismissKeyboard
{
    // add self
    [_searchBar resignFirstResponder];
}
- (void)keyboardDidShow: (NSNotification *) notif{
    // Do something here
    isKeyboardVisible = true;
}

- (void)keyboardDidHide: (NSNotification *) notif{
    // Do something here
    isKeyboardVisible = false;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.title=[Settings valueForKey:@"page_name"];
    if([[Settings valueForKey:@"clear"] isEqualToString:@"YES"]){
        if(![[Settings valueForKey:@"page_name"] isEqualToString:@"靠北北大"])
        {
            _tableView.tableHeaderView = nil;
        }else{
            _tableView.tableHeaderView = _searchBar;
        }
        if([[Settings valueForKey:@"clear"] isEqualToString:@"YES"]){
            [Settings setObject:@"NO" forKey:@"clear"];
            [loadView show];
        }
        updating=false;
        [self UpdateWithStatus:Reload];
    }

}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    self.title=@"";
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dialogWithTitle:(NSString*)Title andMessage:(NSString*)Message{
    
    UIAlertView *message= [[UIAlertView alloc] initWithTitle:Title
                                                     message:Message
                                                    delegate:self
                                           cancelButtonTitle:@"確定"
                                           otherButtonTitles:nil, nil, nil];
    [message show];
    
    [loadView hide];
    _tableView.scrollEnabled=YES;
}
@end
