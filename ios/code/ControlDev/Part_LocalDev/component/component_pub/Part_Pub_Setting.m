//
//  Part_HXLED_Sub1.m
//  home
//
//  Created by Han.zh on 2017/3/21.
//  Copyright © 2017年 Han.zhihong. All rights reserved.
//

#import "Part_Pub_Setting.h"


@interface Part_Pub_Setting()
{
  
}
@end

@implementation Part_Pub_Setting

-(void)awakeFromNib
{
    [super awakeFromNib];
   
}

-(void)dealloc
{
    NSLog(@"Part_Pub_Setting dealloc");
}

//--------------------------------------------------------
//检测是否返回
- (void)didMoveToParentViewController:(UIViewController*)parent{
    [super didMoveToParentViewController:parent];
    if(!parent){
        //NSLog(@"页面pop成功了");
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
