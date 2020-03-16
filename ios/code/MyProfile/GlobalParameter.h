//
//  GlobalParameter.h
//  Smart
//
//  Created by sohn on 12-12-31.
//  Copyright (c) 2012年 Han.zhihong. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef struct _TckUserlist
{
    char key[1024]; //登录的加密钥匙
}TckUserlist;

@interface GlobalParameter : NSObject

+ (NSString*) documentPath:(NSString*)str;
//账户信息
+(void)setLoginKey:(NSString*)key;
+(NSString*)getLoginKey;
+(void)clearLoginCfg;
//获取本地图片地址
+ (NSString*) createUserIconLocalPath:(NSString*)userid;
+ (NSString*) getUserIconLocalPath:(NSString*)userid;
//网络信息
+(NSString*) getAccountAddrByICON:(NSString*)userid;
+(NSString*) getAccountAddrByMob:(NSString*)page;
+(NSString*) getAccountAddrBySMS:(NSString*)page;
+(NSString*) getIOTAddrByInfo:(NSString*)page;
@end
