//
//  McuNetAssist.h
//  McuNet
//
//  Created by Han.zh on 15/10/3.
//  Copyright © 2015年 Han.zhihong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface McuNetAssist : NSObject

//获取设备的IP地址,子网,广播地址的数组
+(NSArray*)deviceIPAdress;

//网络地址转换
+(void) SockAddrToPram:(const struct sockaddr_in *)addr :(char*)ip :(unsigned short *)port;
+(void) SockPramToAddr:(const char*)ip :(unsigned short)port :(struct sockaddr_in *)addr;

@end
