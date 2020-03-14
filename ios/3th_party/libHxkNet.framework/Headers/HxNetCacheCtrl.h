//
//  McuNet.h
//  McuNet
//
//  Created by Han.zh on 15/9/17.
//  Copyright (c) 2015年 Han.zhihong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "hxnet-protocol.h"


@interface HxNetCacheData : NSObject

@property (nonatomic,assign) BOOL isYunCache;
@property NSMutableData* data;
@property (nonatomic,assign) time_t lastPackTime;
@property (nonatomic,copy) NSString* ip;
@property (nonatomic,assign) int port;
@property (nonatomic,copy) NSString* devUUID;

@end

//数据回调
@protocol HxNetCacheCtrlDelegate <NSObject>
-(void)HxNetDataRecv:(TzhNetFrame_Cmd*)data ipv4:(NSString*)ipv4 port:(int)port;
-(void)HxNetDataRecv:(TzhNetFrame_Cmd*)data devUUID:(NSString*)uuid;
@end

@interface HxNetCacheCtrl : NSObject

@property NSMutableArray<id<HxNetCacheCtrlDelegate>>* delegateArray;

//开始和停止
-(BOOL)startService;
-(void)stopService;

//放在接收数据那里作处理
-(void)recvCache:(const char*)buf :(int)len ipv4:(NSString*)ipv4 port:(int)port;
-(void)recvCache:(const char*)buf :(int)len devUUID:(NSString*)uuid;

//生成指令
-(int)genNetData:(char*)flag
        CtrlParm:(unsigned char*) parm
     CtrlParmLen:(int) parm_len
         DstBuff:(uchar*)dstBuf;

-(int)genNetData_v1:(char*)flag
    Promission8Byte:(unsigned char*) pmiss
           CtrlParm:(unsigned char*) parm
        CtrlParmLen:(int) parm_len
            DstBuff:(uchar*)dstBuf;
@end
