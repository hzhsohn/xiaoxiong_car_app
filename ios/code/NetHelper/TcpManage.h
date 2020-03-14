//
//  TcpManage.h
//  RegalConcise
//
//  Created by sohn on 13-6-2.
//  Copyright (c) 2013年 Han.zhihong. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum _TTcpManageStatus
{
    ZH_TCP_MANGE_DISCONNECT,    //已经断开连接
    ZH_TCP_MANGE_DISCONNECTING, //正在断开连接
    ZH_TCP_MANGE_CONNECT_INIT,  //初始化连接信息
    ZH_TCP_MANGE_CONNECTING,    //连接中
    ZH_TCP_MANGE_CONNECTED,     //成功连接
    ZH_TCP_MANGE_NOT_RECONNECT  //不需要重复连接
}TTcpManageStatus;

//数据回调
@protocol TcpManageDelegate <NSObject>

-(void)TcpManageBegin;
-(void)TcpManageConnectCallback:(BOOL) b;
-(void)TcpManageRecvCallback:(char*)buf :(int)len;
-(void)TcpManageDisconnectCallback;

@end

@interface TcpManage : NSObject

@property (nonatomic,assign) id<TcpManageDelegate> delegate;

-(BOOL)connect_start:(NSString*)host :(int)port;
-(void)disconnect_will_reconnect;
-(void)disconnect_not_reconnect;
-(BOOL)isConnected;
-(int)send:(char*)buf :(int)len;
-(void)thread;

@end
