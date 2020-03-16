//
//  SignIn_iPhone.m
//  smart
//
//  Created by Han.zh on 14-8-19.
//  Copyright (c) 2014年 Han.zhihong. All rights reserved.
//

#import "SignIn_iPhone.h"
#import "HelpHeader.h"
#import "JSONKit.h"
#import "ProjectAccountCfg.h"
#import "GlobalParameter.h"
#import "TempCfg.h"
#import "DefineHeader.h"
#import "WebBrower.h"

@interface SignIn_iPhone ()
{
    WebProc* _web;
    __weak IBOutlet UITextField *_txtUser;
    __weak IBOutlet UITextField *_txtPassword;
    __weak IBOutlet UIActivityIndicatorView *ind;
    __weak IBOutlet UIButton *loginBtn;
}
- (IBAction)txtOnExit:(id)sender;
- (IBAction)btnLogin_click:(id)sender;
- (IBAction)btnForgot_click:(id)sender;

@end

@implementation SignIn_iPhone

- (void)awakeFromNib{
    [super awakeFromNib];
    _web=[[WebProc alloc] init];
    _web.delegate=self;
}

-(void)dealloc
{
    _web.delegate=nil;
    _web=nil;
    
    _txtUser=nil;
    _txtPassword=nil;
    //[_txtEmail release];
    //[_txtPassword release];
    //[super dealloc];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    //隐藏回退按键
    self.navigationItem.hidesBackButton=YES;
    // Do any additional setup after loading the view.
    
    /*
    //注册事件
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardWillShow:)
     name:UIKeyboardWillShowNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardWillHide:)
     name:UIKeyboardWillHideNotification
     object:nil];
    */
    loginBtn.layer.masksToBounds = true;
    loginBtn.layer.cornerRadius = 4;
    //初始化
    [ind setBounds:CGRectMake(0, 0, 130, 130)];
    [ind setBackgroundColor:[UIColor grayColor]];
    ind.alpha=0.0f;
    ind.layer.cornerRadius = 10;//设置那个圆角的有多圆
    ind.layer.borderWidth = 0;//设置边框的宽度
    [ind setHidden:YES];
    
    NSString*acc=[TempCfg get:@"account"];
    if (acc) {
        _txtUser.text=acc;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //隐藏回退按键
    self.navigationItem.leftBarButtonItem=nil;
    [self.navigationItem setHidesBackButton:YES animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) keyboardWillShow:(NSNotification *)note {
    NSLog(@"keyboard show");
    
    //上移输入框
    NSDictionary* info = [note userInfo];
    NSValue* aValue = [info objectForKey:@"UIKeyboardBoundsUserInfoKey"];
    CGSize keyboardRect = [aValue CGRectValue].size;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    
    CGRect rk;
    rk=self.view.frame;
    rk.origin.y=-keyboardRect.height;
    [self.view setFrame:rk];
    
    [UIView setAnimationTransition:0 forView:self.view cache:YES];
    [UIView commitAnimations];
    
}
- (void) keyboardWillHide:(NSNotification *)note
{
    NSLog(@"keyboard hide");
    //恢复输入框
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    
    CGRect rk;
    rk=self.view.frame;
    rk.origin.y=0;
    [self.view setFrame:rk];
    
    [UIView setAnimationTransition:0 forView:self.view cache:YES];
    [UIView commitAnimations];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    NSLog(@"segue.identifier=%@",segue.identifier);
    /*
    if ([segue.identifier isEqualToString:@"segueReactiveEmail"])
    {
        ReactiveEmail_iPhone* frm=(ReactiveEmail_iPhone*)segue.destinationViewController;
        [frm setEmailString:_txtEmail.text];
    }*/
}

- (IBAction)txtOnExit:(id)sender {
    [(UITextField*)sender resignFirstResponder];
}

- (IBAction)btnLogin_click:(id)sender
{
    if ([_txtUser.text isEqualToString:@""]) {
        alert_ok(self, 0, @"alert", @"signin_empty_account");
        return;
    }
    
    if ([_txtPassword.text isEqualToString:@""]) {
        alert_ok(self, 0, @"alert", @"signin_empty_password");
        return;
    }

    //登录
    NSString* str=[NSString stringWithFormat:@"a=%@&p=%@",_txtUser.text,_txtPassword.text];
    [_web sendData:[GlobalParameter getAccountAddrByMob:@"sign_in.i.php"] parameter:str];
    //
    [TempCfg set:_txtUser.text :@"account"];
}

- (IBAction)btnForgot_click:(id)sender
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MyProfile" bundle:nil];
    WebBrower *frm=(WebBrower *)[sb instantiateViewControllerWithIdentifier:@"HTML5"];
    frm.main_url=WEB_FORGOT_URL;
    [self.navigationController pushViewController:frm animated:YES];
    
    
    //进入APP界面
    //[self performSegueWithIdentifier:@"forgot" sender:nil];
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

    if([page isEqualToString:@"sign_in.i.php"])
    {
        //解释data
        NSDictionary *result = [safeJsonData objectFromJSONData];
        if(nil==result)
        {
            alert_err(@"json_data_fail",ss);
            goto _nnc;
        }
        
        switch ([[result objectForKey:@"nRet"] intValue]) {
            case 1://登录成功
            {
                //登录信息
                [GlobalParameter setLoginKey:[result objectForKey:@"szKey"]];
                
                //保存账户
                [ProjectAccountCfg saveAccount:[result objectForKey:@"szKey"]];
                [ProjectAccountCfg saveKeyAliveNow];

                //跳到返回到加载页
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
                break;
            case 2://登录失败
            {
                alert_ok(self, 0, @"alert", @"signin_login_fail");
            }
                break;
            case 3://账号为空
            {
                alert_ok(self, 0, @"alert", @"signin_empty_account");
            }
                break;
            case 4://密码为空
            {
                alert_ok(self, 0, @"alert", @"signin_empty_password");
            }
                break;
            case 5://账号已被禁用
            {
                alert_ok(self, 0, @"alert", @"signin_empty_password");
            }
                break;
            case 6://不存在的账号
            {
                alert_ok(self, 78, @"alert", @"signin_no_user");
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


/////////////////////////////
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"AlertView.tag%ld ,buttonIndex=%ld",alertView.tag,buttonIndex);
    
    switch (alertView.tag) {
        /*case 102:
        {
            switch (buttonIndex) {
                case 0:
                    //按了取消键
                    break;
                case 1:
                    //
                    break;
            }
        }
            break;*/
        case 78://跳到去注册
        {
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MyProfile" bundle:nil];
            WebBrower *frm=(WebBrower *)[sb instantiateViewControllerWithIdentifier:@"HTML5"];
            frm.main_url=WEB_SIGNUP_URL;
            [self.navigationController pushViewController:frm animated:YES];
            
            //跳到去APP注册
            //[self performSegueWithIdentifier:@"signup" sender:nil];
        }
            break;
    }
    
}


@end
