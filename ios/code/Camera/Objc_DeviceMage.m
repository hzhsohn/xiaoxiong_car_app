//
//  Objc_DataStruct.m
//  monitor
//
//  Created by Han Sohn on 12-6-1.
//  Copyright (c) 2012年 Han.zhihong. All rights reserved.
//

#import "Objc_DeviceMage.h"

@implementation Objc_DeviceMage

-(id) init
{
    if((self=[super init]))
    {
        m_aryDevInfo=[[NSMutableArray alloc] init];
              
        NSData *nsData;
        TagDeviceInfo info;
        
        //添加大华数字录像机
        info.devID=MONITOR_DEVICE_ID_DAHUA_DVR;
        strcpy(info.devName,[NSLocalizedString(@"dev_dahua_dvr",nil) UTF8String]);
        strcpy(info.imgName,"dahua_dvr.png");
        info.defaultPort=37777;
        nsData=[NSData dataWithBytes:&info length:sizeof(TagDeviceInfo)];
        [m_aryDevInfo addObject:nsData];
                
        //canon vb-c50fsi
        info.devID=MONITOR_DEVICE_ID_CANON_C50FSI;
        strcpy(info.devName,[NSLocalizedString(@"dev_canon_c50fsi",nil) UTF8String]);
        strcpy(info.imgName,"canon_c50fsi.png");
        info.defaultPort=80;
        nsData=[NSData dataWithBytes:&info length:sizeof(TagDeviceInfo)];
        [m_aryDevInfo addObject:nsData];
        
        //mobotix
        info.devID=MONITOR_DEVICE_ID_MOBOTIX;
        strcpy(info.devName,[NSLocalizedString(@"dev_mobotix",nil) UTF8String]);
        strcpy(info.imgName,"mobotix.png");
        info.defaultPort=8080;
        nsData=[NSData dataWithBytes:&info length:sizeof(TagDeviceInfo)];
        [m_aryDevInfo addObject:nsData];
        
        //MJPEG
        info.devID=MONITOR_DEVICE_ID_MJPEG;
        strcpy(info.devName,[NSLocalizedString(@"dev_mjpeg",nil) UTF8String]);
        strcpy(info.imgName,"mjpeg.png");
        info.defaultPort=8080;
        nsData=[NSData dataWithBytes:&info length:sizeof(TagDeviceInfo)];
        [m_aryDevInfo addObject:nsData];
    }
    return self;
}

-(void) dealloc
{
    m_aryDevInfo=nil;
    
    NSLog(@"DeviceMage dealloc");
}

///////////////////////////////////////////////
//可支持的设备ID信息
-(NSArray*) getList
{
    return m_aryDevInfo;
}

//获取对应devID的设备信息
-(TagDeviceInfo*) getByDevID:(TDevceID)devID
{
    TagDeviceInfo *p;
    for (int i=0; i<[m_aryDevInfo count]; i++) {
        p=(TagDeviceInfo*)[[m_aryDevInfo objectAtIndex:i] bytes];
        if (p->devID==devID) {
            return p;
        }
    }
    return NULL;
}

-(int) getIndexByDevID:(TDevceID)devID
{
    TagDeviceInfo *p;
    for (int i=0; i<[m_aryDevInfo count]; i++) {
        p=(TagDeviceInfo*)[[m_aryDevInfo objectAtIndex:i] bytes];
        if (p->devID==devID) {
            return i;
        }
    }
    return -1;
}

@end
