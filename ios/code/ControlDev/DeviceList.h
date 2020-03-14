//
//  DeviceList.h
//  discolor-led
//
//  Created by Han.zh on 15/2/7.
//  Copyright (c) 2015年 Han.zhihong. All rights reserved.
//  主要功能: 显示设备列表内容

#import <UIKit/UIKit.h>

/******************
 
 软件使用流程
 1.设备初始化接入到路由里面
 2.使用UDP探测可控制的硬件
 3.检测到硬件添加到TableView里面显示
 4.点击硬件名称,如果手机存在控制密码,即进入控制界面,如果手机没有硬件的控制密码那跳到添加密码的界面
 
 ******************/

@interface DeviceList : UIViewController

@end
