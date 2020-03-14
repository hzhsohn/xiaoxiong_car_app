//
//  McuNet.h
//  McuNet
//
//  Created by Han.zh on 15/9/17.
//  Copyright (c) 2015年 Han.zhihong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSDSearchInfo.h"

/******************
 逻辑
 
1.手机广播192.168.1.255和组播228.0.0.8到各个子设备中  ,手机->设备 发送:FMSD
2.设备回复答应,并获取IP地址 ,设备->手机 发送:RMSD+设备ID+JSON内容
3.UDP进行直接控制操作

 ******************/


//广播端口
#define  MSD_BROADCAST_BIND_PORT     2288
#define  MSD_MULTIP_ADDR                     "228.0.0.8"    //组播地址


//数据回调
@protocol MSDSearchDevDelegate <NSObject>

-(void)MSDSearchDevOnLine:(MSDSearchInfo*)info;
-(void)MSDSearchDevUpdate:(MSDSearchInfo*)info;
-(void)MSDSearchDevOffLine:(MSDSearchInfo*)info;

@end

@interface MSDSearchDev : NSObject

@property NSMutableArray<id<MSDSearchDevDelegate>>* delegateArray;

//开始服务
-(BOOL)startService;
-(BOOL)startService:(int)bindPort;

//释放对象
-(void)stopService;

//当前设备
-(void)getDevNSDataArray:(NSMutableArray*) ary;

//清空已经搜索的对象
-(void)clearAllDev;

//重置快捷搜索
-(void)resetQuickSearch;
@end
