//
//  Forgot_iPhone.m
//  smart
//
//  Created by Han.zh on 14-8-21.
//  Copyright (c) 2014年 Han.zhihong. All rights reserved.
//

#import "Forgot_iPhone.h"
#import "HelpHeader.h"
#import "GlobalParameter.h"
#import "JSONKit.h"

@interface Forgot_iPhone ()
{
    __weak IBOutlet UIActivityIndicatorView *ind;
}
@end

@implementation Forgot_iPhone

- (void)awakeFromNib{
    [super awakeFromNib];
    _web=[[WebProc alloc] init];
    _web.delegate=self;
}

-(void)dealloc
{
    _web.delegate=nil;
    _web=nil;
    
    //[_txtEmail release];
    _txtEmail=nil;
    
    //[super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_txtEmail becomeFirstResponder];
};

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

- (IBAction)itmNext_click:(id)sender
{
    if ([_txtEmail.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert", nil)
                                                        message:NSLocalizedString(@"forgot_empty_email", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                              otherButtonTitles:nil];
        [alert show];
        //[alert release];
        alert=nil;
        return;
    }
    
    [_txtEmail setEnabled:FALSE];
    [self.navigationItem.rightBarButtonItem setEnabled:FALSE];
    [self.navigationItem setHidesBackButton:YES animated:YES];

    //登录检测key是否可用
    NSString* str=[NSString stringWithFormat:@"em=%@",_txtEmail.text];
    [_web sendData:[GlobalParameter getAccountAddrByMob:@"forgot_by_email.i.php"] parameter:str];
    
}

- (IBAction)txtDone:(id)sender {
    [_txtEmail resignFirstResponder];
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
    
    if([page isEqualToString:@"forgot_by_email.i.php"])
    {
        [_txtEmail setEnabled:TRUE];
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
        [self.navigationItem setHidesBackButton:NO animated:YES];

        //解释data
        NSDictionary *result = [safeJsonData objectFromJSONData];
        if(nil==result)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"json_data_fail", nil)
                                                            message:ss
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                                  otherButtonTitles:nil];
            [alert show];
            //[alert release];
            alert=nil;
            goto _nnc;
        }
        
        switch ([[result objectForKey:@"nRet"] intValue]) {
            case 1://
            {
                [self performSegueWithIdentifier:@"segueForgotDone" sender:self];
            }
                break;
            case 2://邮箱格式不对
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert", nil)
                                                                message:NSLocalizedString(@"forgot_mail_format_err", nil)
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                                      otherButtonTitles:nil];
                [alert show];
                //[alert release];
                alert=nil;
            }
                break;
            case 3://不存在此邮箱用户
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert", nil)
                                                                message:NSLocalizedString(@"forgot_no_user", nil)
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                                      otherButtonTitles:nil];
                [alert show];
                //[alert release];
                alert=nil;
            }
                break;
            case 4://发送失败
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert", nil)
                                                                message:NSLocalizedString(@"forgot_send_fail", nil)
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                                      otherButtonTitles:nil];
                [alert show];
                //[alert release];
                alert=nil;
            }
                break;
            case 5://缺少em参数
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert", nil)
                                                                message:NSLocalizedString(@"forgot_empty_email", nil)
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                                      otherButtonTitles:nil];
                [alert show];
                //[alert release];
                alert=nil;
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
    
    [_txtEmail setEnabled:TRUE];
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    [self.navigationItem setHidesBackButton:NO animated:YES];
    [self performSegueWithIdentifier:@"segueForgotFail" sender:self];
    
}

@end
