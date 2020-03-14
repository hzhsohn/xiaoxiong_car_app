//
//  Part_XMap_Cell_MSD.h
//  code
//
//  Created by Be-Service on 2019/12/24.
//  Copyright © 2019 Han.zhihong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Part_XMap_Cell_MSD : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *image_selected;
@property (weak, nonatomic) IBOutlet UILabel *device_name;
@property (weak, nonatomic) IBOutlet UILabel *device_label;
@property (weak, nonatomic) IBOutlet UILabel *device;


+(Part_XMap_Cell_MSD*)loadTableCell:(UITableView*)tableView;
@end

NS_ASSUME_NONNULL_END
