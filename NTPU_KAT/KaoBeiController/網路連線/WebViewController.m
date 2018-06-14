//
//  WebViewController.m
//  NTPU_KAT
//
//  Created by KuoAiTe on 2014/11/17.
//  Copyright (c) 2014年 KuoAiTe. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}
-(void)startWithURL:(NSURL *)URL{
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:URL];
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0,DeviceWidth,DeviceHeight-TabBarHeight)];
    webView.delegate=self;
    webView.scalesPageToFit=YES;
    [webView loadRequest:requestObj];

    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:webView];
    [self setTitle:[URL absoluteString]];
    NSLog(@"點擊:%@",URL);
}

- (void)webViewDidFinishLoad:(UIWebView *)wView{
    [self setTitle:[wView stringByEvaluatingJavaScriptFromString:@"document.title"]];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // Remove progress view
    // because UINavigationBar is shared with other ViewControllers
    self.title =@"";
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
