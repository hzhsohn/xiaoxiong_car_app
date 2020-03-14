//
//  CtrlMain_w1.h
//  discolor-led
//
//  Created by Han.zh on 15/2/17.
//  Copyright (c) 2015年 Han.zhihong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceIDTemplate : UIViewController

//初始化需求信息
@property (nonatomic,assign) int netType; //0=局域网,1=互联网
@property (nonatomic,copy) NSString* devUUID;
@property (nonatomic,copy) NSString* devName;
@property (nonatomic,copy) NSString* devflag;
@property (nonatomic,copy) NSString* host;
@property (nonatomic,assign) int port;

-(void) setDeviceInfo:(int)netType
                     :(NSString*)devUUID
                     :(NSString*)devname
                     :(NSString*)flag
                     :(NSString*)host
                     :(int)port;

@end
