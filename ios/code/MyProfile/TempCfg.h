//
//  ProjectSqlite.h
//  Smart
//
//  Created by sohn on 12-11-16.
//  Copyright (c) 2012年 Han.zhihong. All rights reserved.
//

#import <Foundation/Foundation.h>


//读写账号的读写配置文件
@interface TempCfg: NSObject

//获取文档目录
+(NSString*) getFilePath;
//判断配置文件是否存在
+(BOOL)isFileExist;

//保存
+(BOOL)set:(NSString*)cnt :(NSString*)key_name;

//获取
+(NSString*)get:(NSString*)key_name;

@end
