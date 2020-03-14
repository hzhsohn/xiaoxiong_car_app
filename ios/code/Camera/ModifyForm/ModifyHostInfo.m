//
//  AddHostInfo_iPhone.m
//  monitor
//
//  Created by Han Sohn on 12-6-8.
//  Copyright (c) 2012年 Han.zhihong. All rights reserved.
//

#import "ModifyHostInfo.h"


@implementation ModifyHostInfo
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        m_devMage=[[Objc_DeviceMage alloc] init];
    }
    return self;
}

-(void)dealloc
{
    m_devMage=nil;
    delegate=nil;
    
    NSLog(@"ModifyHostInfo dealloc");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    txtTitle.text=[NSString stringWithUTF8String:m_pHostInfo->title];
    txtHost.text=[NSString stringWithUTF8String:m_pHostInfo->host];
    txtPort.text=[NSString stringWithFormat:@"%d",m_pHostInfo->port];
    txtUsername.text=[NSString stringWithUTF8String:m_pHostInfo->username];
    txtPassword.text=[NSString stringWithUTF8String:m_pHostInfo->password];

    //当前的设备
    //TagDeviceInfo *dev=(TagDeviceInfo *)[m_devMage getByDevID:m_pHostInfo->devID];
    //[m_devMage getIndexByDevID:tDevID]
    
    self.navigationController.navigationBar.translucent = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    txtTitle=nil;
    txtHost=nil;
    txtPort=nil;
    txtUsername=nil;
    txtPassword=nil;
    
    btnShowPick=nil;
    lbPickType=nil;
    pikType=nil;
}

///////////////////////////////////////////
-(void) setInfo:(TagHostInfo*)hostInfo
{
    m_pHostInfo=hostInfo;
}

-(IBAction) btnApply_click:(id)sender
{
    char buf[10];
    strncpy(buf, [txtHost.text UTF8String], 5);
    if (0==strncmp(buf, "http:",5))
    {
        UIAlertView *alert_fail = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"addfrm_txtAddr_err", nil)
                                                              message:nil
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                                    otherButtonTitles:nil];
        [alert_fail show];
        alert_fail=nil;
        return;
    }
    
    if ([txtTitle.text isEqualToString:@""] || [txtHost.text isEqualToString:@""])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert", nil)
                                                        message:NSLocalizedString(@"addfrm_not_null", nil)
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
        
        [alert show];
        alert=nil;
        return;
    }
    
    if (0==[txtPort.text intValue]) 
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert", nil)
                                                        message:NSLocalizedString(@"addfrm_port_err", nil)
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
        
        [alert show];
        alert=nil;
        return;
    }
    
    //////////////////////////////////////////////
    TagHostInfo hostInfo={0};
    hostInfo.autoID=m_pHostInfo->autoID;
    strcpy(hostInfo.title,[txtTitle.text UTF8String]);
    strcpy(hostInfo.host,[txtHost.text UTF8String]);
    hostInfo.port=[txtPort.text intValue];
    hostInfo.devID=m_pHostInfo->devID;
    strcpy(hostInfo.username,[txtUsername.text UTF8String]);
    strcpy(hostInfo.password,[txtPassword.text UTF8String]);
    strcpy(hostInfo.parameter,"");
    
    [delegate ModifyHostInfoResult:&hostInfo];
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction) txtDone:(id)sender
{
    UITextField *txt=(UITextField*)sender;
    [txt resignFirstResponder];
}

@end
