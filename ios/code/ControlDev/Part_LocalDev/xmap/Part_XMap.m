//
//  ViewController.m
//  libxmap_Demo
//
//  Created by Han.zh on 2019/12/11.
//  Copyright © 2019 Han.zhihong. All rights reserved.
//

#import "Part_XMap.h"
#import <libxmap/libxmap.h>
#import "McuGlobalParameter.h"
#import "JSONKit.h"
#import "XMBaseStatus.h"

//网络控制
extern McuGlobalParameter *mcuParameter;

@interface Part_XMap ()<XMapDTRSListener>
{
    
    __weak IBOutlet UIButton *loginBtn;
    __weak IBOutlet UITextField *account;
    __weak IBOutlet UITextField *password;
    __weak IBOutlet UIActivityIndicatorView *inding;
    UILabel *lb1;
    
    //
    XMapDTRS* xmap;
    //定时器
    NSTimer* m_timer;
    //保活包计数器
    unsigned long tmeKeepCountCal;
    unsigned long tmeRecvKeep;
}

//左边插入文字
-(void)leftText:(UITextField*)target :(NSString*)title;
//
- (IBAction)btnLogin:(id)sender;

@end

@implementation Part_XMap

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self leftText:account :@" 账号:"];
//    [self leftText:password :@" 密码:"];
    password.secureTextEntry = true;
    

    //获取数据库里的账户信息
    char user[255]={0};
    char passwd[255]={0};
    BOOL ret=[self getUserPassword:self.devUUID u:user p:passwd];
    if(ret)
    {
        account.text=[NSString stringWithUTF8String:user];
        password.text=[NSString stringWithUTF8String:passwd];
    }
    
    _backView.layer.masksToBounds = true;
    _backView.layer.cornerRadius = 8;
    
    loginBtn.layer.masksToBounds = true;
    loginBtn.layer.cornerRadius = 8;
    
    //
    inding.hidden=NO;
    inding.alpha=1;
    inding.layer.cornerRadius = 10;//设置那个圆角的有多圆
    inding.layer.borderWidth = 0;//设置边框的宽度
    [account setEnabled:NO];
    [password setEnabled:NO];
    lb1=[[UILabel alloc] initWithFrame:CGRectMake(0, 150, 200, 24)];
    [lb1 setTextAlignment:NSTextAlignmentCenter];
    [inding addSubview:lb1];
    
    //初始化xmap
    xmap=[[XMapDTRS alloc] initWithDPID:@"8eefc35e609587453f411e9e92bfc107" targetUUID:self.devUUID];
    [xmap.delegateList addObject:self];
    tmeRecvKeep=[XMapCommand getTime];
    [xmap connectXMap];
    lb1.text=@"正在连接服务器。。。";
    
    
    //初始化公共参数
    [mcuParameter clearAllParameter];
    [mcuParameter setParameter:@"netType" :[NSNumber numberWithInt:self.netType]];
    [mcuParameter setParameter:@"host" :self.host];
    [mcuParameter setParameter:@"port" :[NSNumber numberWithInt:self.port]];
    [mcuParameter setParameter:@"devUUID" :self.devUUID];
    [mcuParameter setParameter:@"devName" :self.devName];
    [mcuParameter setParameter:@"+xmap" :xmap];
    
    
    //计时器
    m_timer = [NSTimer scheduledTimerWithTimeInterval: 0.001//秒
                                               target: self
                                             selector: @selector(handleTimer:)
                                             userInfo: nil
                                              repeats: YES];
}

-(void)dealloc
{
    //[super dealloc];
    NSLog(@"Part_XMap dealloc");
    //
    g_XMBaseStatus.isXTNetLoginSuccess=false;
}

//--------------------------------------------------------
//检测是否返回
- (void)didMoveToParentViewController:(UIViewController*)parent{
    [super didMoveToParentViewController:parent];
    if(!parent){
        NSLog(@"页面pop成功了");
        [m_timer invalidate];
        m_timer=nil;
        [xmap destory];
        xmap=nil;
    }
}


