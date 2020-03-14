//
//  ProjectSqlite.m
//  Smart
//
//  Created by sohn on 12-11-16.
//  Copyright (c) 2012年 Han.zhihong. All rights reserved.
//

#import "TempCfg.h"

//配置文件名
#define TEMP_CFG @"temp.cfg"

@implementation TempCfg

//document目录
+(NSString*) getFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString* str=[documentsDir stringByAppendingPathComponent:TEMP_CFG];
    //NSLog(@"account config=%@",str);
    return str;
}

+(BOOL)isFileExist
{
    NSFileManager *file_manager = [NSFileManager defaultManager];
    return [file_manager fileExistsAtPath:[self getFilePath]];
}

+(BOOL)set:(NSString*)cnt :(NSString*)key_name;
{
    NSString *configFile = [self getFilePath];
    NSMutableDictionary *configList =[[NSMutableDictionary alloc] initWithContentsOfFile:configFile];
    if (configList)
    {
        [configList setValue:cnt forKey:key_name];
    }
    else
    {
        configList = [[NSMutableDictionary alloc] initWithObjectsAndKeys:cnt,key_name,nil];
    }
    
    [configList writeToFile:configFile atomically:YES];
    
    if(configList)
    {
        configList=nil;
        //[configList release];
        return TRUE;
    }
    return FALSE;
}
//获取
+(NSString*)get:(NSString*)key_name;
{
    NSString* ret=NULL;
    NSString *configFile = [self getFilePath];
    NSMutableDictionary *configList =[[NSMutableDictionary alloc] initWithContentsOfFile:configFile];
    if (configList)
    {
        NSString *str=[configList objectForKey:key_name];
        if (str) {
            ret=[NSString stringWithString:str];
        }
    }
    //[configList release];
    configList=nil;
    return ret;
}
@end
