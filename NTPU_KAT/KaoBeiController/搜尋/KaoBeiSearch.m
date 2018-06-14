//
//  KaoBeiHistory.m
//  NTPU_KAT
//
//  Created by KuoAiTe on 2014/6/2.
//  Copyright (c) 2014年 KuoAiTe. All rights reserved.
//

#import "KaoBeiSearch.h"
#import "KaoBeiDetailController.h"
#import "HistoryCell.h"
#import "ArticleObject.h"

@interface KaoBeiSearch ()

@end

@implementation KaoBeiSearch
{
    UILabel* lblLoading;
    long long Dowload_Size;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initViews];
}
-(void) initViews{
    [self.view setBackgroundColor:[UIColor whiteColor]];
    //靠北北大
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, DeviceWidth, DeviceHeight - TabBarHeight) ];
    [_tableView registerNib:[UINib nibWithNibName:@"HistoryCell" bundle:nil] forCellReuseIdentifier:@"HSCell"];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    _tableView.separatorInset = UIEdgeInsetsZero;
    _tableView.layoutMargins = UIEdgeInsetsZero;
    [self.view addSubview:_tableView];
    
    loadingView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DeviceWidth, DeviceHeight)];
    loadingView.backgroundColor = [UIColor colorWithWhite:0. alpha:0.6];
    loadingView.layer.cornerRadius = 5;
    loadingView.alpha=0;
    
    UIActivityIndicatorView *activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.center = CGPointMake(loadingView.frame.size.width / 2.0, NavHeight + StatusBarHeight + BodyHeight /2 - 30);
    
    [activityView startAnimating];
    activityView.tag = 100;
    [loadingView addSubview:activityView];
    
    lblLoading = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 150, 60)];
    lblLoading.center = CGPointMake(loadingView.frame.size.width / 2.0,  NavHeight + StatusBarHeight + BodyHeight /2 + 5);
    lblLoading.text = @"讀取中\r\n 0 / 100";
    lblLoading.textColor = [UIColor whiteColor];
    lblLoading.backgroundColor = [UIColor clearColor];
    lblLoading.font = [UIFont fontWithName:lblLoading.font.fontName size:15];
    lblLoading.textAlignment = NSTextAlignmentCenter;
    lblLoading.numberOfLines = 0;
    [loadingView addSubview:lblLoading];
    [self.view addSubview:loadingView];
    [UIView animateWithDuration:0.6f animations:^{
        loadingView.alpha = 1;
    } completion:^(BOOL completed) {
    }];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(void)StartWithURL:(NSString *)post_url AndTitle:(NSString *)title {
    
    SearchResult = [[NSMutableArray alloc] init];
    SearchUrl=post_url;
    SearchTitle=title;
    [self setTitle:[NSString stringWithFormat:@"搜尋結果 - %@",SearchTitle]];
    receivedData = [[NSMutableData alloc] init];
    //NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:SearchUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:8.0f];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:SearchUrl]];
    [request setValue:@"identity" forHTTPHeaderField:@"Accept-Encoding"];
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (!theConnection) {
        receivedData = nil;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [SearchResult count];
}

- (UITableViewCell *)tableView:(HistoryCell *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    HistoryCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"HSCell" forIndexPath:indexPath];
    cell.tag=row;
    cell.textLabel.text = ((ArticleObject *)[SearchResult objectAtIndex:row]).title;
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    KaoBeiDetailController *detailView = [[KaoBeiDetailController alloc] init];
    
    detailView.data = [SearchResult objectAtIndex:row ];
    [self.navigationController pushViewController:detailView animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

#pragma mark - Connect Delegate
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"開始建立連線");
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    //Clear Buffer
    [receivedData setLength:0];
    
    int statusCode_ = (int)[httpResponse statusCode];
    if (statusCode_ == 200) {
        Dowload_Size = [response expectedContentLength];
        NSLog(@"檔案大小 :%lld",[httpResponse expectedContentLength]);
    }
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    [receivedData appendData:data];
    if ( Dowload_Size == NSURLResponseUnknownLength){
        
    }else{
        lblLoading.text = [NSString stringWithFormat:@"讀取中\r\n %d / 100",(int) ( (float)[receivedData length] / (float) Dowload_Size * 100 )];
        NSLog(@"讀取中 -  %d / 100",(int) ((float)[receivedData length]/ (float) Dowload_Size * 100 ));
    }
}
- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    // Release the connection and the data object
    // by setting the properties (declared elsewhere)
    // to nil.  Note that a real-world app usually
    // requires the delegate to manage more than one
    // connection at a time, so these lines would
    // typically be replaced by code to iterate through
    // whatever data structures you are using.
    connection = nil;
    receivedData = nil;
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"網路連接錯誤"
                                                      message:@"請檢查網路連線設定\r\n ErrCode: -1"
                                                     delegate:nil
                                            cancelButtonTitle:@"確定"
                                            otherButtonTitles:nil, nil, nil];
    [UIView animateWithDuration:0.6f animations:^{
        loadingView.alpha = 0;
    } completion:^(BOOL completed) {
        [loadingView removeFromSuperview];
    }];
    [message performSelectorOnMainThread: @selector(show) withObject: nil waitUntilDone: NO ];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    // receivedData is declared as a property elsewhere
    NSLog(@"Succeeded! Received %d bytes of data",(int)[receivedData length]);
    
    if(receivedData !=nil){
        id data = [NSJSONSerialization JSONObjectWithData:receivedData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:nil];
        
        for(int i=0;i<[data count];++i){
            ArticleObject *row = [[ArticleObject alloc] init];
            row.message = [[data objectForKey:[NSString stringWithFormat:@"%d",i+1]] objectForKey:@"message"];
            row.POST_ID = [row.message componentsSeparatedByString:@"\n"][0];
            NSInteger Post_Length = [row.message length] ;
            if(Post_Length > 30 ) Post_Length = 30;
            row.title = [row.message substringToIndex:Post_Length];
            row.title = [NSString stringWithFormat:@"%@ - %@",row.POST_ID,[[row.title substringFromIndex:(row.POST_ID.length+2)]stringByReplacingOccurrencesOfString:@"\n" withString:@" "]];
            row.object_ID = [[data objectForKey:[NSString stringWithFormat:@"%d",i+1]] objectForKey:@"object_id"];
            row.page_name = @"靠北北大";
            NSLog(@"我看看:%@",row.object_ID);
            [SearchResult addObject:row];
        }
        [_tableView reloadData];
        [UIView animateWithDuration:0.6f animations:^{
            loadingView.alpha = 0;
        } completion:^(BOOL completed) {
            [loadingView removeFromSuperview];
        }];
    }
    receivedData = nil;
}

@end
