//
//  CtrlMain_w1.h
//  discolor-led
//
//  Created by Han.zh on 15/2/17.
//  Copyright (c) 2015年 Han.zhihong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceIDTemplateTab : UITabBarController

//初始化需求信息
@property (nonatomic,copy) NSString* devName;
@property (nonatomic,copy) NSString* host;
@property (nonatomic,assign) int port;

-(void) setInfo:(NSString*)devname :(NSString*)host :(int)port;

@end
