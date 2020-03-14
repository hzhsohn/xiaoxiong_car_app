//
//  AccountManage.m
//  smart
//
//  Created by Han.zh on 14-8-6.
//  Copyright (c) 2014年 Han.zhihong. All rights reserved.
//

#import "MyProfileTable.h"
#import "HelpHeader.h"
#import "GlobalParameter.h"
#import "JSONKit.h"
#import "DefineHeader.h"
#import "WebProc.h"
#import "LoginInfo.h"
#import "MD5File.h"

@interface MyProfileTable ()<WebPocDelegate>
{
    __weak IBOutlet UIActivityIndicatorView *ind;
    
    
    WebProc* _web;
    
    __weak IBOutlet UILabel *txtNickName;
    __weak IBOutlet UILabel *txtUserID;
    __weak IBOutlet UIImageView *imgIcon;
    
    NSMutableData* imageData;
}


-(void)setInfo;

@end

@implementation MyProfileTable

- (void)awakeFromNib{
    [super awakeFromNib];
    _web=[[WebProc alloc] init];
    _web.delegate=self;
    imageData=[[NSMutableData alloc] init];
}

-(void)dealloc
{
    _web.delegate=nil;
    _web=nil;
    imageData=nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //初始化
    [ind setBackgroundColor:[UIColor grayColor]];
    ind.alpha=0.0f;
    ind.layer.cornerRadius = 0;//设置那个圆角的有多圆
    ind.layer.borderWidth = 0;//设置边框的宽度
    [ind setHidden:YES];
    
    self.navigationItem.hidesBackButton=YES;
}

- (void)loadImage:(NSString*)url_str
{
    NSURL *url = [NSURL URLWithString:url_str];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:url];
    [request setHTTPMethod:@"GET"]; //设置请求方式
    [request setTimeoutInterval:60];//设置超时时间
    [NSURLConnection connectionWithRequest:request delegate:self];//发送一个异步请求
    [imageData resetBytesInRange:NSMakeRange(0, [imageData length])];
    
}

-(void) webNetInfo
{
    //获取我的简要信息
    NSString* str=[NSString stringWithFormat:@"k=%@",[GlobalParameter getLoginKey]];
    [_web sendData:[GlobalParameter getAccountAddrByMob:@"get_info.i.php"] parameter:str];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSString*userid=[LoginInfo get:@"userid"];
    if(nil==userid)
    {
        [self webNetInfo];
    }
    else
    {
        [self setInfo];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segModNick"])
    {
        ModifyNickame *p=(ModifyNickame *)segue.destinationViewController;
        [self.navigationController pushViewController:p animated:YES];
    }
}

*/

//////////////////////////////////////////////////////////////////

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0://///////////////////////////////////////////
        {
            [self performSegueWithIdentifier:@"segAccount" sender:nil];
            
        }
            break;
        case 1://///////////////////////////////////////////
        {
            switch (indexPath.row) {
                case 0:
                {
                    UIStoryboard *frm = [UIStoryboard storyboardWithName:@"RemoteCtrl" bundle:nil];
                    [self.navigationController pushViewController:[frm instantiateViewControllerWithIdentifier:@"RemoteCtrl"]
                                                         animated:YES];
                }
                break;
                case 1:
                {
                    UIStoryboard *frm = [UIStoryboard storyboardWithName:@"CAID" bundle:nil];
                    [self.navigationController pushViewController:[frm instantiateViewControllerWithIdentifier:@"CAIDInfo"]
                                                         animated:YES];
                }
                    break;
                case 1000:
                {
                    //暂未做这个小钱包功能
                    UIStoryboard *frm = [UIStoryboard storyboardWithName:@"Money" bundle:nil];
                    [self.navigationController pushViewController:frm.instantiateInitialViewController
                                                         animated:YES];

                }
                    break;
            }

        }
        break;
        case 2:
        {
            UIStoryboard *frm = [UIStoryboard storyboardWithName:@"CameraBackup" bundle:nil];
            [self.navigationController pushViewController:
             [frm instantiateViewControllerWithIdentifier:@"CameraBackup"]
                                                 animated:YES];
        }
            break;
        case 3://///////////////////////////////////////////设置
        {
            [self performSegueWithIdentifier:@"segSetting" sender:nil];
        }
            break;
    }
}


