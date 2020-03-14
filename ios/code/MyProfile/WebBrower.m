//
//  CloudManage.m
//  discolor-led
//
//  Created by Han.zh on 15/2/7.
//  Copyright (c) 2015年 Han.zhihong. All rights reserved.
//

#import "WebBrower.h"
#import <QuartzCore/QuartzCore.h> 

@interface WebBrower ()<UIWebViewDelegate>
{
    __weak IBOutlet UIWebView *web;
    __weak IBOutlet UIActivityIndicatorView *indLoading;
    __weak IBOutlet UIView *viConnectFail;
}

-(void) loadWeb:(NSString*)url_str :(NSString*)bodyShare;

@end

@implementation WebBrower

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.main_url=@"";
    self.body_parm=@"";
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

////////////////////////////////////////////////////
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化
    [indLoading setBounds:CGRectMake(0, 0, 130, 130)];
    [indLoading setBackgroundColor:[UIColor grayColor]];
    indLoading.alpha=0.75f;
    indLoading.layer.cornerRadius = 10;//设置那个圆角的有多圆
    indLoading.layer.borderWidth = 0;//设置边框的宽度
    [indLoading setHidden:YES];
    
    [web setOpaque:NO];//opaque是不透明的意思
    [web setScalesPageToFit:YES];//自动缩放以适应屏幕
    [self loadWeb:self.main_url :self.body_parm];
    
    viConnectFail.alpha=0;
    viConnectFail.hidden=YES;
}

-(void)dealloc
{
    //[super dealloc];
    [web stopLoading];
    web.delegate=nil;
}

-(void) loadWeb:(NSString*)url_str :(NSString*)bodyShare
{
    if (0==strncmp([url_str UTF8String], "http", 4))
    {
        NSMutableURLRequest * requestShare = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url_str]];
        [requestShare setHTTPMethod: @"POST"];
        [requestShare setHTTPBody: [bodyShare dataUsingEncoding: NSUTF8StringEncoding]];
        [web loadRequest:requestShare];
    }
    else
    { [web loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:url_str]]]; }
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString*s=[[request URL] absoluteString];
    NSLog(@"%@",s);
    return TRUE;
}

//开始加载数据
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"web start load");
    viConnectFail.alpha=0;
    viConnectFail.hidden=YES;
    [indLoading startAnimating];
    [indLoading setHidden:NO];
}
//数据加载完
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"web finish load");
    [indLoading stopAnimating];
    [indLoading setHidden:YES];
    
    [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '200%'"];//修改百分比即可
}

//加载失败
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    //出现刷新按钮
    viConnectFail.alpha=1;
    viConnectFail.hidden=NO;
    [indLoading stopAnimating];
    [indLoading setHidden:YES];
}



@end
