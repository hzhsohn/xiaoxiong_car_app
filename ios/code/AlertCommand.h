//
//  FoundTableController.h
//  home
//
//  Created by Han.zh on 2017/3/1.
//  Copyright © 2017年 Han.zhihong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface AlertCommand : NSObject

-(id) init;
-(void)dealloc;
-(bool) command:(NSString*)str :(UIViewController*)sel :(WKWebView*)wkv;
//
- (void)shareWeChatLink:(NSString*)url :(NSString*)title :(NSString*)mark;
@end
