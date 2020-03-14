//
//  LoginInfo.h
//  home
//
//  Created by Han.zh on 2017/7/3.
//  Copyright © 2017年 Han.zhihong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginInfo : NSObject

+(void)set:(NSString*)str key:(NSString*)k;
+(void)clear;
+(NSString*)get:(NSString*)k;
+(void)remove:(NSString*)k;
@end
