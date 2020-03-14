//
//  SearchCell.m
//  home
//
//  Created by Han.zh on 16/1/2.
//  Copyright © 2016年 Han.zhihong. All rights reserved.
//

#import "CAIDCell.h"

@interface CAIDCell()
{
   
}
- (IBAction)btnEdit:(id)sender;
- (IBAction)btnShare:(id)sender;

@end

@implementation CAIDCell

-(void)dealloc
{
    self.delegate=nil;
}

- (IBAction)btnEdit:(id)sender {
    [self.delegate CAIDCell_Modify_click:self.aryInfo];
}

- (IBAction)btnShare:(id)sender {
    [self.delegate CAIDCell_ShareKey_click:self.aryInfo];
}
@end
