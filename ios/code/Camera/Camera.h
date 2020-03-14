//
//  ViewController.h
//  monitor
//
//  Created by Han Sohn on 12-5-31.
//  Copyright (c) 2012年 Han.zhihong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceController.h"
#import "Objc_AudioPlay.h"
#import "Objc_DeviceMage.h"
#import "Objc_HostInfoMage.h"
#import "ModifyHostInfo.h"
#import "AddrTableCell_iPhone.h"

@interface Camera : UIViewController<DeviceControllerDelegate,AddrTableCell_iPhoneDelegate,ModifyHostInfo_iPhoneDelegate>
{
    ////////top view内控件
    __weak IBOutlet UILabel *lbNetwork;
    ///////
    __weak IBOutlet UITableView *tbAddr;
  
    __weak IBOutlet UIBarButtonItem *btnAdd;
    __weak IBOutlet UIBarButtonItem *btnEdit;
    
    //声音
    SystemSoundID m_soundSelectRow;
    
    Objc_DeviceMage *m_devMage;
    Objc_HostInfoMage *m_hostInfoMage;
    
    TNetworkType m_network;
}

-(IBAction) btnAdd_click:(id)sender;
-(IBAction) btnEdit_click:(id)sender;

@end
