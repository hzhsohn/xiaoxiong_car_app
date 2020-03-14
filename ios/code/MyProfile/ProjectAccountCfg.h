//
//  ProjectSqlite.h
//  Smart
//
//  Created by sohn on 12-11-16.
//  Copyright (c) 2012年 Han.zhihong. All rights reserved.
//

#import <Foundation/Foundation.h>


//读写账号的读写配置文件
@interface ProjectAccountCfg: NSObject

//获取文档目录
+(NSString*) getFilePath;
//判断配置文件是否存在
+(BOOL)isFileExist;

//保存账户的一些登录信息,不包括密码,key是登录之后的通讯钥匙
+(BOOL)saveAccount:(NSString*)userid;
//通过WEB校检之后设置,验证有效是一小时,此时间内不用重复通过WEB验证
+(void)saveKeyAliveNow;
//获取有效时间,默认1800秒
+(time_t)getKeyAlive;
//获取加密钥匙
+(NSString*)getKey;

@end
