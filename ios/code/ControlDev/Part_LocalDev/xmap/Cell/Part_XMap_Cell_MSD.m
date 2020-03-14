//
//  Part_XMap_Cell_MSD.m
//  code
//
//  Created by Be-Service on 2019/12/24.
//  Copyright © 2019 Han.zhihong. All rights reserved.
//

#import "Part_XMap_Cell_MSD.h"

@implementation Part_XMap_Cell_MSD

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

+(Part_XMap_Cell_MSD*)loadTableCell:(UITableView*)tableView
{
        Part_XMap_Cell_MSD*cell = (Part_XMap_Cell_MSD *)[tableView
                                           dequeueReusableCellWithIdentifier: @"Part_XMap_Cell_MSD"];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"Part_XMap_Cell_MSD"
                                                         owner:self options:nil];
            // NSLog(@"nib %d",[nib count]);
            for (id oneObject in nib)
                if ([oneObject isKindOfClass:[Part_XMap_Cell_MSD class]])
                    cell = (Part_XMap_Cell_MSD *)oneObject;
        }
        return cell;
}

@end
