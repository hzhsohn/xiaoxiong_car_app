//
//  Objc_HostInfoMage.h
//  monitor
//
//  Created by Han Sohn on 12-6-16.
//  Copyright (c) 2012年 Han.zhihong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#include "info_structs_define.h"
#import "Objc_Sqlite.h"

@interface Objc_HostInfoMage : NSObject
{
    NSMutableArray *m_aryHostInfo;
    Objc_Sqlite *m_sqlMage;
    
    //数据库路径
    NSMutableString *m_sDatabasePath;
}

//处理数据库
-(BOOL) createDB;
-(BOOL) openDB;
-(BOOL) deleteDB;

//重新刷新HOST信息;
-(void) reloadHostInDB;
//获取设备主机信息列表
-(NSArray*) getHostInfoList;


//插入设备主机信息,用于连接,添加成功返回TRUE,失败返回FLASE
-(BOOL) insertHostInfo:(char*) title
              :(char*) host
              :(int) port
              :(TDevceID) devID
              :(char*) username
              :(char*) password
              :(char*) parameter;

//更新主机信息
- (BOOL) updateHostInfo:(int)autoID :(char*)title :(char*)host :(int)port 
                       :(TDevceID)devID :(char*)username :(char*)password
                       :(char*)parameter;
//获取详细主机信息
-(TagHostInfo*) getHostByAutoID:(int)autoID;
-(void) deleteHostByIndex:(int)index;

@end
