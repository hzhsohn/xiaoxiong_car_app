//
//  McuNet.h
//  McuNet
//
//  Created by Han.zh on 15/9/17.
//  Copyright (c) 2015年 Han.zhihong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "hxnet-protocol.h"

//数据回调
@protocol MSDUDPDelegate <NSObject>
-(void)MSDUDPRecvform:(char*)recvbuf :(int)recvlen :(struct sockaddr_in*)addr;
@end

@interface MSDUDP : NSObject

@property (nonatomic,assign) id<MSDUDPDelegate> delegate;

//开始服务
-(void)start:(int)binPort;

//释放对象
-(void)stop;

//发送UDP数据
-(void)sendto:(unsigned char*)buff len:(int)send_len ipv4:(NSString*)ip Port:(int)port;
@end
