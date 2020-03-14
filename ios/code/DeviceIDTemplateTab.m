//
//  CtrlMain_w1.m
//  discolor-led
//
//  Created by Han.zh on 15/2/17.
//  Copyright (c) 2015年 Han.zhihong. All rights reserved.
//

#import "DeviceIDTemplateTab.h"

@interface DeviceIDTemplateTab ()


@end

@implementation DeviceIDTemplateTab

-(void) setInfo:(NSString*)devname :(NSString*)host :(int)port;
{
    self.devName=devname;
    self.host=host;
    self.port=port;
    
    NSLog(@"self.devName=%@\nself.host=%@\nself.port=%d",self.devName,self.host,self.port);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

-(void)dealloc
{
    self.devName=nil;
    self.host=nil;
    self.port=0;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //设置标题,颜色和字体大小
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [UIColor whiteColor],NSForegroundColorAttributeName,
                          [UIFont systemFontOfSize:16.0],NSFontAttributeName,
                          nil];
    [self.navigationController.navigationBar setTitleTextAttributes:dict];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
 */


@end
