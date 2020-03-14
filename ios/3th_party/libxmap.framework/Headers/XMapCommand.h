//
//  XMapCommand.h
//  libxmap_Demo
//
//  Created by Han.zh on 2019/12/11.
//  Copyright © 2019 Han.zhihong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libxmap/libxmap.h>


@interface XMapCommand : NSObject

//获取时间
+(time_t) getTime;
//---------------------------------
//保活包
+(XMapWritePacket*) getKeep;
//保活包处理
+(XMapWritePacket*) recvKeep;

//---------------------------------
//登录进系统里
+(XMapWritePacket*) login
                       :(NSString*) group_name
                       :(NSString*) password
                      :(NSString*) deviceName;
//获取的当前协议版本号
+(XMapWritePacket*) loginout;

//获取的当前协议版本号
+(XMapWritePacket*) getProtocolVersion;

//获取工程信息
+(XMapWritePacket*) getProjectInfo;

//获取当前工程WALL表
+(XMapWritePacket*) getWallList;

//获取当前工程WALL表某个内容
+(XMapWritePacket*) getWallListCxt :(int) index;

//获取wall的元素
+(XMapWritePacket*) getWallElement :(NSString*) filename;

//获取wall的元素
+(XMapWritePacket*) getWallElementCxt :(NSString*) filename :(int) index;

+(XMapWritePacket*) getWallElementByLabel
                                 :(NSString*) label_name;

//获取当前搜索到的MSD设备信息
+(XMapWritePacket*) getMSDDevice;

//获取当前搜索到的MSD设备信息
+(XMapWritePacket*) getMSDDeviceCxt :(int) index;

//获取当前用户列表
+(XMapWritePacket*) getUserList;

//获取当前用户列表某个内容
+(XMapWritePacket*) getUserListCxt :(int) index;
//获取推送列表
+(XMapWritePacket*) getPushGroup;
+(XMapWritePacket*) getPushGroupCxt :(int) index;
//获取推送设备列表
+(XMapWritePacket*) getPushDevList :(NSString*) group_type;
+(XMapWritePacket*) getPushDevListCxt :(NSString*) group_type :(int) index;
//添加推送设备
+(XMapWritePacket*) addPushGroup :(NSString*) pushType;

//删除推送设备
+(XMapWritePacket*) deletePushGroup
                           :(NSString*) type;
//添加推送设备
+(XMapWritePacket*) addPushDev
                      :(NSString*) pushType
                      :(NSString*) devType
                      :(NSString*) token
                      :(NSString*) description;

//删除推送设备
+(XMapWritePacket*) deletePushDev
                         :(NSString*) uniqueID;

//修改设备描述
+(XMapWritePacket*) modifyPushDev
                         :(NSString*) unique_id
                         :(NSString*) dev
                         :(NSString*) token
                         :(NSString*) descriptionl;

//控制场景
+(XMapWritePacket*) controlMSDDev :(NSString*) devname :(NSString*) scene;

//MSD与脚本数据交互
+(XMapWritePacket*) getMSDUData
                       :(NSString*) devname
                       :(NSString*) command
                       :(NSString*) parameter;
//获取设备标签列表
+(XMapWritePacket*) getDevLabel;
//获取设备标签列表
+(XMapWritePacket*) getDevLabelCxt :(int) index;
//修改设备标签
+(XMapWritePacket*) modifyDevLabel
                          :(NSString*) unique_id
                          :(NSString*) devname
                          :(NSString*) label
                          :(NSString*) description;
//删除设备标签
+(XMapWritePacket*) deleteDevLabel :(NSString*) unique_id;

//修改密码
+(XMapWritePacket*) modifyPassword
                          :(const char*) old_password
                          :(const char*) new_password;

//控制场景
+(XMapWritePacket*) controlBox :(NSString*) wall_filename  :(NSString*) cup_name;

@end

