//
//  XMBaseStatus.h
//  libxmap_Demo
//
//  Created by Han.zh on 2019/12/11.
//  Copyright © 2019 Han.zhihong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef struct _XMBaseStatus
{
    //是否签入通讯成功
    int isXTNetLoginSuccess;

    //网络通讯质量
    long lastSendKeepTime;
    long lastRecvKeepTime;
    long rtt;
    
    //用户登录信息
    struct{
        //是否已经登录
        BOOL isLogin;
        //协议版本
        char protocol_version[255];
        //当前账号名称
        char username[255];
        char userpasswd[255];
        char userdevID[255];
    }XMapUser;

    //工程信息
    struct{
        //工程是否正常
        BOOL isProjectSuccess;
        //工程信息
        char version[128];
        char title[255];
        char description[255];
        char create_time[255];
    }ProjectInfo;
    
}XMBaseStatus;

extern XMBaseStatus g_XMBaseStatus;

void xmapShowAlert(id s,NSString* str);
