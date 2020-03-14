//
//  AccountManage.m
//  smart
//
//  Created by Han.zh on 14-8-6.
//  Copyright (c) 2014年 Han.zhihong. All rights reserved.
//

#import "ModifyPassword.h"
#import "HelpHeader.h"
#import "GlobalParameter.h"
#import "JSONKit.h"
#import "DefineHeader.h"
#import "WebBrower.h"
#import "WebProc.h"
#import "LoginInfo.h"

@interface ModifyPassword ()<WebPocDelegate>
{
    __weak IBOutlet UIActivityIndicatorView *ind;
    
    WebProc* _web;
    
    __weak IBOutlet UITextField *txtOldPwd;
    __weak IBOutlet UITextField *txtNewPwd;
    __weak IBOutlet UITextField *txtNewPwdDB;
}
- (IBAction)txtOnExit:(id)sender;
- (IBAction)btnModify_click:(id)sender;
@end

@implementation ModifyPassword

- (void)awakeFromNib{
    [super awakeFromNib];
    _web=[[WebProc alloc] init];
    _web.delegate=self;
    
}

-(void)dealloc
{
    _web.delegate=nil;
    _web=nil;
}

//左边插入文字
-(void)leftText:(UITextField*)target :(NSString*)title
{
    //左边插入LABEL文字
    UILabel *lb1;
    lb1=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 24)];
    [lb1 setText:title];
    [lb1 setTextAlignment:NSTextAlignmentLeft];
    target.leftView = lb1;
    target.leftViewMode = UITextFieldViewModeAlways;
    lb1=nil;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //初始化
    ind.alpha=0.0f;
    [ind setHidden:YES];
    
    //
    [self leftText:txtOldPwd :NSLocalizedString(@"Old Passwd:", nil)];
    [self leftText:txtNewPwd :NSLocalizedString(@"New Passwd:", nil)];
    [self leftText:txtNewPwdDB :NSLocalizedString(@"Confirm:", nil)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)txtOnExit:(id)sender {
    [(UITextField*)sender resignFirstResponder];
}

//////////////////////////////////
//网络回调
-(void) WebProcCallBackBegin:(NSURL*)url
{
    [ind setAlpha:1];
    [ind setHidden:NO];
    [ind startAnimating];
}
-(void) WebProcCallBackCookies:(NSURL*)url :(NSString*)cookie
{
    
}
-(void) WebProcCallBackData:(NSURL*)url :(NSData*)data
{
    [ind setAlpha:0];
    [ind setHidden:YES];
    [ind stopAnimating];
    
    NSLog(@"url=%@",[url relativeString]);
    NSString *page=[url lastPathComponent];
    NSLog(@"page=%@",page);
    
    NSData *safeJsonData = [_web getSafeJsonData:data];
    NSString *ss = [[NSString alloc] initWithData:safeJsonData encoding:NSUTF8StringEncoding];
   
    if (0==[safeJsonData length]) {
        return;
    }
    
    if([page isEqualToString:@"mod_passwd.i.php"])
    {
        //解释data
        NSDictionary *result = [safeJsonData objectFromJSONData];
        if(nil==result)
        {
            alert_err(@"json_data_fail",ss);
            return;
        }
        
        switch ([[result objectForKey:@"nRet"] intValue]) {
            case 1:
            {
                [ind setAlpha:0];
                [ind setHidden:YES];
                [self.navigationController popViewControllerAnimated:YES];
            }
                break;
            case 2://操作数据库失败
            {
                alert_ok(self, 0, @"alert", @"myprofile_operat_fail");
            }
                break;
            case 3://缺少参数
            {
                alert_ok(self, 0, @"alert", @"myprofile_lost_param");
            }
                break;
            case 4://key参数不正确
            {
                alert_ok(self, 0, @"alert", @"myprofile_key_invalid");
            }
                break;
            case 5://旧密码不对
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert", nil)
                                                                message:NSLocalizedString(@"The old password is incorrect", nil)
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                                      otherButtonTitles:nil];
                [alert show];
                alert=nil;
                //[alert release];
            }
                break;
        }
    }
}
-(void) WebProcCallBackFail:(NSURL*)url
{
    alert_ok(self, 0, @"alert", @"connect network fail.");
    
    [ind setAlpha:0];
    [ind setHidden:YES];
    [ind stopAnimating];
}


- (IBAction)btnModify_click:(id)sender
{
    if ([txtOldPwd.text length]<=0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert", nil)
                                                        message:NSLocalizedString(@"Password cannot be empty", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                              otherButtonTitles:nil];
        [alert show];
        alert=nil;
        return;
    }
    
    if ([txtNewPwd.text length]<=0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert", nil)
                                    message:NSLocalizedString(@"Password cannot be empty", nil)
                                   delegate:self
                          cancelButtonTitle:NSLocalizedString(@"ok", nil)
                          otherButtonTitles:nil];
        [alert show];
        alert=nil;
        return;
    }
    
    
    if (![txtNewPwd.text isEqualToString:txtNewPwdDB.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert", nil)
                                                        message:NSLocalizedString(@"The two password is different", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                              otherButtonTitles:nil];
        [alert show];
        alert=nil;
        return;
    }
    
    //更新记录
    NSString* str=[NSString stringWithFormat:@"k=%@&oldp=%@&newp=%@",
                   [GlobalParameter getLoginKey],
                   txtOldPwd.text,txtNewPwd.text];
    [_web sendData:[GlobalParameter getAccountAddrByMob:@"mod_passwd.i.php"] parameter:str];
}
@end

