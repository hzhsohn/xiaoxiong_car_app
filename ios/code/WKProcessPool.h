//
//  WKProcessPool.h
//  code
//
//  Created by Han.zh on 2020/6/22.
//  Copyright © 2020 Han.zhihong. All rights reserved.
//

//! 导入WebKit框架头文件
#import <WebKit/WebKit.h>
#import "AlertCommand.h"
#import "JDDeviceUtils.h"


@interface WKProcessPool(Share)


+(WKProcessPool*) sharedProcessPool;

@end
