//
//  DevListCell.m
//  discolor-led
//
//  Created by Han.zh on 15/2/7.
//  Copyright (c) 2015年 Han.zhihong. All rights reserved.
//

#import "Part_XMap_Cell_WallList.h"


@interface Part_XMap_Cell_WallList()
@end

@implementation Part_XMap_Cell_WallList

- (void)awakeFromNib {
    [super awakeFromNib];
}

+(Part_XMap_Cell_WallList*)loadTableCell:(UITableView*)tableView
{
        Part_XMap_Cell_WallList*cell = (Part_XMap_Cell_WallList *)[tableView
                                           dequeueReusableCellWithIdentifier: @"Part_XMap_Cell_WallList"];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"Part_XMap_Cell_WallList"
                                                         owner:self options:nil];
            // NSLog(@"nib %d",[nib count]);
            for (id oneObject in nib)
                if ([oneObject isKindOfClass:[Part_XMap_Cell_WallList class]])
                    cell = (Part_XMap_Cell_WallList *)oneObject;
        }
        return cell;
}

@end
