//
//  XMBaseStatus.m
//  libxmap_Demo
//
//  Created by Han.zh on 2019/12/11.
//  Copyright © 2019 Han.zhihong. All rights reserved.
//

#import "XMBaseStatus.h"

XMBaseStatus g_XMBaseStatus;


//------------------------
void xmapShowAlert(id s,NSString* str)
{
    //显示提示框
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:str
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              //响应事件
                                                              NSLog(@"action = %@", action);
                                                          }];
    [alert addAction:defaultAction];
    [s presentViewController:alert animated:YES completion:nil];
}
