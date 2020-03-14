//
//  McuKeyGen.h
//  McuNet
//
//  Created by Han.zh on 2017/12/6.
//  Copyright © 2017年 Han.zhihong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface McuKeyGen : NSObject

+(void) genKey:(char[6])dstKey_6byte :(NSString*)password;

@end
