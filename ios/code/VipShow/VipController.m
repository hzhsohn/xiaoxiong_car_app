//
//  CloudManage.m
//  discolor-led
//
//  Created by Han.zh on 15/2/7.
//  Copyright (c) 2015年 Han.zhihong. All rights reserved.
//

#import "VipController.h"
#import <QuartzCore/QuartzCore.h>
#import "DefineHeader.h"
#import "ProjectAccountCfg.h"
#import "WebController.h"

@interface VipController ()<UIWebViewDelegate>
{
    __weak IBOutlet UIWebView *web;
    __weak IBOutlet UIActivityIndicatorView *indLoading;
    __weak IBOutlet UIView *viConnectFail;
}

-(void) loadWeb:(NSString*)url_str;

@end

@implementation VipController

-(void)awakeFromNib
{
    [super awakeFromNib];
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
    
    //设置标题
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [UIColor whiteColor],NSForegroundColorAttributeName,
                          [UIFont systemFontOfSize:17],NSFontAttributeName,
                          nil];
    self.navigationController.navigationBar.titleTextAttributes=dict;
    
    //初始化
    [indLoading setBounds:CGRectMake(0, 0, 130, 130)];
    [indLoading setBackgroundColor:[UIColor grayColor]];
    indLoading.alpha=0.75f;
    indLoading.layer.cornerRadius = 10;//设置那个圆角的有多圆
    indLoading.layer.borderWidth = 0;//设置边框的宽度
    [indLoading setHidden:YES];
    
    [web setOpaque:NO];//opaque是不透明的意思
    [web setScalesPageToFit:YES];//自动缩放以适应屏幕
    
    NSString*key=[ProjectAccountCfg getKey];
    NSString* urlstr;
    if(key)
    {
        urlstr=[NSString stringWithFormat:@"%@?key=%@",WEB_INDEX2_URL,key];
    }
    else
    {
        urlstr=WEB_INDEX2_URL;
    }
    [self loadWeb:urlstr];//主页
    
    viConnectFail.alpha=0;
    viConnectFail.hidden=YES;
}

-(void)dealloc
{
    //[super dealloc];
    [web stopLoading];
    web.delegate=nil;
}

-(void) loadWeb:(NSString*)url_str
{
    if (0==strncmp([url_str UTF8String], "http", 4))
    { [web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url_str]]]; }
    else
    { [web loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:url_str]]]; }
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString*s=[[request URL] absoluteString];
    NSLog(@"shouldStartLoadWithRequest = %@",s);
    char *purl=(char*)[s UTF8String];
    if(0==memcmp(purl,"newtab:",7))
    {
        //打开新界面
        UIStoryboard *frm=NULL;
        
        frm = [UIStoryboard storyboardWithName:@"WebController" bundle:nil];
        WebController*wb=(WebController*)frm.instantiateInitialViewController;
        wb.default_url=[NSString stringWithUTF8String:purl+7];
        NSLog(@"wb.default_url = %@",wb.default_url);
        [self.navigationController pushViewController:wb animated:YES];
        return FALSE;
    }
    else
    {
        return TRUE;
    }
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
    
    
    //页面加载完成后加载下面的javascript，修改页面中所有用target="_blank"标记的url（在url前加标记为“newtab”）
    //这里要注意一下那个js的注入方法，不要在最后面放那个替换的方法，不然会出错
    [web stringByEvaluatingJavaScriptFromString:@"javascript: var allLinks = document.getElementsByTagName('a'); if (allLinks) {var i;for (i=0; i<allLinks.length; i++) {var link = allLinks[i];var target = link.getAttribute('target'); if (target && target == '_blank') {link.href = 'newtab:'+link.href;link.setAttribute('target','_self');}}}"];

    
    NSString*key=[ProjectAccountCfg getKey];
    [web stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"javascript: function userkey(){return '%@';}",key]];
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
