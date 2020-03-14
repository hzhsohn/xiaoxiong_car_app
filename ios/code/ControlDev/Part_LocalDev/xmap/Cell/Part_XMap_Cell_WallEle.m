//
//  DevListCell.m
//  discolor-led
//
//  Created by Han.zh on 15/2/7.
//  Copyright (c) 2015年 Han.zhihong. All rights reserved.
//

#import "Part_XMap_Cell_WallEle.h"


@interface Part_XMap_Cell_WallEle()
@end

@implementation Part_XMap_Cell_WallEle

- (void)awakeFromNib {
    [super awakeFromNib];
}

+(Part_XMap_Cell_WallEle*)loadTableCell:(UITableView*)tableView
{
        Part_XMap_Cell_WallEle*cell = (Part_XMap_Cell_WallEle *)[tableView
                                           dequeueReusableCellWithIdentifier: @"Part_XMap_Cell_WallEle"];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"Part_XMap_Cell_WallEle"
                                                         owner:self options:nil];
            // NSLog(@"nib %d",[nib count]);
            for (id oneObject in nib)
                if ([oneObject isKindOfClass:[Part_XMap_Cell_WallEle class]])
                    cell = (Part_XMap_Cell_WallEle *)oneObject;
        }
        return cell;
}

@end
