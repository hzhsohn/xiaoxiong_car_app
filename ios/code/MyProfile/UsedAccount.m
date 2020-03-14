//
//  UsedAccount_iPhone.m
//  smart
//
//  Created by Han.zh on 14-8-7.
//  Copyright (c) 2014年 Han.zhihong. All rights reserved.
//

#import "UsedAccount.h"
#import "HelpHeader.h"
#import "DefineHeader.h"
#import "ProjectAccountCfg.h"
#import "JSONKit.h"
#import "ProjectAccountCfg.h"
#import "GlobalParameter.h"


@interface UsedAccount ()
{
    __weak IBOutlet UILabel *_txtStatus;
    WebProc* _web;
}

-(void)loadInfo;

@end

@implementation UsedAccount

- (void)awakeFromNib{
    [super awakeFromNib];
    _web=[[WebProc alloc] init];
    _web.delegate=self;
}

-(void)dealloc
{
    _web.delegate=nil;
    _web=nil;
    
    _txtStatus=nil;
    //[_txtStatus release];
    //[super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //设置标题
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [UIColor whiteColor],NSForegroundColorAttributeName,
                          [UIFont systemFontOfSize:17],NSFontAttributeName,
                          nil];
    self.navigationController.navigationBar.titleTextAttributes=dict;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadInfo];
}

-(void)loadInfo
{
     [_txtStatus setText:NSLocalizedString(@"useda_connecting", nil)];
    //检测配置文件是否存在
    if([ProjectAccountCfg isFileExist])
    {
        NSString *key=[ProjectAccountCfg getKey];

        if (key) {
            time_t t=[ProjectAccountCfg getKeyAlive];
            if (time(NULL)-t<1800) {
                [GlobalParameter setLoginKey:key];
                //跳到账户管理页面
                [self performSegueWithIdentifier:@"segueAccountManage" sender:self];
            }
            else
            {
                //通过WEB验证已经超过半小时
                //登录检测key是否可用
                NSString* str=[NSString stringWithFormat:@"k=%@",key];
                [_web sendData:[GlobalParameter getAccountAddrByMob:@"verify_key.i.php"] parameter:str];
            }
        }
        else{
            //钥匙为空
            [self performSegueWithIdentifier:@"segueSignIn" sender:self];
        }
    }
    else
    {
        [self performSegueWithIdentifier:@"segueSignIn" sender:self];
    }
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
}

//////////////////////////////////
//网络回调
-(void) WebProcCallBackBegin:(NSURL*)url
{

}
-(void) WebProcCallBackCookies:(NSURL*)url :(NSString*)cookie
{
    
}
-(void) WebProcCallBackData:(NSURL*)url :(NSData*)data
{
    NSLog(@"url=%@",[url relativeString]);
    NSString *page=[url lastPathComponent];
    NSLog(@"page=%@",page);
    
    NSString *ss = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSData *safeJsonData = [NSData dataWithBytes:[ss UTF8String] length:[ss length]];
    NSLog(@"data len=%ld,%@",(unsigned long)[data length],ss);
    
    if (0==[safeJsonData length]) {
        return;
    }

    if([page isEqualToString:@"verify_key.i.php"])
    {
        //解释data
        NSDictionary *result = [safeJsonData objectFromJSONData];
        if(nil==result)
        {
            alert_err(@"json_data_fail",ss);
            return;
        }
        
        switch ([[result objectForKey:@"nRet"] intValue]) {
            case 1://登录成功
            {
                //登录信息
                [GlobalParameter setLoginKey:[result objectForKey:@"szKey"]];
               
                //保存有效不再验证时间
                [ProjectAccountCfg saveKeyAliveNow];
                
                //跳到账户管理页面
                [self performSegueWithIdentifier:@"segueAccountManage" sender:self];
            }
                break;
            case 2://钥匙为空
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert", nil)
                                                                message:NSLocalizedString(@"useda_empty_key", nil)
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                                      otherButtonTitles:nil];
                [alert setTag:100];
                [alert show];
                alert=nil;
                //[alert release];
            }
                break;
            case 3://账号未激活
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert", nil)
                                                                message:NSLocalizedString(@"useda_inaction", nil)
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                                      otherButtonTitles:nil];
                [alert setTag:100];
                [alert show];
                alert=nil;
                //[alert release];
            }
                break;
            case 4://无效钥匙
            {
                /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert", nil)
                                                                message:NSLocalizedString(@"useda_invalid_key", nil)
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                                      otherButtonTitles:nil];
                [alert setTag:100];
                [alert show];
                alert=nil;
                 */
                
                [GlobalParameter clearLoginCfg];
                //去登录页
                [self performSegueWithIdentifier:@"segueSignIn" sender:self];
            }
                break;
            case 5://钥匙与账户不匹配
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert", nil)
                                                                message:NSLocalizedString(@"The key has expired", nil)
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                                      otherButtonTitles:nil];
                [alert setTag:100];
                [alert show];
                alert=nil;
                //[alert release];
            }
                break;
            case 6://不存在此用户
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert", nil)
                                                                message:NSLocalizedString(@"useda_no_user", nil)
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                                      otherButtonTitles:nil];
                [alert setTag:100];
                [alert show];
                alert=nil;
                //[alert release];
            }
                break;
            case 7://账号被禁用
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert", nil)
                                                                message:NSLocalizedString(@"account has been disabled", nil)
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                                      otherButtonTitles:nil];
                [alert setTag:100];
                [alert show];
                alert=nil;
                //[alert release];
            }
                break;
            default:
                break;
        }
    }
}
-(void) WebProcCallBackFail:(NSURL*)url
{
    //服务器连接失败
    [_txtStatus setText:NSLocalizedString(@"useda_connect_fail", nil)];
    
    //6秒后继续连接
    [self performSelector:@selector(loadInfo) withObject:nil afterDelay:6/*秒数*/];
}

/////////////////////////////////////////
//重载的函数

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (100==alertView.tag)
    {
        [GlobalParameter clearLoginCfg];
        //去登录页
        [self performSegueWithIdentifier:@"segueSignIn" sender:self];
    }
}



@end
