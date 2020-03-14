//
//  _Help_Header_h_
//  home
//
//  Created by Han.zh on 2017/3/2.
//  Copyright © 2017年 Han.zhihong. All rights reserved.
//
#ifndef _Help_Header_h_
#define _Help_Header_h_

#import <UIKit/UIKit.h>

#define DWORD unsigned long

void alert_ok_non(id sel,NSInteger tag,NSString* title,NSString* str);
void alert_ok(id sel,NSInteger tag,NSString* nsl_title,NSString* nsl_str);

void alert_err(NSString* nsl_title,NSString* nsl_str);
void dev_err(NSString* str);

//获取毫秒
DWORD platGetTime();

#endif /* _Help_Header_h_ */