//定时器
-(void)handleTimer: (NSTimer *) timer
{
    [xmap loop_process];
    
    //保活包
    if([XMapCommand getTime]-tmeKeepCountCal >20000)
    {
        tmeKeepCountCal=[XMapCommand getTime];
        [xmap sendPack:[XMapCommand getKeep]];
    }
    
    //25秒还没接收到就连接超时
    if([XMapCommand getTime]-tmeRecvKeep >25000)
    {
        tmeRecvKeep=[XMapCommand getTime];
        //重新连接
        [xmap connectXMap];
    }
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

- (IBAction)btnLogin:(id)sender
{
        //登录
        strcpy(g_XMBaseStatus.XMapUser.username,[[account text] UTF8String]);
        strcpy(g_XMBaseStatus.XMapUser.userpasswd,[[password text] UTF8String]);
        strcpy(g_XMBaseStatus.XMapUser.userdevID,"ios remote client uuid is null");
        [xmap sendPack:[XMapCommand login :[NSString stringWithUTF8String:g_XMBaseStatus.XMapUser.username]
                                          :[NSString stringWithUTF8String:g_XMBaseStatus.XMapUser.userpasswd]
                                          :[NSString stringWithUTF8String:g_XMBaseStatus.XMapUser.userdevID]]];
        //
        [self setUserPassword:self.devUUID u:[account text]  p:[account text]];
}
//-------------------------------------------------
//
// XMapDTRS 的回调
//
-(void) XMapDTRS_devuuid_subscr_success
{
    NSLog(@"devuuid_subscr_success");
    lb1.text=@"正在订阅设备信息。。。";
}
-(void) XMapDTRS_sign_success
{
    NSLog(@"sign_success");
    inding.hidden=YES;
    inding.alpha=0;
    [account setEnabled:YES];
    [password setEnabled:YES];
    lb1.text=@"中控连接签入成功";
    
    //自动登录
    if(false==g_XMBaseStatus.isXTNetLoginSuccess)
    {
        if(![account.text isEqualToString:@""] && ![password.text isEqualToString:@""])
        {
            [self btnLogin:nil];
        }
    }
    else{
        //自动登录账号
        [xmap sendPack:[XMapCommand login :[NSString stringWithUTF8String:g_XMBaseStatus.XMapUser.username]
                                          :[NSString stringWithUTF8String:g_XMBaseStatus.XMapUser.userpasswd]
                                          :[NSString stringWithUTF8String:g_XMBaseStatus.XMapUser.userdevID]]];
        
        //xmapShowAlert(self,@"重新登录成功");
    }
}

-(void) XMapDTRS_new_data:(char*) data :(int)len
{
    short cmd=0;
    memcpy(&cmd,data,2);
    NSLog(@"Part_XMap new_data len=%d , cmd=%d",len,cmd);
    
    switch (cmd) {
        case ecpnSToCKeep:
        {
            tmeRecvKeep=[XMapCommand getTime];
            [xmap sendPack:[XMapCommand recvKeep]];
            NSLog(@"ecpnCToSKeepRtt rtt=%ld",g_XMBaseStatus.rtt);
        }
        break;
        case ecpuSToCLogin:
        {
            int ret=data[2];
            switch(ret)
            {
                case ecpRetLoginNone://*****************未登录不能操作*****************
                    NSLog(@"ZH_GROUP_LOGIN_RESULT_NO_LOGIN");
                    //Toast.makeText(_cxt, "未登录不能操作", Toast.LENGTH_SHORT).show();
                    break;
                case ecpRetLoginSuccess://*****************登录成功*****************
                {
                    NSLog(@"ZH_GROUP_LOGIN_RESULT_SUCCESS");
                    //Toast.makeText(_cxt, "登录成功...!!!", Toast.LENGTH_SHORT).show();
                    //
                    //[self showAlert:@"登录成功"];
                    if(false==g_XMBaseStatus.isXTNetLoginSuccess)
                    {
                        g_XMBaseStatus.isXTNetLoginSuccess=true;
                        [self performSegueWithIdentifier:@"segGo" sender:nil];
                    }
                }
                    break;
                case ecpRetLoginPasswordFail://*****************密码错误*****************
                {
                    NSLog(@"ZH_GROUP_LOGIN_RESULT_PASS_FAIL");
                    //Toast.makeText(_cxt, "登录失败!!", Toast.LENGTH_SHORT).show();
                    //
                    xmapShowAlert(self,@"密码错误");
                }
                    break;
                case ecpRetLoginOverload://*****************服务器超载*****************
                    NSLog(@"ZH_GROUP_LOGIN_RESULT_OVERLOAD");
                    //Toast.makeText(_cxt, "服务器超载", Toast.LENGTH_SHORT).show();
                    xmapShowAlert(self,@"服务器超载");
                    break;
                case ecpRetLoginRemoveOccup://*****************账户异地登录,当前设备被断开*****************
                    NSLog(@"ZH_GROUP_LOGIN_RESULT_EXIST_DEVICEID");
                    //Toast.makeText(_cxt, "账户异地登录,当前设备被断开", Toast.LENGTH_SHORT).show();
                    xmapShowAlert(self,@"账户异地登录,当前设备被断开");
                    break;
                }
        }
        break;
        case ecpuSToCJsonCommand:
        {
            NSString* pjsonData=[NSString stringWithUTF8String:&data[2]];
            NSLog(@"XMapWallList ecpuSToCJsonCommand=%@",pjsonData);

            NSData*jsonData=[NSData dataWithData:[pjsonData dataUsingEncoding: NSUTF8StringEncoding]];
            NSDictionary *result = [jsonData objectFromJSONData];
            NSString*jcmd=[result objectForKey:@"cmd"];
            
            if([jcmd isEqualToString:@"need_login"])
            {
                if(g_XMBaseStatus.isXTNetLoginSuccess)
                {
                    [xmap sendPack:[XMapCommand login
                                  :[NSString stringWithUTF8String:g_XMBaseStatus.XMapUser.username]
                                  :[NSString stringWithUTF8String:g_XMBaseStatus.XMapUser.userpasswd]
                                  :[NSString stringWithUTF8String:g_XMBaseStatus.XMapUser.userdevID]]];
                    
                }
            }
            else if([jcmd isEqualToString:@"login_out_rb"])
            {
                g_XMBaseStatus.isXTNetLoginSuccess=false;
            }
        }
        break;
    }
}
//通讯异常
-(void) XMapDTRS_abnormal_communication:(int)errid :(NSString*) msg
{
    NSLog(@"abnormal_communication errid=%d, msg=%@",errid,msg);
}
-(void) XMapDTRS_disconnect
{
    NSLog(@"disconnect");
    inding.hidden=NO;
    inding.alpha=1;
}


- (IBAction)nav_BackViewcontroll:(UIBarButtonItem *)sender {
    [self.navigationController popViewControllerAnimated:true];
}


@end
