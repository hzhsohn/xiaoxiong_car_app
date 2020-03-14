//
//  _Help_Header_h_
//  home
//
//  Created by Han.zh on 2017/3/2.
//  Copyright © 2017年 Han.zhihong. All rights reserved.
//

#import "HelpHeader.h"
#include <sys/time.h>
#include <stddef.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/wait.h>

void alert_ok_non(id sel,NSInteger tag,NSString* title,NSString* str)
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:str
                                                   delegate:sel
                                          cancelButtonTitle:nil
                                          otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
    alert.tag=tag;
    [alert show];
    alert=nil;
}

void alert_ok(id sel,NSInteger tag,NSString* nsl_title,NSString* nsl_str)
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(nsl_title, nil)
                                                    message:NSLocalizedString(nsl_str, nil)
                                                   delegate:sel
                                          cancelButtonTitle:nil
                                          otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
    alert.tag=tag;
    [alert show];
    alert=nil;
}

void alert_err(NSString* nsl_title,NSString* nsl_str)
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(nsl_title, nil)
                                                    message:NSLocalizedString(nsl_str, nil)
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
    
    [alert show];
    alert=nil;
}

void dev_err(NSString* str)
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"APP开发错误"
                                                    message:str
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:NSLocalizedString(@"ok", nil), nil];

    [alert show];
    alert=nil;
}

DWORD platGetTime()
{
    /* linux */
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return (tv.tv_sec*1000+tv.tv_usec/1000);
}
