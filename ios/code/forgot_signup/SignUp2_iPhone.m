//
//  SignUp2_iPhone.m
//  smart
//
//  Created by Han.zh on 14-8-21.
//  Copyright (c) 2014年 Han.zhihong. All rights reserved.
//

#import "SignUp2_iPhone.h"
#import "HelpHeader.h"
#import "ProjectAccountCfg.h"
#import "GlobalParameter.h"
#import "JSONKit.h"
#import "SignUpFail_iPhone.h"
#import "SignUpDone_iPhone.h"

@interface SignUp2_iPhone ()
{
    __weak IBOutlet UIActivityIndicatorView *ind;
    __weak IBOutlet UIButton *nextBtn;
}
@end

@implementation SignUp2_iPhone


- (void)awakeFromNib{
    [super awakeFromNib];
    _sEmail=[[NSMutableString alloc] init];
    _sNickname=[[NSMutableString alloc] init];
    
    _web=[[WebProc alloc] init];
    _web.delegate=self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [_txtPassword1 becomeFirstResponder];
    nextBtn.layer.masksToBounds = true;
    nextBtn.layer.cornerRadius = 4;//设置那个圆角的有多圆
    //初始化
    [ind setBounds:CGRectMake(0, 0, 130, 130)];
    [ind setBackgroundColor:[UIColor grayColor]];
    ind.alpha=0.0f;
    ind.layer.cornerRadius = 10;//设置那个圆角的有多圆
    ind.layer.borderWidth = 0;//设置边框的宽度
    [ind setHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    /*
    NSLog(@"segue.identifier=%@",segue.identifier);
    if ([segue.identifier isEqualToString:@"segueSignUpDone"]) {
        SignUpDone_iPhone* frm=(SignUpDone_iPhone*)segue.destinationViewController;
    }*/
}


-(void)setInfo:(NSString*)email :(NSString*)nick
{
    [_sEmail setString:email];
    [_sNickname setString:nick];
}

- (IBAction)btnSave_click:(id)sender
{
    if ([_txtPassword1.text isEqualToString:@""] || [_txtPassword2.text isEqualToString:@""])
    {
        //密码为空
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"alert", nil)
                              message:NSLocalizedString(@"Password cannot be empty", nil)
                              delegate:self
                              cancelButtonTitle:NSLocalizedString(@"ok", nil)
                              otherButtonTitles:nil];
        [alert show];
        alert=nil;
        //[alert release];
        return;
    }
    
    //判断两次密码是否一样
    if ([_txtPassword1.text isEqualToString:_txtPassword2.text]) {
        //注册
        NSString* str=[NSString stringWithFormat:@"p=%@&nick=%@&em=%@",_txtPassword1.text,_sNickname,_sEmail];
        [_web sendData:[GlobalParameter getAccountAddrByMob:@"reg_by_email.i.php"] parameter:str];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"alert", nil)
                              message:NSLocalizedString(@"signup_password_different", nil)
                              delegate:self
                              cancelButtonTitle:NSLocalizedString(@"ok", nil)
                              otherButtonTitles:nil];
        [alert show];
        alert=nil;
        //[alert release];
    }
    
}

- (void)dealloc {
    //[_sEmail release];
    //[_sNickname release];
    //[_txtPassword1 release];
    //[_txtPassword2 release];
    //[_web release];
    
    _sEmail=nil;
    _sNickname=nil;
    _txtPassword1=nil;
    _txtPassword2=nil;
    
    _web.delegate=nil;
    _web=nil;
    
    //[super dealloc];
    
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
    NSLog(@"url=%@",[url relativeString]);
    NSString *page=[url lastPathComponent];
    NSLog(@"page=%@",page);
    
    NSData *safeJsonData = [_web getSafeJsonData:data];
    NSString *ss = [[NSString alloc] initWithData:safeJsonData encoding:NSUTF8StringEncoding];
    
    if (0==[safeJsonData length]) {
        return;
    }
    
    if([page isEqualToString:@"reg_by_email.i.php"])
    {
        //解释data
        NSDictionary *result = [safeJsonData objectFromJSONData];
        if(nil==result)
        {
            alert_err(@"json_data_fail",ss);
            goto _nnc;
        }
        
        switch ([[result objectForKey:@"nRet"] intValue]) {
            case 1://成功
            {
                [self performSegueWithIdentifier:@"segueSignUpDone" sender:self];
            }
                break;
            case 2://邮箱格式不对
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert", nil)
                                        message:NSLocalizedString(@"signup_email_err", nil)
                                       delegate:self
                              cancelButtonTitle:NSLocalizedString(@"ok", nil)
                              otherButtonTitles:nil];
                [alert show];
                alert=nil;
                //[alert release];
            }
                break;
            case 3://邮箱为空
            {
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert", nil)
                                    message:NSLocalizedString(@"signup_email_not_null", nil)
                                   delegate:self
                          cancelButtonTitle:NSLocalizedString(@"ok", nil)
                          otherButtonTitles:nil];
                [alert show];
                alert=nil;
                //[alert release];
            }
                break;
            case 4://呢称为空
            {
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert", nil)
                                        message:NSLocalizedString(@"signup_nick_not_null", nil)
                                       delegate:self
                              cancelButtonTitle:NSLocalizedString(@"ok", nil)
                              otherButtonTitles:nil];
                [alert show];
                alert=nil;
                //[alert release];
            }
                break;
            case 5://密码为空
            {
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert", nil)
                                    message:NSLocalizedString(@"Password cannot be empty", nil)
                                   delegate:self
                          cancelButtonTitle:NSLocalizedString(@"ok", nil)
                          otherButtonTitles:nil];
                [alert show];
                alert=nil;
                //[alert release];
            }
                break;
            case 6:// 操作失败
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert", nil)
                                    message:NSLocalizedString(@"signup_operat_fail", nil)
                                   delegate:self
                          cancelButtonTitle:NSLocalizedString(@"ok", nil)
                          otherButtonTitles:nil];
                [alert show];
                alert=nil;
                //[alert release];
            }
                break;
            case 7://用户ID已经存在
            {
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert", nil)
                                    message:NSLocalizedString(@"signup_userid_repeat", nil)
                                   delegate:self
                          cancelButtonTitle:NSLocalizedString(@"ok", nil)
                          otherButtonTitles:nil];
                [alert show];
                alert=nil;
                //[alert release];
            }
                break;
            case 8://用户已经被注册
            {
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert", nil)
                                                            message:NSLocalizedString(@"signup_account_repeat", nil)
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                                  otherButtonTitles:nil];
                [alert show];
                alert=nil;
                //[alert release];
            }
                break;
            default:
                break;
        }
        
    }
    
_nnc:
    [ind setAlpha:0];
    [ind setHidden:YES];
    [ind stopAnimating];
}
-(void) WebProcCallBackFail:(NSURL*)url
{
    alert_ok(self, 0, @"alert", @"connect network fail.");
    
    [ind setAlpha:0];
    [ind setHidden:YES];
    [ind stopAnimating];
}


@end
