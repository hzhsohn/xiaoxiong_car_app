//
//  CloudManage.m
//  discolor-led
//
//  Created by Han.zh on 15/2/7.
//  Copyright (c) 2015年 Han.zhihong. All rights reserved.
//

#import "MyPController.h"
#import <QuartzCore/QuartzCore.h>
#import "DefineHeader.h"
#import "WebController.h"
#import <MJRefresh/MJRefresh.h>
#import <Foundation/Foundation.h>
//! 导入WebKit框架头文件
#import <WebKit/WebKit.h>
#import "AlertCommand.h"
#import "AlertCommand2.h"

//
#import "WKProcessPool.h"
#import "WKDeviceUtils.h"

WKWebView *g_wkwebp3;

@interface MyPController ()<WKNavigationDelegate,WKUIDelegate>
{
    //首页的URL
    NSString* default_urlstr;
    
}
@property (strong ,nonatomic) WKWebView *g_wkweb3;

-(void) loadWeb:(NSString*)url_str;

@end

@implementation MyPController
@synthesize g_wkweb3;

-(CGRect) getFrmPos
{
    CGRect f= [ UIScreen mainScreen ].bounds;
    //处理浏览器高度问题,判断是否有导航栏如果有导航栏即加-44高度
    int navh=0;
    NSString*devIfs=[WKDeviceUtils getDeviceIdentifier];
    //devIfs=@"iPhone 11 Pro";
    if([devIfs isEqualToString:@"iPhone 11"] ||
       [devIfs isEqualToString:@"iPhone 11 Pro"] ||
       [devIfs isEqualToString:@"iPhone 11 Pro Max"] )
    {
        int sum=-44+navh;
        f.origin.y+=sum;
        f.size.height-=sum-34;
    }
    else{
        int sum=-20+navh;
        f.origin.y+=sum;
        f.size.height-=sum;
    }

    return f;
}

-(void)awakeFromNib
{
    [super awakeFromNib];

  //
  WKWebViewConfiguration *config = [WKWebViewConfiguration new];
  config.preferences = [WKPreferences new];
  config.preferences.javaScriptEnabled = YES;
  config.preferences.javaScriptCanOpenWindowsAutomatically = YES;

  //使用单例 解决locastorge 储存问题
  config.processPool = [WKProcessPool sharedProcessPool];


  NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
  WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
  WKUserContentController *wkUController = [[WKUserContentController alloc] init];
  [wkUController addUserScript:wkUScript];
  
  //scalesPageToFit
  config.userContentController = wkUController;

  CGRect f=[self getFrmPos];
  g_wkweb3 = [[WKWebView alloc]initWithFrame:f configuration:config];
  g_wkweb3.navigationDelegate = self;
  g_wkweb3.UIDelegate = self;
  [g_wkweb3 setOpaque:NO];//opaque是不透明的意思
  [self.view addSubview: g_wkweb3];

  
  //如果你导入的MJRefresh库是最新的库，就用下面的方法创建下拉刷新和上拉加载事件
  g_wkweb3.scrollView.mj_header.alpha=0.0f;
  g_wkweb3.scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefresh)];
  //web.scrollView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self //refreshingAction:@selector(footerRefresh)];

//滚动栏处理
  g_wkweb3.scrollView.showsVerticalScrollIndicator = NO;
//
//@"http://xt-sys.com/a4.php";
  default_urlstr=  WEB_INDEX3_URL;
  [self loadWeb:default_urlstr];//主页
    
    g_wkwebp3=g_wkweb3;
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
}

+(WKWebView *)getWeb
{
    return g_wkwebp3;
}

#pragma mark - 下拉刷新
- (void)headerRefresh{
    [g_wkweb3 reload];
}

#pragma mark - 上拉加载
- (void)footerRefresh{
}

#pragma mark - 结束下拉刷新和上拉加载
- (void)endRefresh{

    //当请求数据成功或失败后，如果你导入的MJRefresh库是最新的库，就用下面的方法结束下拉刷新和上拉加载事件
    [g_wkweb3.scrollView.mj_header endRefreshing];
    [g_wkweb3.scrollView.mj_footer endRefreshing];
    g_wkweb3.scrollView.mj_header.alpha=0.0f;

}

-(void)dealloc
{
    //[super dealloc];
    [g_wkweb3 stopLoading];
    g_wkweb3=nil;
}

-(void) loadWeb:(NSString*)url_str
{
    //
    NSURL *url = [NSURL URLWithString:default_urlstr];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [g_wkweb3 loadRequest:request];
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
    // 禁止放大缩小
    NSString *injectionJSString = @"var script = document.createElement('meta');"
    "script.name = 'viewport';"
    "script.content=\"width=device-width, initial-scale=1.0,maximum-scale=1.0, minimum-scale=1.0, user-scalable=no\";"
    "document.getElementsByTagName('head')[0].appendChild(script);";
    [webView evaluateJavaScript:injectionJSString completionHandler:nil];
    
    [webView evaluateJavaScript:@"javascript: var allLinks = document.getElementsByTagName('a'); if (allLinks) {var i;for (i=0; i<allLinks.length; i++) {var link = allLinks[i];var target = link.getAttribute('target'); if (target && target == '_blank') {link.href = 'newtab:'+link.href;link.setAttribute('target','_self');}}}"  completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        
        NSLog(@"response: %@ error: %@", response, error);
    }];
    
    [self endRefresh];
}

//! alert(message)
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    
    NSString*pp=@"url:https://www.daichepin.com/webphone_ios/webphone/client_register";
    int n=(int)[pp length];
    if([message compare:pp options:NSCaseInsensitiveSearch range:NSMakeRange(0,n)])
    {
        AlertCommand* acmd=[[AlertCommand alloc] init];
        if(false==[acmd command:message :self :g_wkweb3])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
            [alert show];
            completionHandler();
        }
        else
        {
            completionHandler();
        }
        acmd=nil;
    }
    else{
        AlertCommand2* acmd=[[AlertCommand2 alloc] init];
        if(false==[acmd command:message :self :g_wkweb3])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
            [alert show];
            completionHandler();
        }
        else
        {
            completionHandler();
        }
        acmd=nil;
    }
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


- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView API_AVAILABLE(macosx(10.11), ios(9.0))
{
    [webView reload];
}
@end
