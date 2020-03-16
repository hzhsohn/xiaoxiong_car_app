//
//  AddAccount_iPhone.m
//  Smart
//
//  Created by sohn on 12-11-14.
//  Copyright (c) 2012年 sohn. All rights reserved.
//

#import "SignUp_iPhone.h"
#import "HelpHeader.h"
#import "DefineHeader.h"
#import "SignUp2_iPhone.h"
#import "JSONKit.h"
#import "GlobalParameter.h"

@interface SignUp_iPhone ()
{
    __weak IBOutlet UILabel *lbRet;
    __weak IBOutlet UIActivityIndicatorView *ind;
    __weak IBOutlet UIButton *nextBtn;
}

- (void)veryKey_email:(NSString*)em;

@end

@implementation SignUp_iPhone

- (void)awakeFromNib
{
    [super awakeFromNib];
    _web=[[WebProc alloc] init];
    _web.delegate=self;
}


- (void)dealloc {
    _web.delegate=nil;
    _web=nil;
    _txtUserID=nil;
    //[_txtUserID release];
    //[super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [lbRet setText:@""];
    
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
-(void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}
-(void) viewWillDisappear:(BOOL)animated
{
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
};

//////////////////////////////////////////////////
-(IBAction) txtDone:(id)sender
{
    UITextField*txt=(UITextField*)sender;
    [txt resignFirstResponder];
}

-(IBAction) btnNext_click:(id)sender
{
    if ([_txtEmail.text isEqualToString:@""]) {
        //用户为空
        alert_ok(self, 0, @"alert", @"signup_email_not_null");
        return;
    }
    if ([_txtNickname.text isEqualToString:@""]) {
        //密码为空
        alert_ok(self, 0, @"alert", @"signup_nick_not_null");
        return;
    }
    
    //验证是否可以注册
    [self veryKey_email:_txtEmail.text];
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segueSignUp2"])
    {
        SignUp2_iPhone *frm=segue.destinationViewController;
        [frm setInfo:_txtEmail.text :_txtNickname.text];
    }
}

- (void)veryKey_email:(NSString*)em
{
    NSString*str=[NSString stringWithFormat:@"verify_reg.i.php?a=%@",em];
    [_web sendData:[GlobalParameter getAccountAddrByMob:str] parameter:nil];
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
    
    if([_web isNotFoundPage:ss])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert", nil)
                                                        message:NSLocalizedString(@"not found web page.", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                              otherButtonTitles:nil];
        [alert show];
        alert=nil;
        return;
    }
    
    if([page isEqualToString:@"verify_reg.i.php"])
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
                [self performSegueWithIdentifier:@"segueSignUp2" sender:self];
            }
                break;
            case 2://邮箱已被占用
            {
                alert_ok(self, 0, @"alert", @"email occupation");
            }
                break;
            case 3://参数为空
            {
                alert_ok(self, 0, @"alert", @"parameter is null.");
            }
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
