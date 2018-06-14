//
//  KaoBei_Controller.m
//  NTPU_KAT
//
//  Created by KuoAiTe on 2014/5/28.
//  Copyright (c) 2014年 KuoAiTe. All rights reserved.
//

#import "KaoBei_Controller.h"
#import "KaoBeiDetailController.h"
#import <FacebookSDK/FacebookSDK.h>

@interface KaoBei_Controller ()

@end

@implementation KaoBei_Controller

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"First", @"First");
        //self.tabBarItem.image = [UIImage imageNamed:@"first"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    
    CGRect rect = [[UIScreen mainScreen] applicationFrame];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 60, 320, rect.size.height - 48) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.pullDelegate = self;
    _tableView.canPullDown = YES;
    _tableView.canPullUp = YES;
    [self.view addSubview:_tableView];
    NavBar.topItem.title=@"文章列表";
    NavCtrl=self.navigationController;
    
    count = 15;
    /* make the API call */
    [FBRequestConnection startWithGraphPath:@"/NTPUcrash/posts/?limit=15"
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              /* handle the result */
                              Result = (NSArray *)[result data];
                              //NSLog(@"first:%@",[result objectForKey:@"paging"]);
                              Next = [[[[result objectForKey:@"paging"] objectForKey:@"next"] componentsSeparatedByString:@"until=" ]objectAtIndex:1];
                              [_tableView reloadData];
                          }];
    
    }

#pragma mark -
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = [indexPath row];
    static NSString *indentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSDictionary* Post_Data = [Result objectAtIndex:row];
    NSString* Post_Title = [Post_Data objectForKey:@"message"];
    Post_Title = [NSString stringWithFormat:@"%@ - %@",[Post_Title componentsSeparatedByString:@"\n"][0],[Post_Title componentsSeparatedByString:@"\n"][2]];
    //NSDictionary* Post_Message = [Result valueForKey:@"message"];
    //NSLog(@"%@",Post_Message);
    // NSLog(@"我是%@",Post_Message);
    if([Post_Title isEqualToString:@"(null) - (null)"])
        cell.textLabel.text = @"Loading...........";
    else
        cell.textLabel.text = Post_Title;
    
    return cell;
}


#pragma mark UIScrollView PullDelegate

- (void)scrollView:(UIScrollView*)scrollView loadWithState:(LoadState)state {
    if (state == PullDownLoadState) {
        [self performSelector:@selector(PullDownLoadEnd) withObject:nil afterDelay:3];
    }
    else {
        [self performSelector:@selector(PullUpLoadEnd) withObject:nil afterDelay:3];
    }
}

- (void)PullDownLoadEnd {
    count = 15;
    _tableView.canPullUp = YES;
    [_tableView reloadData];
    [_tableView stopLoadWithState:PullDownLoadState];
}

- (void)PullUpLoadEnd { 
    NSString *NextGraph=[NSString stringWithFormat:@"/NTPUcrash/posts/?limit=10&until=%@",Next];
    NSLog(@"Result:%@",NextGraph);
    [FBRequestConnection startWithGraphPath:NextGraph
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              /* handle the result */
                              count += 10;
                              [Result addObjectsFromArray:(NSArray *)[result data]];
                              NSLog(@"%@",Result);
                              Next = [[[[result objectForKey:@"paging"] objectForKey:@"next"] componentsSeparatedByString:@"until=" ]objectAtIndex:1];
                              //NSLog(@"%@",[result objectForKey:@"paging"]);
                              //NSArray* a = [(NSArray*)[result data] initWithArray:Result copyItems:YES];
                              //NSLog(@"okk3");
                              //NSLog(@"%@",a);
                              //NSArray *ab= Result initWithArray:Result;
                          }];
    if ([Next isEqualToString:@"1"]) {
        _tableView.canPullUp = NO;
    }
    
    [_tableView reloadData];
    [_tableView stopLoadWithState:PullUpLoadState];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    KaoBeiDetailController *detailView = [[KaoBeiDetailController alloc] init];

    //[detailView setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    //[self presentModalViewController:detailView animated:YES];
    //[self presentViewController:<#(UIViewController *)#> animated:<#(BOOL)#> completion:<#^(void)completion#>]
    [NavCtrl pushViewController:detailView animated:YES];
    NSLog(@"讓我進去！");
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
