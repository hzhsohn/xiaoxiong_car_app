//
//  MSDSearchInfo.h
//  McuNet
//
//  Created by Han.zh on 2017/1/16.
//  Copyright © 2017年 Han.zhihong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSDSearchInfo : NSObject

@property(nonatomic,copy)       NSString* devUUID;
@property(nonatomic,copy)       NSString* devflag;
@property(nonatomic,copy)       NSString* devname;
@property(nonatomic,copy)       NSString* dvar; //MCU给的状态变量
@property(nonatomic,copy)       NSString* ip;
@property(nonatomic,assign)     int port;
//最后一次探测时间
@property(nonatomic,assign)  unsigned long dwLastCheckTime;
//是否在线
@property(nonatomic,assign)  BOOL isOnline;

@end


