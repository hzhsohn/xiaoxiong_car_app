//
//  MD5File.m
//  home
//
//  Created by Han.zh on 2017/9/11.
//  Copyright © 2017年 Han.zhihong. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FileHashDefaultChunkSizeForReadingData 1024*8
#include <CommonCrypto/CommonDigest.h>

@interface MD5File : NSObject

+(NSString*)getFileMD5WithPath:(NSString*)path;

@end
