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
#import "WebController.h"
#import <MJRefresh/MJRefresh.h>
#import <Foundation/Foundation.h>
//! 导入WebKit框架头文件
#import <WebKit/WebKit.h>
#import "AlertCommand.h"

WKWebView *g_wkweb2;

@interface VipController ()<WKNavigationDelegate,WKUIDelegate>
{
    //首页的URL
    NSString* default_urlstr;
    
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
    /*NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [UIColor whiteColor],NSForegroundColorAttributeName,
                          [UIFont systemFontOfSize:17],NSFontAttributeName,
                          nil];
    self.navigationController.navigationBar.titleTextAttributes=dict;
    */
    [self.navigationController setNavigationBarHidden:YES animated:NO];
   
    //
    WKWebViewConfiguration *config = [WKWebViewConfiguration new];
    config.preferences = [WKPreferences new];
    config.preferences.javaScriptEnabled = YES;
    config.preferences.javaScriptCanOpenWindowsAutomatically = YES;
    NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
    WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    WKUserContentController *wkUController = [[WKUserContentController alloc] init];
    [wkUController addUserScript:wkUScript];
    
    //scalesPageToFit
    config.userContentController = wkUController;
            
    CGRect f=self.view.bounds;
    f.origin.y+=20;
    g_wkweb2 = [[WKWebView alloc]initWithFrame:f configuration:config];
    g_wkweb2.navigationDelegate = self;
    g_wkweb2.UIDelegate = self;
    [g_wkweb2 setOpaque:NO];//opaque是不透明的意思
    [self.view addSubview: g_wkweb2];
    
    //如果你导入的MJRefresh库是最新的库，就用下面的方法创建下拉刷新和上拉加载事件
    g_wkweb2.scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefresh)];
    //g_wkweb2.scrollView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self //refreshingAction:@selector(footerRefresh)];
    
    //滚动栏处理
    g_wkweb2.scrollView.showsVerticalScrollIndicator = NO;
    //
    default_urlstr=WEB_INDEX2_URL;
    [self loadWeb:default_urlstr];//主页

}

+(WKWebView *)getWeb
{
    return g_wkweb2;
}

#pragma mark - 下拉刷新
- (void)headerRefresh{
    [g_wkweb2 reload];
}

#pragma mark - 上拉加载
- (void)footerRefresh{
}

#pragma mark - 结束下拉刷新和上拉加载
- (void)endRefresh{

    //当请求数据成功或失败后，如果你导入的MJRefresh库是最新的库，就用下面的方法结束下拉刷新和上拉加载事件
    [g_wkweb2.scrollView.mj_header endRefreshing];
    [g_wkweb2.scrollView.mj_footer endRefreshing];

}

-(void)dealloc
{
    //[super dealloc];
    [g_wkweb2 stopLoading];
    g_wkweb2=nil;
}

-(void) loadWeb:(NSString*)url_str
{
    //
    NSURL *url = [NSURL URLWithString:default_urlstr];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [g_wkweb2 loadRequest:request];
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


#pragma mark - WKUIDelegate

//html加载失败
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"error message:%@",error);
    [self endRefresh];
}

//html开始加载
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    NSLog(@"begin load html");
}

//html加载完成
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    NSLog(@"finish load");
    [webView evaluateJavaScript:@"javascript: var allLinks = document.getElementsByTagName('a'); if (allLinks) {var i;for (i=0; i<allLinks.length; i++) {var link = allLinks[i];var target = link.getAttribute('target'); if (target && target == '_blank') {link.href = 'newtab:'+link.href;link.setAttribute('target','_self');}}}"  completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        
        NSLog(@"response: %@ error: %@", response, error);
    }];
    
    [self endRefresh];
}

//! alert(message)
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    
    AlertCommand* acmd=[[AlertCommand alloc] init];
    if(false==[acmd command:message :self :g_wkweb2])
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Alert" message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            completionHandler();
        }];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else
    {
        completionHandler();
    }
    acmd=nil;
}

//! confirm(message)
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Confirm" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:confirmAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

//! prompt(prompt, defaultText)
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString *))completionHandler {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = defaultText;
    }];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields[0].text);
    }];
    [alertController addAction:confirmAction];
    [self presentViewController:alertController animated:YES completion:nil];
}


@end
