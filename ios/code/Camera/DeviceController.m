//
//  DeviceController.m
//  monitor
//
//  Created by Han Sohn on 12-7-9.
//  Copyright (c) 2012年 Han.zhihong. All rights reserved.
//

#import "DeviceController.h"
#import "assist_function.h"
#import "dh_platform.h"

@interface DeviceController ()

@end

@implementation DeviceController
@synthesize dev_delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        m_pHostInfoMage=nil;
        m_pHostInfo=nil;
        m_pNetType=nil;
        
        //flow data
        m_dwRecvLength=0;
        m_dwBeginFlowSec=time(NULL);
    }
    return self;
}

-(void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

-(void) dealloc
{
}

-(void) setInfo:(Objc_HostInfoMage *)hostInfoMage 
               :(TagHostInfo*)hostInfo 
               :(TNetworkType*)network
{
    m_pHostInfoMage=hostInfoMage;
    m_pHostInfo=hostInfo;
    m_pNetType=network;
}

@end
