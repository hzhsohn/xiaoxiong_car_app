//
//  Header.h
//  libHxkNet
//
//  Created by Han.zh on 2018/8/16.
//  Copyright © 2018年 Han.zhihong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface McuWebDevItem:NSObject

@property (copy) NSString* dpid;
@property (copy) NSString* devname;
@property (copy) NSString* uuid;
@property (copy) NSString* flag;
@property (copy) NSString* uptime; //last login time
@property BOOL isOnline;

@end


