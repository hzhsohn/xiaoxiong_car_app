//
//  LoginInfo.m
//  home
//
//  Created by Han.zh on 2017/7/3.
//  Copyright © 2017年 Han.zhihong. All rights reserved.
//

#import "LoginInfo.h"

//我的资料全局参数
NSMutableDictionary* g_MyInfo;

@implementation LoginInfo

+(void)set:(NSString*)str key:(NSString*)k
{
    if(nil==g_MyInfo)
    {
        g_MyInfo=[[NSMutableDictionary alloc] init];
    }
    [g_MyInfo setObject:str forKey:k];
}

+(void)clear
{
    if(g_MyInfo)
    {
        [g_MyInfo removeAllObjects];
        g_MyInfo=nil;
    }
}

+(NSString*)get:(NSString*)k
{
    if(g_MyInfo)
    {
        return [g_MyInfo objectForKey:k];
    }
    return nil;
}

+(void)remove:(NSString*)k
{
    if(g_MyInfo)
    {
        return [g_MyInfo removeObjectForKey:k];
    }
}
@end
