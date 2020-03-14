//
//  MSDService.h
//  McuNet
//
//  Created by Han.zh on 2017/11/16.
//  Copyright © 2017年 Han.zhihong. All rights reserved.
//

#import <Foundation/Foundation.h>


//MSD的数据包结构
@interface MSDPacket : NSObject

@property (nonatomic,assign) int packetID;
@property (nonatomic,copy) NSString* ip;
@property (nonatomic,assign) int port;
@property (nonatomic,copy) NSData* data;
@property (nonatomic,assign) time_t initPacketTime; //发送数据包计数器
@property (nonatomic,assign) time_t sendPacketLastTime; //发送数据包计数器

-(id)initWithPack:(unsigned short)packID :(NSString*)ip :(int)port :(NSData*)data;

@end

//回调处理
@protocol MSDDelegate <NSObject>

-(void) send_cb:(MSDPacket*) packet;
-(void) recvfrom:(char*)buff :(int) len :(NSString*) ipv4 :(int) port;
-(void) err:(int)codeid :(NSString*) msg :(MSDPacket*) packet;

@end

//处理类
@interface MSDService : NSObject

@property NSMutableArray<id<MSDDelegate>>* delegateArray;

-(BOOL) startService;
-(BOOL) startService:(int)bindPort;
-(void) stopService;

-(void) sendto:(unsigned char*)send_buf BuffLen:(int)send_len :(NSString*)ipv4 Port:(int)port ;
-(void) sendDUDP:(char*) data datalen:(int) len ipv4:(NSString*) ipv4 port:(int) port :(NSString*) devname;
-(void) sendDUDP:(char*) data datalen:(int) len ipv4:(NSString*) ipv4 port:(int) port strlist:(NSArray*) aryDevname;

//发送补包透传数据,返回包的packetID
-(int) sendMSUDP:(char*) data datalen:(int) len ipv4:(NSString*) host_or_ipv4 port:(int) port;

@end
