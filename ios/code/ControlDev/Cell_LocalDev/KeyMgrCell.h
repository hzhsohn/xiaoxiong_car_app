//
//  DevListCell.h
//  discolor-led
//
//  Created by Han.zh on 15/2/7.
//  Copyright (c) 2015年 Han.zhihong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KeyMgrCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *img;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbPasswd;
@property (weak, nonatomic) IBOutlet UILabel *lbTitleValue;
@property (weak, nonatomic) IBOutlet UILabel *lbPasswdValue;
@property (weak, nonatomic) IBOutlet UILabel *lbFlag;

@end
