//
//  AppDelegate.m
//  discolor-led
//
//  Created by Han.zh on 15/2/7.
//  Copyright (c) 2015年 Han.zhihong. All rights reserved.
//

#import "AppDelegate.h"
#import "WXApi.h"
#import "StartupPageController.h"
#import "MainTabController.h"
@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [WXApi registerApp:@"wxfc9a296ef77b9b95" withDescription:@"DaiChePin Share"];
    
    BOOL isFirst =[[[NSUserDefaults standardUserDefaults] objectForKey:@"isFirst"]boolValue];
      if (!isFirst) {
//          第一次启动
          
           //3.多页启动页
           StartupPageController *startup = [[StartupPageController alloc]init];
           startup.ImageArray = @[@"固定资源",@"固定线路",@"长期合作"];
          [[NSUserDefaults standardUserDefaults]setObject:@"YES" forKey:@"isFirst"];
           self.window.rootViewController = startup;
           
      }else
      {
          //非第一次
          MainTabController *view = [[MainTabController alloc]init];
          self.window.rootViewController = view;
      }
    return YES;
}

- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<NSString *,id> *)options {
    return  [WXApi handleOpenURL:url delegate:self];
}
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return TRUE;
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return TRUE;
}

// onReq是微信终端向第三方程序发起请求，要求第三方程序响应。第三方程序响应完后必须调用sendRsp返回。在调用sendRsp返回时，会切回到微信终端程序界面
- (void)onReq:(BaseReq *)req
{
   
}

// 如果第三方程序向微信发送了sendReq的请求，那么onResp会被回调。sendReq请求调用后，会切到微信终端程序界面
- (void)onResp:(BaseResp *)resp
{
    NSLog(@"回调处理");
    // 处理 分享请求 回调
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        switch (resp.errCode) {
            case WXSuccess:
                //分享成功
                break;
            case WXErrCodeUserCancel:
                //用户取消分享
                break;
            default:
                //分享失败
                break;
        }
    }
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.

}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
}

    

@end
