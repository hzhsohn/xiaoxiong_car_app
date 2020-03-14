//
//  Part_XMap_Cell_UserList.m
//  code
//
//  Created by Be-Service on 2019/12/20.
//  Copyright © 2019 Han.zhihong. All rights reserved.
//

#import "Part_XMap_Cell_UserList.h"

@implementation Part_XMap_Cell_UserList

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

+(Part_XMap_Cell_UserList*)loadTableCell:(UITableView*)tableView
{
        Part_XMap_Cell_UserList*cell = (Part_XMap_Cell_UserList *)[tableView
                                           dequeueReusableCellWithIdentifier: @"Part_XMap_Cell_UserList"];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"Part_XMap_Cell_UserList"
                                                         owner:self options:nil];
            // NSLog(@"nib %d",[nib count]);
            for (id oneObject in nib)
                if ([oneObject isKindOfClass:[Part_XMap_Cell_UserList class]])
                    cell = (Part_XMap_Cell_UserList *)oneObject;
        }
        return cell;
}

@end
