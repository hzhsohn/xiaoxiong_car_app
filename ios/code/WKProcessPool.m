//
//  WKProcessPool.m
//  code
//
//  Created by Han.zh on 2020/6/22.
//  Copyright © 2020 Han.zhihong. All rights reserved.
//

#import "WKProcessPool.h"

@implementation WKProcessPool(Share)

+(WKProcessPool*) sharedProcessPool
{
    static WKProcessPool* SharedProcessPool;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
    SharedProcessPool = [[WKProcessPool alloc] init];
    });
    return SharedProcessPool;
}

/*
+ (WKProcessPool *) singleWkProcessPool
{
    AFDISPATCH_ONCE_BLOCK(^{
        sharedPool = [[WKProcessPool alloc] init];
    })
    return sharedPool;
}
*/

@end
