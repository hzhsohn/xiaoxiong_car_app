//
//  WKProcessPool.h
//  code
//
//  Created by Han.zh on 2020/6/22.
//  Copyright © 2020 Han.zhihong. All rights reserved.
//

#import <Foundation/Foundation.h>
//! 导入WebKit框架头文件
#import <WebKit/WebKit.h>
#import "AlertCommand.h"
#import "JDDeviceUtils.h"


NS_ASSUME_NONNULL_BEGIN

@interface WKProcessPool (SharedProcessPool)

+(WKProcessPool*)sharedProcessPool;

@end

NS_ASSUME_NONNULL_END
