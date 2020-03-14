//
//  UIView+LayerProperty.m
//  手势解锁测试
//
//  Created by 兴宇周 on 17/3/7.
//  Copyright © 2017年 兴宇周. All rights reserved.
//

#import "UIView+LayerProperty.h"

@implementation UIView (LayerProperty)
/**
 * 设置边框宽度
 *
 */
- (void)setBorderWidth:(CGFloat)borderWidth
{
    if(borderWidth <0) return;
    self.layer.borderWidth = borderWidth;
}

/**
 * 设置边框颜色
 */
- (void)setBorderColor:(UIColor *)borderColor
{
    self.layer.borderColor = borderColor.CGColor;
}

/**
 *  设置圆角
 */
- (void)setCornerRadius:(CGFloat)cornerRadius
{
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = cornerRadius >0;
}
@end
