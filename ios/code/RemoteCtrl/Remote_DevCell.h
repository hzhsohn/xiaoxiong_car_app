//
//  DevListCell.h
//  discolor-led
//
//  Created by Han.zh on 15/2/7.
//  Copyright (c) 2015年 Han.zhihong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Remote_DevCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgOnline;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (nonatomic,copy) NSString* devflag;
@property (nonatomic,copy) NSString* uuid;
@property (weak, nonatomic) IBOutlet UILabel *lbOnline;

-(void)setOnline:(BOOL)b;

@end
