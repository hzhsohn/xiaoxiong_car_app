//
//  CloudManage.m
//  discolor-led
//
//  Created by Han.zh on 15/2/7.
//  Copyright (c) 2015年 Han.zhihong. All rights reserved.
//

#import "AlertCommand.h"
#import <QuartzCore/QuartzCore.h>
#import "DefineHeader.h"
#import <MJRefresh/MJRefresh.h>
#import <Foundation/Foundation.h>
#import "WebController.h"
#import <WebKit/WebKit.h>
#import "IndexController.h"
#import "VipController.h"
#import "MyPController.h"
#import "WXApi.h"

@implementation AlertCommand

-(id) init
{
    if(self=[super init])
    {
    }
    return self;
}

-(void)dealloc
{
}


-(bool) command:(NSString*)str :(UIViewController*)sel :(WKWebView*)wkv
{
    if(![str compare:@"url:" options:NSCaseInsensitiveSearch range:NSMakeRange(0,4)])
    {
        NSString*doConent=[str substringFromIndex:4];
        
        UIStoryboard *frm = [UIStoryboard storyboardWithName:@"WebController" bundle:nil];
        WebController* v=(WebController*)frm.instantiateInitialViewController;
        v.default_url=doConent;
        [sel.navigationController pushViewController:v animated:YES];
        return true;
    }
    else if(![str compare:@"lurl:" options:NSCaseInsensitiveSearch range:NSMakeRange(0,5)])
    {
        NSString*doConent=[str substringFromIndex:5];
        //
        NSURL *url = [NSURL URLWithString:doConent];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
        [wkv loadRequest:request];
        return true;
    }
    else if(![str compare:@"cmd:" options:NSCaseInsensitiveSearch range:NSMakeRange(0,4)])
    {
        NSString*doConent=[str substringFromIndex:4];
        
        if([doConent isEqualToString:@"closefrm"])
        {
            [sel.navigationController popViewControllerAnimated:YES];
        }
        else if(![doConent compare:@"tel|" options:NSCaseInsensitiveSearch range:NSMakeRange(0,4)])
        {
            NSString*lsdata=[doConent substringFromIndex:4];
            
            NSString*opentel=[NSString stringWithFormat:@"tel://%@",lsdata];
            [[UIApplication sharedApplication]
                    openURL:[NSURL URLWithString:opentel]];
        }
        else if(![doConent compare:@"pay|" options:NSCaseInsensitiveSearch range:NSMakeRange(0,4)])
               {
                   NSString*lsdata=[doConent substringFromIndex:4];
                   NSLog(@"lsdata%@",lsdata);
                   
               }
        else if(![doConent compare:@"share|" options:NSCaseInsensitiveSearch range:NSMakeRange(0,6)])
        {
            NSString*lsdata=[doConent substringFromIndex:6];
            
            // alert("cmd:share|分享|标题|我是分享的内容http://www.hanzhihong.cn");
            NSArray *strArr = [lsdata componentsSeparatedByString:@"|"];
            
            if([strArr count]>=3) {
                [self shareWeChatLink:strArr[0] :strArr[1] :strArr[2]];
            }
        }
        /*else if(command.startsWith("setitem|")) {
            String newmsg = command.replace("setitem|", "");
            // alert("cmd:setitem|0|撸啊撸");
            String[] strArr = newmsg.split("\\|", -1);
            if (strArr.length >= 2) {
                if (strArr[0].equals("0")) {
                    MainActivity.bottomNavigationView.getMenu().findItem(R.id.item_found)
                            .setTitle(strArr[1]);
                } else if (strArr[0].equals("1")) {
                    MainActivity.bottomNavigationView.getMenu().findItem(R.id.item_vip)
                            .setTitle(strArr[1]);
                } else if (strArr[0].equals("2")) {
                    MainActivity.bottomNavigationView.getMenu().findItem(R.id.item_my)
                            .setTitle(strArr[1]);
                }
            } else {
                new AlertDialog.Builder(H5Web_acty.this).
                        setTitle("提示").setMessage("setitem 需要两个参数 cmd:setitem|0|撸啊撸").setPositiveButton("确定",
                        new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface arg0, int arg1) {
                                //TODO
                            }
                        }).create().show();
            }
        }*/
        else if(![doConent compare:@"reload|" options:NSCaseInsensitiveSearch range:NSMakeRange(0,7)])
        {
            NSString*lsdata=[doConent substringFromIndex:7];
            if([lsdata isEqualToString:@"0"])
            {
                [[IndexController getWeb] reload];
            }
            else if([lsdata isEqualToString:@"1"])
            {
                [[VipController getWeb] reload];
            }
            else if([lsdata isEqualToString:@"2"])
            {
                [[MyPController getWeb] reload];
            }
        }
    
        return true;
    }
    
    return false;
}


/** 分享链接*/
- (void)shareWeChatLink:(NSString*)url :(NSString*)title :(NSString*)mark
{
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    WXMediaMessage *message = [WXMediaMessage message];
    WXWebpageObject *ext = [WXWebpageObject object];
    //需要分享的链接
    ext.webpageUrl = url;
    //多媒体数据对象
    message.mediaObject = ext;
    //分享的链接介绍文本
    message.description = mark;
    //分享的链接标题
    message.title = title;
    //给分享链接设置小图标
    [message setThumbImage:[UIImage imageNamed:@"shareTest"]];
    //标记不是分享文本
    req.bText = NO;
    //设置message对象
    req.message = message;
    // 分享目标场景
    // 发送到聊天界面  WXSceneSession
    // 发送到朋友圈    WXSceneTimeline
    // 发送到微信收藏  WXSceneFavorite
    req.scene = WXSceneSession;
    //发起微信分享
    BOOL isInstalled = [WXApi sendReq:req];
    if (isInstalled == NO) {
        //调用微信分享失败 如：没有安装微信
    }
}


@end
