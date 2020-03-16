//
//  GlobalParameter.m
//  Smart
//
//  Created by sohn on 12-12-31.
//  Copyright (c) 2012年 Han.zhihong. All rights reserved.
//

#import "GlobalParameter.h"
#import "ProjectAccountCfg.h"
#import "DefineHeader.h"

//账户信息
TckUserlist g_accountInfo={0};

@implementation GlobalParameter
//--------------------------------------------
+ (NSString*) documentPath:(NSString*)str
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    if (nil!=str) {
        return [NSString stringWithFormat:@"%@/%@",documentsDirectory,str];
    }
    return [NSString stringWithFormat:@"%@",documentsDirectory];
}
+(void)setLoginKey:(NSString*)key
{
    strcpy(g_accountInfo.key, [key UTF8String]);
}
+(NSString*)getLoginKey
{
    return [NSString stringWithUTF8String:g_accountInfo.key];
}
//删除配置文件清空登录信息
+(void)clearLoginCfg
{
    memset(&g_accountInfo, 0, sizeof(TckUserlist));
    remove([[ProjectAccountCfg getFilePath] UTF8String]);
    remove([[self documentPath:@"CAID.cfg"] UTF8String]);
}
+ (NSString*) createUserIconLocalPath:(NSString*)userid
{
    NSString *dir=[self documentPath:[NSString stringWithFormat:@"u_icon"]];
    if(access([dir UTF8String], 0))
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *str=[self documentPath:[NSString stringWithFormat:@"u_icon/%@.jpg",userid]];
    return str;
}
+ (NSString*) getUserIconLocalPath:(NSString*)userid
{
    NSString *dir=[self documentPath:[NSString stringWithFormat:@"u_icon"]];
    if(access([dir UTF8String], 0))
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *str=[self documentPath:[NSString stringWithFormat:@"u_icon/%@.jpg",userid]];
    if (0==access([str UTF8String], 0)) {
        return str;
    }
    return nil;
}

+(NSString*) getAccountAddrByICON:(NSString*)userid
{
    return [NSString stringWithFormat:@"%@/u_icon/%@.jpg",ACCOUNT_URL,userid];
}

+(NSString*) getAccountAddrByMob:(NSString*)page
{
    return [NSString stringWithFormat:@"%@/_j0/%@",ACCOUNT_URL,page];
}

+(NSString*) getAccountAddrBySMS:(NSString*)page
{
    return [NSString stringWithFormat:@"%@/_sms/%@",ACCOUNT_URL,page];
}

+(NSString*) getIOTAddrByInfo:(NSString*)page
{
    return [NSString stringWithFormat:@"%@/_j1/%@",IOT_URL_INFO,page];
}

@end
