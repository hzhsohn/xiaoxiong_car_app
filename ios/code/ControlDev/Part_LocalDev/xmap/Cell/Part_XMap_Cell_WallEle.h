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

@interface Part_XMap_Cell_WallEle : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *img1;
@property (weak, nonatomic) IBOutlet UILabel *txt1;
@property (weak, nonatomic) IBOutlet UILabel *txt2;

    @property (assign,nonatomic) NSInteger cellRow;
    +(Part_XMap_Cell_WallEle*)loadTableCell:(UITableView*)tableView;

@end
