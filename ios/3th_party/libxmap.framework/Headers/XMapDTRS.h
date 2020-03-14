//
//  XMapDTRS.h
//  libxmap
//
//  Created by Han.zh on 2019/10/5.
//  Copyright © 2019年 Han.zhihong. All rights reserved.
//

#import "XMapWritePacket.h"
#import "XMapReadPacket.h"

/**
 * 事件监听接口
 */
@protocol XMapDTRSListener
/*
 连接顺序
 
 1.连接服务器
 2.订阅中控的消息
 3.签入中控系统
 4.正常通讯
 
 */
-(void) XMapDTRS_devuuid_subscr_success;
-(void) XMapDTRS_sign_success;
-(void) XMapDTRS_new_data:(char*) data :(int)len;
-(void) XMapDTRS_abnormal_communication:(int)errid :(NSString*) msg;//通讯异常
-(void) XMapDTRS_disconnect;

@end

@interface XMapDTRS : NSObject

@property(nonatomic,copy) NSString* targetUUID;
@property NSMutableArray<id<XMapDTRSListener>>* delegateList;

-(id) initWithDPID:(NSString*) dpid targetUUID:(NSString*) uuid;

//循环执行-------------
-(void) loop_process;
//-------------------

//申请签入XMAP终端
-(BOOL) sign;
//连接XMAP
-(void) connectXMap;
//注销对象
-(void) destory;
//发送数据
-(BOOL) send:(char*) buf :(int) len;
-(BOOL) sendPack:(XMapWritePacket*) pk;

@end
