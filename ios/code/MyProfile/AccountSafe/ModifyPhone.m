//
//  AccountManage.m
//  smart
//
//  Created by Han.zh on 14-8-6.
//  Copyright (c) 2014年 Han.zhihong. All rights reserved.
//

#import "ModifyPhone.h"
#import "HelpHeader.h"
#import "GlobalParameter.h"
#import "JSONKit.h"
#import "DefineHeader.h"
#import "WebBrower.h"
#import "WebProc.h"
#import "LoginInfo.h"

@interface ModifyPhone ()<WebPocDelegate>
{
    __weak IBOutlet UIActivityIndicatorView *ind;
    __weak IBOutlet UITextField *txtPhone;
    __weak IBOutlet UITextField *txtVCode;
    
    __weak IBOutlet UIButton *btnGetSMS;
    WebProc* _web;
    
    BOOL isCheckCodeOK;
    
    int SMS_Last_Time;
    NSTimer* timer;
    
}

- (IBAction)txtOnExit:(id)sender;
- (IBAction)btnModify_click:(id)sender;
- (IBAction)btnSMS_click:(id)sender;

@end

@implementation ModifyPhone

- (void)awakeFromNib{
    [super awakeFromNib];
    _web=[[WebProc alloc] init];
    _web.delegate=self;
    isCheckCodeOK=FALSE;
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
    lb1=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 24)];
    [lb1 setText:title];
    [lb1 setTextAlignment:NSTextAlignmentLeft];
    target.leftView = lb1;
    target.leftViewMode = UITextFieldViewModeAlways;
    lb1=nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString* nickname;
    nickname=[LoginInfo get:@"phone"];
    txtPhone.text=nickname;
    
    //初始化
    [ind setBackgroundColor:[UIColor grayColor]];
    ind.alpha=0.0f;
    ind.layer.cornerRadius = 0;//设置那个圆角的有多圆
    ind.layer.borderWidth = 0;//设置边框的宽度
    [ind setHidden:YES];
    
    //
    [self leftText:txtPhone :NSLocalizedString(@"Mobile:",nil)];
    [self leftText:txtVCode :NSLocalizedString(@"SMS Code:",nil)];
    [btnGetSMS setTitle:NSLocalizedString(@"Get SMS",nil) forState:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//--------------------------------------------------------
//检测是否返回
- (void)willMoveToParentViewController:(UIViewController*)parent{
    [super willMoveToParentViewController:parent];
    NSLog(@"%s,%@",__FUNCTION__,parent);
}
- (void)didMoveToParentViewController:(UIViewController*)parent{
    [super didMoveToParentViewController:parent];
    NSLog(@"%s,%@",__FUNCTION__,parent);
    if(!parent){
        NSLog(@"页面pop成功了");
        if(timer)
        {
            [timer invalidate];
            timer = nil;
        }
    }
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
    
    if([page isEqualToString:@"mod_phone.i.php"])
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
                [LoginInfo set:txtPhone.text key:@"phone"];
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
        }
    }
    else if([page isEqualToString:@"vcode_modify_phone_number.i.php"])
    {
        txtPhone.enabled=true;
        
        //解释data
        NSDictionary *result = [safeJsonData objectFromJSONData];
        if(result)
        {
            NSDictionary *dd=[result objectForKey:@"rsp"];
            if(dd)
            {
                NSString*anc=[dd objectForKey:@"Code"];
                NSString*msg=[dd objectForKey:@"Message"];
                if([anc isEqualToString:@"OK"])
                {
                    btnGetSMS.enabled=false;
                    SMS_Last_Time=60;
                    timer = [NSTimer scheduledTimerWithTimeInterval: 1//秒
                                                              target: self
                                                            selector: @selector(handleTimer:)
                                                            userInfo: nil
                                                             repeats: NO];
                    
                    alert_ok(self, 0, @"alert", @"SMS send ok.");
                }
                if([anc isEqualToString:@"isv.MOBILE_NUMBER_ILLEGAL"])
                {
                    alert_err(@"sms err",@"mobile number illegal");
                }
                if([anc isEqualToString:@"isv.BUSINESS_LIMIT_CONTROL"])
                {
                    alert_err(@"sms err",@"business limit control");
                }
                else if(![msg isEqualToString:@"OK"])
                {
                    alert_err(@"sms err",msg);
                }
            }
        }
        else
        {
            alert_err(@"sms err",@"sms interface error");
        }
    }
    else if([page isEqualToString:@"vcode_check.i.php"])
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
                isCheckCodeOK=TRUE;
                
                //更新记录
                NSString *ttCnt;
                ttCnt = [txtPhone.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSString* str=[NSString stringWithFormat:@"k=%@&ph=%@",
                               [GlobalParameter getLoginKey],
                               ttCnt];
                [_web sendData:[GlobalParameter getAccountAddrByMob:@"mod_phone.i.php"] parameter:str];
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
            case 4://不存在验证的电话号码
            case 5://验证码错误
            case 6://验证码已失效
            {
                alert_ok(self, 0, @"alert", @"verify vode error or invalid");
            }
                break;
        }
        txtPhone.enabled=true;
    }
}
-(void) WebProcCallBackFail:(NSURL*)url
{
    alert_ok(self, 0, @"alert", @"connect network fail.");
    
    [ind setAlpha:0];
    [ind setHidden:YES];
    [ind stopAnimating];
    
    txtPhone.enabled=true;
}

- (IBAction)btnModify_click:(id)sender
{
    if([txtPhone.text isEqualToString:@""])
    {
        alert_err(@"alert",@"phone number can't null");
        return;
    }
    if([txtVCode.text isEqualToString:@""])
    {
        alert_err(@"alert",@"verify code can't null");
        return;
    }
    
    txtPhone.enabled=false;
    
    NSString *ttCnt;
    ttCnt = [txtPhone.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if(TRUE==isCheckCodeOK)
    {
        //更新记录
        NSString* str=[NSString stringWithFormat:@"k=%@&ph=%@",
                       [GlobalParameter getLoginKey],
                       ttCnt];
        [_web sendData:[GlobalParameter getAccountAddrByMob:@"mod_phone.i.php"] parameter:str];
    }
    else
    {
        //校验短信
        NSString* str=[NSString stringWithFormat:@"ph=%@&c=%@", ttCnt, txtVCode.text];
        [_web sendData:[GlobalParameter getAccountAddrBySMS:@"vcode_check.i.php"] parameter:str];
    }
}

- (IBAction)btnSMS_click:(id)sender
{
    txtPhone.enabled=false;
    
    NSString *ttCnt;
    ttCnt = [txtPhone.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //获取验证码
    NSString* str=[NSString stringWithFormat:@"ph=%@", ttCnt];
    [_web sendData:[GlobalParameter getAccountAddrBySMS:@"vcode_modify_phone_number.i.php"] parameter:str];
}

-(void) handleTimer: (NSTimer *) timer
{
    SMS_Last_Time--;
    if(SMS_Last_Time>0)
    {
        NSString*sstr=[NSString stringWithFormat:NSLocalizedString(@"%d sec",nil),SMS_Last_Time];
        [btnGetSMS setTitle:sstr forState:0];
        btnGetSMS.enabled=false;
        [NSTimer scheduledTimerWithTimeInterval: 1//秒
                                                 target: self
                                               selector: @selector(handleTimer:)
                                               userInfo: nil
                                                repeats: NO];
    }
    else
    {
        [btnGetSMS setTitle:NSLocalizedString(@"Get SMS",nil) forState:0];
        btnGetSMS.enabled=true;
    }
}

@end
