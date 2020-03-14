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

@protocol ModifyHostInfo_iPhoneDelegate <NSObject>
//@optional
-(void) ModifyHostInfoResult:(TagHostInfo*)info;
@end

@interface ModifyHostInfo : UIViewController
{
    IBOutlet UITextField *txtTitle;
    IBOutlet UITextField *txtHost;
    IBOutlet UITextField *txtPort;
    IBOutlet UITextField *txtUsername;
    IBOutlet UITextField *txtPassword;
    TDevceID tDevID;
    
    TagHostInfo          *m_pHostInfo;
    ///////////////////////////////////
    IBOutlet UIButton *btnShowPick;
    IBOutlet UILabel *lbPickType;
    IBOutlet UIPickerView *pikType;
    
    Objc_DeviceMage *m_devMage;
}

@property (nonatomic,assign) id<ModifyHostInfo_iPhoneDelegate> delegate;

-(void) setInfo:(TagHostInfo*)hostInf;

-(IBAction) btnApply_click:(id)sender;
-(IBAction) txtDone:(id)sender;

@end
