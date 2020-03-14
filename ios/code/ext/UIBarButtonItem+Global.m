//
//  UIBarButtonItem+Global.m
//  home
//
//  Created by 兴宇周 on 17/1/4.
//  Copyright © 2017年 Han.zhihong. All rights reserved.
//

#import "UIBarButtonItem+Global.h"

@implementation UIBarButtonItem (Global)
+ (void)imageName:(NSString *)name size:(CGSize)size{
    
    UIButton * btn = [[UIButton alloc]init];
    [btn setImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
    btn.frame = CGRectMake(0, 0, 24, 24);
}
@end
