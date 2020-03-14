//
//  AddrTableCell.h
//  monitor
//
//  Created by Han Sohn on 12-5-31.
//  Copyright (c) 2012年 Han.zhihong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddrTableCell_iPhoneDelegate <NSObject>
//@optional
-(void) AddrTableCellbtnModify_click:(int)hostAutoID;
@end

@interface AddrTableCell_iPhone : UITableViewCell {
    UITableViewCellStateMask m_eState;
    float m_fBtnModiftMove;
    
}

-(IBAction) btnModify_click:(id)sender;

@property (nonatomic, assign) id<AddrTableCell_iPhoneDelegate> delegate;
@property (nonatomic, assign) int hostAutoID;
@property (nonatomic, retain) IBOutlet UIImageView *imgLogo;
@property (nonatomic, retain) IBOutlet UILabel *lbTitle;
@property (nonatomic, retain) IBOutlet UILabel *lbHost;
@property (nonatomic, retain) IBOutlet UILabel *lbPort;
@property (nonatomic, retain) IBOutlet UIButton *btnModify;
@end
