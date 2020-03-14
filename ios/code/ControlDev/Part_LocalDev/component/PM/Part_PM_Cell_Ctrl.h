//
//  DevListCell.h
//  discolor-led
//
//  Created by Han.zh on 15/2/7.
//  Copyright (c) 2015年 Han.zhihong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DevListCell.h"
#import "DeviceIDTemplate.h"

@protocol Part_PM_Cell_Delgate <NSObject>

-(void) Part_PM_Cell_Click:(NSInteger)cellRow btnIndex:(int)index;

@end


@interface THxkKG:NSObject
    @property (copy,nonatomic) NSString* channelName;
    @property (assign,nonatomic) BOOL isOn;
@end


@interface Part_PM_Cell_Ctrl : DevListCell

    @property (assign,nonatomic) NSInteger cellRow;
    -(void)setOnOff:(BOOL)b;
    -(void)setText:(NSString*)str;
    +(Part_PM_Cell_Ctrl*)loadTableCell:(UITableView*)tableView;
    @property (assign,nonatomic) id<Part_PM_Cell_Delgate> delegate;

@end