-(void)setInfo
{
    NSString* userid;
    NSString* createtime;
    NSString* nickname;
    NSString* email;
    NSString* phone;
    NSString* icon_md5;
    userid=[LoginInfo get:@"userid"];
    createtime=[LoginInfo get:@"createtime"];
    nickname=[LoginInfo get:@"nickname"];
    email=[LoginInfo get:@"email"];
    phone=[LoginInfo get:@"phone"];
    icon_md5=[LoginInfo get:@"icon_md5"];
    
    [txtNickName setText:[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"Nickname:", nil),nickname]];
    [txtUserID setText:[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"UserID:", nil),userid]];
    
    //获取图像
    NSString*stricon=[GlobalParameter getUserIconLocalPath:userid];
    if(nil==stricon)
    {
        [imgIcon setImage:[UIImage imageNamed:@"def_user"]];
        //如果文件不存在就下载这个图片
        [self loadImage:[GlobalParameter getAccountAddrByICON:userid]];
    }
    else
    {
        //显示旧图片
        UIImage*img=[UIImage imageWithContentsOfFile:stricon];
        imgIcon.image=img;
        //对比文件MD5
        NSString*pic_md5=[MD5File getFileMD5WithPath:stricon];
        if(icon_md5)
        {
            if(![icon_md5 isEqualToString:pic_md5])
            {
                //如果文件不存在就下载这个图片
                [self loadImage:[GlobalParameter getAccountAddrByICON:userid]];
            }
        }
    }
}

//////////////////////////////////////////////////////////////////////
- (IBAction)itmBack_click:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
    
    NSString* rurl=[url relativeString];
    NSLog(@"url=%@",rurl);
    NSString *page=[url lastPathComponent];
    NSLog(@"page=%@",page);
    
    NSData *safeJsonData = [_web getSafeJsonData:data];
    NSString *ss = [[NSString alloc] initWithData:safeJsonData encoding:NSUTF8StringEncoding];
    
    if (0==[safeJsonData length]) {
        return;
    }
    
    if([page isEqualToString:@"get_info.i.php"])
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
                BOOL all_disable=0;
                //获取信息
                NSDictionary *info = [result objectForKey:@"info"];
                NSString* userid=[info objectForKey:@"userid"];
                NSString* createtime=[info objectForKey:@"createtime"];
                NSString* nickname=[info objectForKey:@"nickname"];
                NSString* email=[info objectForKey:@"email"];
                NSString* phone=[info objectForKey:@"phone"];
                NSString* icon_md5=[info objectForKey:@"icon_md5"];
                NSNumber* szAllDisable=[info objectForKey:@"all_disable"];
                
                //全局参数
                if(userid)
                {[LoginInfo set:userid key:@"userid"];}
                if(createtime)
                {[LoginInfo set:createtime key:@"createtime"];}
                if(nickname)
                {[LoginInfo set:nickname key:@"nickname"];}
                if(email)
                {[LoginInfo set:email key:@"email"];}
                if(phone)
                {[LoginInfo set:phone key:@"phone"];}
                if(icon_md5)
                {
                    if(![icon_md5 isKindOfClass:NSNull.class])
                    {[LoginInfo set:icon_md5 key:@"icon_md5"];}
                }
                
                if(szAllDisable)
                {
                   all_disable=[szAllDisable integerValue];
                   if(TRUE==all_disable)
                   {
                       //账户被禁用
                       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert", nil)
                                                               message:NSLocalizedString(@"account was disable", nil)
                                                              delegate:self
                                                     cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                                     otherButtonTitles:nil];
                       [alert show];
                       alert=nil;
                   }
                }
                
                [self setInfo];
                
                //判断CAID文件是否存在
                if(access([[GlobalParameter documentPath:@"CAID.cfg"] UTF8String], 0))
                {
                    //获取CAID信息
                    NSString* str=[NSString stringWithFormat:@"k=%@",[GlobalParameter getLoginKey]];
                    [_web sendData:[GlobalParameter getIOTAddrByCAID:@"getcaid.i.php"] parameter:str];
                }
                
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
    else if([page isEqualToString:@"getcaid.i.php"])
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
                NSArray*aryy=[result objectForKey:@"ary"];
                if(aryy)
                {
                    //保存CAID列表
                    NSMutableDictionary* caidlst=[[NSMutableDictionary alloc] init];
                    NSString*str=[GlobalParameter documentPath:@"CAID.cfg"];
                    for(NSDictionary*d in aryy)
                    {
                        [caidlst setValue:[d objectForKey:@"title"]
                                   forKey:[d objectForKey:@"caid"]];
                    }
                    [caidlst writeToFile:str atomically:YES];
                    caidlst=nil;
                }
            }
                break;
        }
    }

}
-(void) WebProcCallBackFail:(NSURL*)url
{
    [self performSelector:@selector(webNetInfo) withObject:nil afterDelay:2];
}
//////////////////////////////////////////////

#pragma mark - NSURLConnection delegate

//数据加载过程中调用,获取数据
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [imageData appendData:data];
}

//数据加载完成后调用
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    //图片数据
    NSString* userid=[LoginInfo get:@"userid"];
    if(userid)
    {
        //判断是否为图片数据
        UIImage*img=[UIImage imageWithData:imageData];
        if(img)
        {
            NSString*stricon=[GlobalParameter createUserIconLocalPath:userid];
            [imageData writeToFile:stricon atomically:YES];
            
            imgIcon.image=img;
            //更新MD5值
            NSString*pic_md5=[MD5File getFileMD5WithPath:stricon];
            [LoginInfo set:pic_md5 key:@"icon_md5"];
        }
        return;
    }
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"请求网络失败:%@",error);
    
}

@end
