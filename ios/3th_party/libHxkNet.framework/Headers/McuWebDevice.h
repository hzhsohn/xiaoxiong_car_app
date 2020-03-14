//
//  Header.h
//  libHxkNet
//
//  Created by Han.zh on 2018/8/16.
//  Copyright © 2018年 Han.zhihong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "McuWebDevItem.h"

//WEB获取在线设备信息
#define sIotDevUrl                              @"http://iot.d.hx-kong.com:8088/"
#define sIotDev_get_dev_by_caid_page            @"get-dev.php"
#define sIotDev_remove_dev_by_caid_page         @"remove-dev.php"
#define sIotDev_get_online_by_caid_page         @"get-online.php"
#define sIotDev_get_online_by_uuid_page         @"check-online.php"

//////////////////////////////////////////

//数据回调
@protocol McuWebDeviceDelegate <NSObject>
//
-(void) deviceList:(NSArray*) devList;
-(void) removeDevice:(NSString*)del_caid :(NSString*) del_uuid;
-(void) deviceOnlineByCAID:(NSArray*) lstUUID;
-(void) deviceOnlineByUUID:(NSArray*) lstUUID;
//
-(void) getDevListFail:(NSString*)errMsg;
-(void) removeDeviceFail:(NSString*)errMsg;
-(void) getDevOnlineByCAIDFail:(NSString*)errMsg;
-(void) getDevOnlineByUUIDFail:(NSString*)errMsg;
@end

@interface McuWebDevice : NSObject

@property id<McuWebDeviceDelegate> delegate;

-(void) getDevices:(NSString*) caid;
-(void) getOnlineDevicesByCAID:(NSString*) caid;
-(void) getOnlineDevicesByUUID:(NSString*) uuid;
-(void) deleteDevice:(NSString*) caid :(NSString*) uuid;

@end

