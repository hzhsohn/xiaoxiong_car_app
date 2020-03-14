//
//  config_w1.m
//  discolor-led
//
//  Created by Han.zh on 15/3/8.
//  Copyright (c) 2015年 Han.zhihong. All rights reserved.
//

#import "McuGlobalParameter.h"

@interface McuGlobalParameter ()
{
    NSMutableDictionary* lstP;
}

@end

@implementation McuGlobalParameter

-(id)init
{
    if(self=[super init])
    {
        lstP=[[NSMutableDictionary alloc] init];
        return self;
    }
    return nil;
}

-(void)dealloc
{
    [lstP removeAllObjects];
    lstP=nil;
}

-(void)clearAllParameter
{
    [lstP removeAllObjects];
}
-(void)setParameter:(NSString*)key :(id)p
{
    [lstP setObject:p forKey:key];
}
-(id)getParameter:(NSString*)key
{
    return [lstP objectForKey:key];
}

@end
