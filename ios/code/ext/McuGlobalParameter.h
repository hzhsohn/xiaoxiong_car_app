//
//  config_w1.m
//  discolor-led
//
//  Created by Han.zh on 15/3/8.
//  Copyright (c) 2015年 Han.zhihong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface McuGlobalParameter : NSObject

-(void)clearAllParameter;
-(void)setParameter:(NSString*)key :(id)p;
-(id)getParameter:(NSString*)key;


@end
