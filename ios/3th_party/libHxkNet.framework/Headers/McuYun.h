//
//  ezhMcuYun.h
//  RegalConcise
//
//  Created by sohn on 13-6-2.
//  Copyright (c) 2013年 Han.zhihong. All rights reserved.
//

#import <Foundation/Foundation.h>

//调度服务器的域名
#define IOT_DEV_URL        "iot.d.hx-kong.com"

//标识占一个字节,ezhUserProl_Data 接收和发送都是一样
typedef enum _EzhUserProtocol{
    ezhUserProl_Data =0,			//[string devUUID][uchar buf]
    ezhUserProl_Data_Ret =1,		//[string devUUID][uchar buf]
    ezhUserProl_Keep =2,			//无
    ezhUserProl_Keep_Ret =3,		//无
    ezhUserProl_SubscrDev =4,		//[string 要获取数据的devUUID]
    ezhUserProl_SubscrDev_Ret =5,	//[string 设置成功的的devUUID]
    ezhUserProl_UnsubscrDev =6,		//[string 取消数据的devUUID]
    ezhUserProl_UnsubscrDev_Ret =7,	//[string 成功取消的devUUID]
    ezhUserProl_IsOnline =8,		//循环<[string 要查找在线的devUUID]>
    ezhUserProl_IsOnline_Ret =9,	//循环<[string 在线的devUUID]>
}EzhUserProtocol;

typedef enum _TTcpMcuYunStatus
{
    ezhMcuYun_DISCONNECT,    //已经断开连接
    ezhMcuYun_DISCONNECTING, //正在断开连接
    ezhMcuYun_CONNECT_INIT,  //初始化连接信息
    ezhMcuYun_CONNECTING,    //连接中
    ezhMcuYun_CONNECTED,     //成功连接
    ezhMcuYun_NOT_RECONNECT  //不需要重复连接
}TTcpMcuYunStatus;

//数据回调
@protocol McuYunDelegate <NSObject>
//////////////////////////
-(void)McuYunGetDispatch:(NSString*)ip :(int)port;
-(void)McuYunGetDispatchErr:(int)codeID errMsg:(NSString*)msg;
//////////////////////////
-(void)McuYunConnectCallback:(BOOL) b;
-(void)McuYunConnectedDTRS;
//////////////////////////
//保活包
-(void) eventKeep:(time_t)rtt;
//通讯数据
-(void) eventRecvData:(NSString*)devUUID buf:(const char*)buf len:(int)len;
//订阅数据回调成功
-(void) eventSubscrDev:(NSString*)devUUID;
//取消订阅数据回调成功
-(void) eventUnsubscrDev:(NSString*)devUUID;
//是否在线
-(void) eventIsOnline:(NSString*)devUUID :(BOOL)online;
//////////////////////////
-(void)McuYunDisconnectCallback;

@end

@interface McuYun : NSObject

@property (nonatomic,copy) NSString* DPID;
@property NSMutableArray<id<McuYunDelegate>>* delegateArray;
//
-(id)initWithDPID:(NSString*)dpid;
//
-(BOOL) startService;
-(void) stopService;
//
-(BOOL)getIotDispath;
//
-(BOOL)connect_start:(NSString*)host port:(int)port;
-(void)disconnect_will_reconnect;
-(void)disconnect_not_reconnect;
-(BOOL)isTcpConnected;
-(ssize_t)send:(const char*)buf :(int)len;

///////////////////////////////////////////
//IOT保活包
-(ssize_t) iotKeep;
//订阅
-(ssize_t) iotSubscr:(const char*)devUUID;
-(ssize_t) iotUnsubscr:(const char*)devUUID;
//
-(ssize_t) iotIsOnline:(const char*)devUUID;
//发送数据
-(ssize_t) iotSend:(const char*)devUUID buf:(const char*)buf len:(int)len;

@end
