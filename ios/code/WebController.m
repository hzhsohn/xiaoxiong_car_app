//
//  CloudManage.m
//  discolor-led
//
//  Created by Han.zh on 15/2/7.
//  Copyright (c) 2015年 Han.zhihong. All rights reserved.
//

#import "WebController.h"
#import <QuartzCore/QuartzCore.h>
#import "DefineHeader.h"
#import "WebController.h"
#import <MJRefresh/MJRefresh.h>
#import <Foundation/Foundation.h>
//! 导入WebKit框架头文件
#import <WebKit/WebKit.h>
#import "AlertCommand.h"

//
#import "WKProcessPool.h"
#import "WKDeviceUtils.h"

@interface WebController ()<WKNavigationDelegate,WKScriptMessageHandler,WKUIDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    NSMutableArray* imgArray;
    AlertCommand* acmd;
}

@property (nonatomic, strong) WKWebView *wkweb;
@property (nonatomic) BOOL didBecomeActive;

-(void) loadWeb:(NSString*)url_str;

@end

@implementation WebController
@synthesize wkweb;

-(void)awakeFromNib
{
    [super awakeFromNib];
    acmd=[[AlertCommand alloc] init];
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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _didBecomeActive=TRUE;

    [wkweb.configuration.userContentController  addScriptMessageHandler:self name:@"takePhoto"];
    [wkweb.configuration.userContentController  addScriptMessageHandler:self name:@"pickPhoto"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _didBecomeActive=FALSE;
    // 这里要记得移除handlers
    //[wkweb.configuration.userContentController removeScriptMessageHandlerForName:@"takePhoto"];
    //[wkweb.configuration.userContentController removeScriptMessageHandlerForName:@"pickPhoto"];
}
////////////////////////////////////////////////////
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"WKWebView";
    
    //设置标题
    /*NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [UIColor whiteColor],NSForegroundColorAttributeName,
                          [UIFont systemFontOfSize:17],NSFontAttributeName,
                          nil];
    self.navigationController.navigationBar.titleTextAttributes=dict;
    */
    [self.navigationController setNavigationBarHidden:YES animated:NO];
  
    [self.view addSubview:self.webView];
    //访问页面
    [self loadWeb:self.default_url];//主页
}

#pragma mark - get方法
- (WKWebView *)webView {
    if (wkweb == nil) {
            //
            NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
            WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
            WKUserContentController *wkUController = [[WKUserContentController alloc] init];
            [wkUController addUserScript:wkUScript];
        

            //
            WKWebViewConfiguration *config = [WKWebViewConfiguration new];
            config.preferences = [WKPreferences new];
            config.preferences.javaScriptEnabled = YES;
            config.preferences.javaScriptCanOpenWindowsAutomatically = YES;
           //使用单例 解决locastorge 储存问题
           config.processPool = [WKProcessPool sharedProcessPool];
            //scalesPageToFit
            config.userContentController = wkUController;
                    
            CGRect f=[self getFrmPos];
            wkweb = [[WKWebView alloc]initWithFrame:f configuration:config];
            wkweb.navigationDelegate = self;
            wkweb.UIDelegate = self;
            [wkweb setOpaque:NO];//opaque是不透明的意思
           //标题栏透明
            wkweb.backgroundColor=[UIColor clearColor];
          
            //如果你导入的MJRefresh库是最新的库，就用下面的方法创建下拉刷新和上拉加载事件
           // wkweb.scrollView.mj_header.alpha=0.0f;
           // wkweb.scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self //refreshingAction:@selector(headerRefresh)];
            //web.scrollView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self //refreshingAction:@selector(footerRefresh)];
            
            //滚动栏处理
           // wkweb.scrollView.showsVerticalScrollIndicator = NO;
           
    }
    return wkweb;
}


#pragma mark - 下拉刷新
- (void)headerRefresh{
    [wkweb reload];
}

#pragma mark - 上拉加载
- (void)footerRefresh{
}

#pragma mark - 结束下拉刷新和上拉加载
- (void)endRefresh{

    //当请求数据成功或失败后，如果你导入的MJRefresh库是最新的库，就用下面的方法结束下拉刷新和上拉加载事件
    [wkweb.scrollView.mj_header endRefreshing];
    [wkweb.scrollView.mj_footer endRefreshing];
    
    wkweb.scrollView.mj_header.alpha=0.0f;
}

-(void)dealloc
{
    //[super dealloc];
    [wkweb stopLoading];
    wkweb=nil;
}

-(void) loadWeb:(NSString*)url_str
{
#if 0
   //
    NSURL *url = [NSURL URLWithString:url_str];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [wkweb loadRequest:request];
    
#else
    //加载调试页面
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"index_test" withExtension:@"html"];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [wkweb loadRequest:urlRequest]; // 加载页面
#endif
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
    
    if(false==[acmd command:message :self :wkweb])
    {
      /*  UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Alert" message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];*/
        completionHandler();
    }
    else
    {
        completionHandler();
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

// 监听用户导航行为
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    // 可以在这个地方处理用户导航行为
    if (navigationAction.navigationType == WKNavigationTypeReload && _didBecomeActive) {
        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
    _didBecomeActive = NO;
}

// 判断是否白屏
- (BOOL)isBlankView:(UIView*)view { // YES：blank
 Class wkCompositingView =NSClassFromString(@"WKCompositingView");
 if ([view isKindOfClass:[wkCompositingView class]]) {
     return NO;
 }
 for(UIView * subView in view.subviews) {
    if(![self isBlankView:subView]) {
    return NO;
    }
 }
 return YES;
}


#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSLog(@"============方法名:%@", message.name);
    NSLog(@"============参数:%@", message.body);
    // 方法名
    if([message.name isEqualToString:@"takePhoto"])
    {
        [self takePhoto];
    }
}

- (void)pickPhoto{
    NSLog(@"pickPhoto");
}

//拍照
- (void)takePhoto{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES; //可编辑
        //判断是否可以打开照相机
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            //摄像头
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                    //出现这个问题，基本就是UI操作放在了非主线程中操作导致。我的问题是webview的回调，有时候会进入子线程处理。所以统一加上dispatch_async(dispatch_get_main_queue...
            dispatch_async(dispatch_get_main_queue(), ^{ //不加这句有时候点击会闪退
                [self presentViewController:picker animated:YES completion:nil];
            });
        }
        else
        {
            NSLog(@"没有摄像头");
        }
    
}


// 相机
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{

   [imgArray removeAllObjects];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [imgArray addObject:image];
    
    if (imgArray.count) {
        //这里开始写请求上传图片接口的代码
        //请求成功，获取返回的图片地址，如果是数组，将数组转换为字符串
        NSString *urlStr=@"123" ;//= [[数组] componentsJoinedByString:@""];
     
        // 然后向js传图片地址:
         NSString *inputValue = [NSString stringWithFormat:@"getPhotoCallback('%@')",urlStr];
         [wkweb evaluateJavaScript:inputValue completionHandler:^(id _Nullable response, NSError * _Nullable error) {
                NSLog(@"value图片: %@ error: %@", response, error);
          }];
        
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
               [self dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)pickerController {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });

}

@end
