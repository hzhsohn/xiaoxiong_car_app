//
//  AddHostInfo_iPhone.h
//  monitor
//
//  Created by Han Sohn on 12-6-8.
//  Copyright (c) 2012年 Han.zhihong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Objc_DeviceMage.h"
#import "Objc_HostInfoMage.h"

@protocol AddHostInfo_iPhoneDelegate <NSObject>
//@optional
-(void) AddHostInfoResult:(TagHostInfo*)info;

@end

@interface AddHostInfo_vb_c50fsi : UITableViewController
{
    IBOutlet UITextField *txtTitle;
    IBOutlet UITextField *txtHost;
    IBOutlet UITextField *txtPort;
    IBOutlet UITextField *txtUsername;
    IBOutlet UITextField *txtPassword;

    Objc_DeviceMage *m_devMage;
    Objc_HostInfoMage *m_infoMage;
}

@property (nonatomic,assign) id<AddHostInfo_iPhoneDelegate> delegate;
-(void)leftText:(UITextField*)target :(NSString*)title;
-(IBAction) btnApply_click:(id)sender;
-(IBAction) txtDone:(id)sender;

@end
