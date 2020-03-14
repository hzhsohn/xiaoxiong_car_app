//
//  AddHostInfo_iPhone.m
//  monitor
//
//  Created by Han Sohn on 12-6-8.
//  Copyright (c) 2012年 Han.zhihong. All rights reserved.
//

#import "AddHostInfo_mjpeg.h"

@implementation AddHostInfo_mjpeg
@synthesize delegate;

-(void)awakeFromNib
{
    [super awakeFromNib];
    // Custom initialization
    m_devMage=[[Objc_DeviceMage alloc] init];
    
    m_infoMage=[[Objc_HostInfoMage alloc] init];
}

-(void)dealloc
{
    NSLog(@"AddHostInfo_mjpeg dealloc");
    m_infoMage=nil;
    
    m_devMage=nil;
    delegate=nil;
    
    txtTitle=nil;
    txtHost=nil;
    txtPort=nil;
    txtUsername=nil;
    txtPassword=nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //
    [self leftText:txtTitle :NSLocalizedString(@"标题:",nil)];
    [self leftText:txtHost :NSLocalizedString(@"域名IP:",nil)];
    [self leftText:txtPort :NSLocalizedString(@"端口:",nil)];
    [self leftText:txtUsername :NSLocalizedString(@"用户名:",nil)];
    [self leftText:txtPassword :NSLocalizedString(@"密码:",nil)];
}

//左边插入文字
-(void)leftText:(UITextField*)target :(NSString*)title
{
    //左边插入LABEL文字
    UILabel *lb1;
    lb1=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 90, 24)];
    [lb1 setText:title];
    [lb1 setTextAlignment:NSTextAlignmentRight];
    target.leftView = lb1;
    target.leftViewMode = UITextFieldViewModeAlways;
    lb1=nil;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @" ";
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
    strcpy(hostInfo.title,[txtTitle.text UTF8String]);
    strcpy(hostInfo.host,[txtHost.text UTF8String]);
    hostInfo.port=[txtPort.text intValue];
    hostInfo.devID=MONITOR_DEVICE_ID_MJPEG;
    strcpy(hostInfo.username,[txtUsername.text UTF8String]);
    strcpy(hostInfo.password,[txtPassword.text UTF8String]);
    strcpy(hostInfo.parameter,"");
    
    if ([m_infoMage insertHostInfo:hostInfo.title
                                  :hostInfo.host
                                  :hostInfo.port
                                  :hostInfo.devID
                                  :hostInfo.username
                                  :hostInfo.password
                                  :hostInfo.parameter])
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert", nil)
                                                        message:NSLocalizedString(@"sqlite_read_fail", nil)
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
        
        [alert show];
        alert=nil;
    }
}

-(IBAction) txtDone:(id)sender
{
    UITextField *txt=(UITextField*)sender;
    [txt resignFirstResponder];
}

@end
