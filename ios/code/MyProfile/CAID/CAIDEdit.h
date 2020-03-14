//
//  MyProfileBaseInfo.h
//  home
//
//  Created by Han.zh on 2017/4/25.
//  Copyright © 2017年 Han.zhihong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CAIDEdit : UITableViewController

@property (nonatomic,copy) NSString* strCAID;
@property (nonatomic,copy) NSString* strAutoid;
@property (nonatomic,copy) NSString* strTitle;

@property (weak, nonatomic) IBOutlet UILabel *lbCAID;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;

@end
