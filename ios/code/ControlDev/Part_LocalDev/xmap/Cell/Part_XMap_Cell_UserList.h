//
//  Part_XMap_Cell_UserList.h
//  code
//
//  Created by Be-Service on 2019/12/20.
//  Copyright © 2019 Han.zhihong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Part_XMap_Cell_UserList : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *desc;

@property (assign,nonatomic) NSInteger cellRow;
+(Part_XMap_Cell_UserList*)loadTableCell:(UITableView*)tableView;
@end

NS_ASSUME_NONNULL_END
