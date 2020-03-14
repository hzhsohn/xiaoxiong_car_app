//
//  DevListInfo.h
//  home
//
//  Created by Han.zh on 2017/1/12.
//  Copyright © 2017年 Han.zhihong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DevKeyMagr.h"

//列表CELL的数据结构
@interface DevListInfo:NSObject
    @property(nonatomic,assign)    TzhKeyMgr dbInfo;
    @property(nonatomic,assign)    BOOL isLANOnline;
    @property(nonatomic,assign)    BOOL isYunOnline;
    @property(nonatomic,copy)    NSString* devUUID;
    @property(nonatomic,copy)    NSString* devflag;
    @property(nonatomic,copy)    NSString* devname;
    @property(nonatomic,copy)    NSString* ip;
    @property(nonatomic,assign)    int port;
    @property(nonatomic,copy)    NSString* dvar;
@end
