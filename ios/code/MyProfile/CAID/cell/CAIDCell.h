//
//  SearchCell.h
//  home
//
//  Created by Han.zh on 16/1/2.
//  Copyright © 2016年 Han.zhihong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CAIDCellDelegate <NSObject>

-(void)CAIDCell_Modify_click:(NSDictionary*)info;
-(void)CAIDCell_ShareKey_click:(NSDictionary*)info;

@end

@interface CAIDCell : UITableViewCell

@property (assign,nonatomic) NSDictionary *aryInfo;

@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbCAID;
@property (assign,nonatomic) id<CAIDCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *btnShare;

@end
