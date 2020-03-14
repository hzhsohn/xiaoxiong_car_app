//
//  DevListCell.m
//  discolor-led
//
//  Created by Han.zh on 15/2/7.
//  Copyright (c) 2015年 Han.zhihong. All rights reserved.
//

#import "Remote_DevCell.h"

@implementation Remote_DevCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

-(void)dealloc
{
}

-(void)setOnline:(BOOL)b
{
    UIImage*t=[UIImage imageNamed:@"devlst_cell_online1"];
    UIImage*f=[UIImage imageNamed:@"devlst_cell_online0"];
    self.lbOnline.text=b?NSLocalizedString(@"online", nil):NSLocalizedString(@"offline", nil);
    if(t&&f)
    {
        self.imgOnline.backgroundColor=[UIColor clearColor];
        self.imgOnline.image=b?t:f;
    }
    else
    {
        self.imgOnline.backgroundColor=b?[UIColor greenColor]:[UIColor lightGrayColor];
    }
}

@end
