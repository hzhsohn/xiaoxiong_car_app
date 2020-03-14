//
//  Objc_DataStruct.h
//  monitor
//
//  Created by Han Sohn on 12-6-1.
//  Copyright (c) 2012年 Han.zhihong. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "info_structs_define.h"

@interface Objc_DeviceMage : NSObject
{
    NSMutableArray *m_aryDevInfo;
}

//获取设备型号列表
-(NSArray*) getList;
//获取详细设备的信息
-(TagDeviceInfo*) getByDevID:(TDevceID)devID;
//根据devID获取列表的index位置,找不到返回-1
-(int) getIndexByDevID:(TDevceID)devID;
@end
