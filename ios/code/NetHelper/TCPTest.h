//
//  TCPTest.h
//  hx-home
//
//  Created by Han.zh on 16/4/6.
//  Copyright © 2016年 Han.zhihong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TCPTest : UIViewController

//默认IP信息
@property(nonatomic,copy)NSString* def_ip;
@property(nonatomic,assign)int def_port;

//清空日志
-(void)clearMessage;

//关闭服务
-(void)closeService;

@end
