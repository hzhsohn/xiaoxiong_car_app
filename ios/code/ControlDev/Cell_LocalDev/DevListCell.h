//
//  DevListCell.h
//  discolor-led
//
//  Created by Han.zh on 15/2/7.
//  Copyright (c) 2015年 Han.zhihong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DevListInfo.h"
#import "DevListInfo.h"

@interface DevListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgOnline;
@property (weak, nonatomic) IBOutlet UIImageView *imgLANOnline;
@property (weak, nonatomic) IBOutlet UIImageView *imgYUNOnline;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbRemark;
@property (nonatomic) NSInteger nAutoID;
@property (nonatomic,copy) NSString* devflag;
@property (nonatomic,assign) DevListInfo* pDevInfo;
@property (assign, nonatomic) NSInteger indexPathRow;
@property (assign, nonatomic) NSInteger IndexPathSection;

@property (weak, nonatomic) IBOutlet UILabel *lbUnknowDevflag;   //标识显示标签

-(void)setTitle:(NSString*)title;
-(void)setUnkonwDev:(BOOL)b;
-(void)setOnline:(BOOL)lanOnline :(BOOL)yunOnline;
+(DevListCell*)loadTableCell:(char*)flag Table:(UITableView*)tableView;

@end
