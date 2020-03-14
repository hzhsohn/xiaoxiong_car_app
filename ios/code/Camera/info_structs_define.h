//
//  DataStructs.h
//  monitor
//
//  Created by Han Sohn on 12-6-22.
//  Copyright (c) 2012年 Han.zhihong. All rights reserved.
//

#ifndef info_structs_define_h
#define info_structs_define_h
#import <CoreLocation/CoreLocation.h>

@class MainController;

//建立目录
#define MKDIR(path)    [[NSFileManager defaultManager] createDirectoryAtPath: [NSString stringWithUTF8String:path] withIntermediateDirectories:YES attributes:nil error:nil];

//设备的种类
typedef enum _TDevceID
{
    MONITOR_DEVICE_ID_UNKNOW =0,
    MONITOR_DEVICE_ID_DAHUA_DVR,//大华数字录像机
    MONITOR_DEVICE_ID_MJPEG,//MJPEG
    MONITOR_DEVICE_ID_CANON_C50FSI,//canon vb-c50fsi
    MONITOR_DEVICE_ID_MOBOTIX,//mobotix
}TDevceID;

//网络类型
typedef enum _TNetworkType
{
    MONITOR_NETWORK_NONE=0, //网络不可用
    MONITOR_NETWORK_WIFI=1, //WIFI
    MONITOR_NETWORK_WWAN=2  //蜂窝网络
}TNetworkType;

//设备信息的结构
typedef struct _TagDeviceInfo{
    TDevceID devID; //区分设备型号
    char devName[128];
    char imgName[128];
    int defaultPort;
}TagDeviceInfo;

//主机信息
typedef struct _TagHostInfo{
    int autoID;
    char title[256];
    char host[256];
    int port;
    char username[128];
    char password[64];
    char parameter[1024];
    TDevceID devID;                 //区分设备型号
}TagHostInfo;


#endif
