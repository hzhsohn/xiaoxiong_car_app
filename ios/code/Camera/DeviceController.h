//
//  DeviceController.h
//  monitor
//
//  Created by Han Sohn on 12-7-9.
//  Copyright (c) 2012年 Han.zhihong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Objc_HostInfoMage.h"

@protocol DeviceControllerDelegate <NSObject>
//@optional
-(void) DeviceControllerSave_callback;
@end

@interface DeviceController : UIViewController
{
    unsigned long m_dwRecvLength;
    unsigned long m_dwBeginFlowSec;
    
    Objc_HostInfoMage       *m_pHostInfoMage;
    TagHostInfo             *m_pHostInfo;
    TNetworkType            *m_pNetType;
}

@property (nonatomic,assign) id<DeviceControllerDelegate> dev_delegate;

-(void) setInfo:(Objc_HostInfoMage *)hostInfoMage 
               :(TagHostInfo*)hostInfo 
               :(TNetworkType*)network;
@end
