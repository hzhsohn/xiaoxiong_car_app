//
//  MyProfile_iPhone.m
//  smart
//
//  Created by Han.zh on 14-8-19.
//  Copyright (c) 2014年 Han.zhihong. All rights reserved.
//

#import "MyProfile_iPhone.h"
#import "HelpHeader.h"
#import "GlobalParameter.h"
#import "JSONKit.h"
#import "WebProc.h"
#import "DefineHeader.h"
#import "LoginInfo.h"

@interface MyProfile_iPhone ()<WebPocDelegate>
{
    WebProc* _web;
    
    __weak IBOutlet UILabel *txtUserid;
    __weak IBOutlet UILabel *txtNickname;
    __weak IBOutlet UIImageView *imgIcon;
    
    __weak IBOutlet UILabel *txtNickNameVal;
    __weak IBOutlet UILabel *txtUserIDVal;
    
    __weak IBOutlet UIActivityIndicatorView *ind;
}

-(void)setInfo;

@end

@implementation MyProfile_iPhone

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [ind setHidden:YES];
    ind.alpha=0;
    
    //获取我的详细信息
   // NSString* str=[NSString stringWithFormat:@"k=%@",[GlobalParameter getLoginKey]];
    //[_web sendData:[GlobalParameter getIOTAddrByInfo:@"iot_info.i.php"] parameter:str];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setInfo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



-(void)setInfo
{
    NSString* userid;
    NSString* createtime;
    NSString* nickname;
    NSString* email;
    NSString* phone;
    NSString* szUserid;
    NSString* szActiveTime;
    NSString* nCredit;
    
    userid=[LoginInfo get:@"userid"];
    szUserid=[LoginInfo get:@"szUserid"];
    createtime=[LoginInfo get:@"createtime"];
    nickname=[LoginInfo get:@"nickname"];
    email=[LoginInfo get:@"email"];
    phone=[LoginInfo get:@"phone"];
    szActiveTime=[LoginInfo get:@"szActiveTime"];
    
    ///////////////////////////////////////////////
    //调整初始化的值
    
    nickname=nickname?nickname:@"";
    userid=userid?userid:@"";
    
    
    ///////////////////////////////////////////////
    txtNickNameVal.text=nickname;
    txtUserIDVal.text=userid;
    
    ///////////////////////////////////////////////
    //加载图像
    NSString*stricon=[GlobalParameter getUserIconLocalPath:userid];
    if(stricon)
    {
        UIImage*img=[UIImage imageWithContentsOfFile:stricon];
        imgIcon.image=img;
    }
    else
    {
        [imgIcon setImage:[UIImage imageNamed:@"def_user"]];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0://///////////////////////////////////////////
        {
            switch (indexPath.row) {
                case 0:
                    [self performSegueWithIdentifier:@"segSetIcon" sender:nil];
                    break;
                case 1:
                    [self performSegueWithIdentifier:@"segModifyNick" sender:nil];
                    break;
            }
        }
            break;
       
    }
}

//////////////////////////////////
//网络回调
-(void) WebProcCallBackBegin:(NSURL*)url
{
    NSString* szUserid=[LoginInfo get:@"szUserid"];
    if(nil==szUserid)
    {
        //已经加载过一次就不显示加载的状态
        [ind setHidden:NO];
        ind.alpha=1;
    }
}
-(void) WebProcCallBackCookies:(NSURL*)url :(NSString*)cookie
{
    
}
-(void) WebProcCallBackData:(NSURL*)url :(NSData*)data
{
    
    [ind setHidden:YES];
    ind.alpha=0;
    
    NSLog(@"url=%@",[url relativeString]);
    NSString *page=[url lastPathComponent];
    NSLog(@"page=%@",page);
    
    NSData *safeJsonData = [_web getSafeJsonData:data];
    NSString *ss = [[NSString alloc] initWithData:safeJsonData encoding:NSUTF8StringEncoding];
    
    if (0==[safeJsonData length]) {
        return;
    }
    
    if([page isEqualToString:@"iot_info.i.php"])
    {

        //解释data
        NSDictionary *result = [safeJsonData objectFromJSONData];
        if(nil==result)
        {
            alert_err(@"json_data_fail",ss);
            
        }
        
        switch ([[result objectForKey:@"nRet"] intValue]) {
            case 1:
            {
                NSDictionary *info = [result objectForKey:@"info"];
                NSString* szUserid=[info objectForKey:@"userid"];
                NSString* szActiveTime=[info objectForKey:@"activeTime"];
                NSString* vip_level=[info objectForKey:@"vip_level"];
                NSString* nCredit=[info objectForKey:@"credit"];
                
                //全局参数
                if(szUserid)
                {[LoginInfo set:szUserid key:@"szUserid"];}
                if(szActiveTime)
                {[LoginInfo set:szActiveTime key:@"activeTime"];}
                if(vip_level)
                {[LoginInfo set:vip_level key:@"vip_level"];}
                if(nCredit)
                {[LoginInfo set:nCredit key:@"nCredit"];}
                
                [self setInfo];
                
            }
                break;
            case 2://不存在此用户
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert", nil)
                                                                message:NSLocalizedString(@"myprofile_no_user", nil)
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                                      otherButtonTitles:nil];
                [alert show];
                alert=nil;
                //[alert release];
            }
                break;
            case 3://操作数据库失败
            {
                alert_ok(self, 0, @"alert", @"myprofile_operat_fail");
            }
                break;
            case 4://缺少参数
            {
                alert_ok(self, 0, @"alert", @"myprofile_lost_param");
            }
                break;
            case 5://key参数不正确
            {
                alert_ok(self, 0, @"alert", @"myprofile_key_invalid");
            }
                break;
            default:
                break;
        }
    }
    
}
-(void) WebProcCallBackFail:(NSURL*)url
{
    NSString* szUserid=[LoginInfo get:@"szUserid"];
    if(nil==szUserid)
    {
        //已经加载过一次就不显示
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert", nil)
                                                        message:NSLocalizedString(@"connect network fail.", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                              otherButtonTitles:nil];
        alert.tag=1200;
        [alert show];
        alert=nil;
    }
    
    [ind setHidden:YES];
    ind.alpha=0;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"AlertView.tag%ld ,buttonIndex=%ld",alertView.tag,buttonIndex);
    switch (alertView.tag) {
        case 1200:
            [self.navigationController popViewControllerAnimated:YES];
            break;
    }
}


@end
