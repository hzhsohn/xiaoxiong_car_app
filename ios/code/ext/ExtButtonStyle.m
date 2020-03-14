//
//  ExtendButton.m
//  BIMA
//
//

#import "ExtButtonStyle.h"

@implementation ExtButtonStyle

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGFloat imageX=contentRect.size.width-28;
    CGFloat imageY=0;
    CGFloat width=28;
    CGFloat height=27;
    return CGRectMake(imageX/2, imageY, width, height);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGFloat imageX=0;
    CGFloat imageY=37;
    CGFloat width=contentRect.size.width;
    CGFloat height=20;
    return CGRectMake(imageX, imageY, width, height);
}

@end
