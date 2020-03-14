//
//  ProjectSqlite.m
//  Smart
//
//  Created by sohn on 12-11-16.
//  Copyright (c) 2012年 Han.zhihong. All rights reserved.
//

#import "ProjectAccountCfg.h"

//配置文件名
#define CK_PROJECT_ACCOUNT_CFG @"account.cfg"

//WEB验证KEY后的验证时间,程序里设了半小时1800秒
time_t g_keyAliveTime=0;



@implementation ProjectAccountCfg

//document目录
+(NSString*) getFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString* str=[documentsDir stringByAppendingPathComponent:CK_PROJECT_ACCOUNT_CFG];
    //NSLog(@"account config=%@",str);
    return str;
}

+(BOOL)isFileExist
{
    NSFileManager *file_manager = [NSFileManager defaultManager];
    return [file_manager fileExistsAtPath:[self getFilePath]];
}

//保存账户的一些登录信息,不包括密码,key是登录之后的通讯钥匙
+(BOOL)saveAccount:(NSString*)key
{
    NSString *configFile = [self getFilePath];
    NSMutableDictionary *configList =[[NSMutableDictionary alloc] initWithContentsOfFile:configFile];  //初始化字典，读取配置文件的信息
    
    //第二:写入文件
    if (configList)
    {
        [configList setValue:key forKey:@"key"];
    }
    else
    {
        //
        configList = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                      key,  @"key",
                      nil];
    }
    
    [configList writeToFile:configFile atomically:YES];
    
    if(configList)
    {
        configList=nil;
        //[configList release];
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}

//通过WEB校检之后设置,验证有效是一小时,此时间内不用重复通过WEB验证
+(void)saveKeyAliveNow
{
    g_keyAliveTime=time(NULL);
}

//获取有效时间
+(time_t)getKeyAlive
{
    return g_keyAliveTime;
}

//获了加密钥匙
+(NSString*)getKey
{
    NSString* ret=NULL;
    NSString *configFile = [self getFilePath];
    NSMutableDictionary *configList =[[NSMutableDictionary alloc] initWithContentsOfFile:configFile];
    if (configList)
    {
        NSString *str=[configList objectForKey:@"key"];
        if (str) {
            ret=[NSString stringWithString:str];
        }
    }
    //[configList release];
    configList=nil;
    return ret;
}

@end
