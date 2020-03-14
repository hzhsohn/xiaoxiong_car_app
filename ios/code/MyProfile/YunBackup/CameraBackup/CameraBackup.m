//
//  AccountManage.m
//  smart
//
//  Created by Han.zh on 14-8-6.
//  Copyright (c) 2014年 Han.zhihong. All rights reserved.
//

#import "CameraBackup.h"
#import "HelpHeader.h"
#import "WebProc.h"
#import "JSONKit.h"
#import "DefineHeader.h"
#import "Objc_HostInfoMage.h"
#import "GlobalParameter.h"

@interface CameraBackup ()<WebPocDelegate>
{
    __weak IBOutlet UIActivityIndicatorView *ind;
    __weak IBOutlet UILabel *lbRecCount;
    __weak IBOutlet UIButton *btnBackup;
    __weak IBOutlet UIButton *btnRestore;
    
    WebProc* _web;
    Objc_HostInfoMage *m_hostInfoMage;
}

//生在JSON 不要使用JSON KIT的生成 会报错的
-(NSString*)DicToJsonString:(id)object;
@end

@implementation CameraBackup

- (void)awakeFromNib{
    [super awakeFromNib];
    _web=[[WebProc alloc] init];
    _web.delegate=self;
    
    m_hostInfoMage=[[Objc_HostInfoMage alloc] init];
}

-(void)dealloc
{
    _web.delegate=nil;
    _web=nil;
    
    m_hostInfoMage=nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //初始化
    ind.alpha=0;
    ind.hidden=1;
    
    //
    [btnBackup setTitle:NSLocalizedString(@"cambackup_btn1", NULL) forState:UIControlStateNormal];
    [btnRestore setTitle:NSLocalizedString(@"cambackup_btn2", NULL) forState:UIControlStateNormal];
    
    //获取设备记录条数
    NSString* str=[NSString stringWithFormat:@"k=%@",[GlobalParameter getLoginKey]];
    [_web sendData:[GlobalParameter getIOTAddrByCamera:@"getcam_cnt.i.php"] parameter:str];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//////////////////////////////////////////////////////////////////

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    /*
    if ([segue.identifier isEqualToString:@"segWeb"])
    {
    }
    */
}

-(NSString*)DicToJsonString:(id)object
{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted 
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    NSString*rets=[NSString stringWithString:jsonString];
    jsonString=nil;
    return rets;
}

//////////////////////////////////////////////////////////////////////
- (IBAction)btnBackup_click:(id)sender
{
    //监控信息
    [m_hostInfoMage reloadHostInDB];
    //
    NSMutableArray* ary=[[NSMutableArray alloc] init];
    for(NSData*da in [m_hostInfoMage getHostInfoList])
    {
        TagHostInfo* hostInfo=(TagHostInfo*)[da bytes];
        NSMutableDictionary* dd=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 [NSString stringWithFormat:@"%d",hostInfo->devID] ,@"devid",
                                 [NSString stringWithUTF8String:hostInfo->host] ,@"host",
                                 [NSString stringWithFormat:@"%d",hostInfo->port] ,@"port",
                                 [NSString stringWithUTF8String:hostInfo->username] ,@"username",
                                 [NSString stringWithUTF8String:hostInfo->password] ,@"password",
                                 [NSString stringWithUTF8String:hostInfo->title] ,@"title",
                                 [NSString stringWithUTF8String:hostInfo->parameter] ,@"parameter",
                                 nil];
        [ary addObject:dd];
    }
    if(ary && [ary count]>0)
    {
        NSString *crJson = [ary JSONString];
        NSLog(@"crJson=%@",crJson);
        [ary removeAllObjects];
        ary=nil;
        
        NSString* str=[NSString stringWithFormat:@"k=%@&data=%@",[GlobalParameter getLoginKey],crJson];
        [_web sendData:[GlobalParameter getIOTAddrByCamera:@"camera_backup.i.php"] parameter:str];
    }
    else
    {
        alert_ok(self, 0, @"alert", @"camera_count_zero_nobackup");
    }
}

- (IBAction)btnRestore_click:(id)sender
{
    NSString* str=[NSString stringWithFormat:@"k=%@",[GlobalParameter getLoginKey]];
    [_web sendData:[GlobalParameter getIOTAddrByCamera:@"camera_restore.i.php"] parameter:str];
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
    
    if([page isEqualToString:@"getcam_cnt.i.php"])
    {
        NSDictionary *result = [safeJsonData objectFromJSONData];
        if(nil==result)
        {
            alert_err(@"json_data_fail",ss);
            goto _nnc;
        }
        
        switch ([[result objectForKey:@"nRet"] intValue]) {
            case 1:
            {
                lbRecCount.text=[NSString stringWithFormat:
                                 NSLocalizedString(@"%@ records",nil),
                                 [result objectForKey:@"count"]];
                
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
    else if([page isEqualToString:@"camera_backup.i.php"])
    {
        //解释data
        NSDictionary *result = [safeJsonData objectFromJSONData];
        if(nil==result)
        {
            alert_err(@"json_data_fail",ss);
            goto _nnc;
        }
        
        switch ([[result objectForKey:@"nRet"] intValue]) {
            case 1:
            {
                alert_ok(self, 0, @"alert", @"camera info backup success.");
                //获取设备记录条数
                NSString* str=[NSString stringWithFormat:@"k=%@",[GlobalParameter getLoginKey]];
                [_web sendData:[GlobalParameter getIOTAddrByCamera:@"getcam_cnt.i.php"] parameter:str];
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
    else if([page isEqualToString:@"camera_restore.i.php"])
    {
        //解释data
        NSDictionary *result = [safeJsonData objectFromJSONData];
        if(nil==result)
        {
            alert_err(@"json_data_fail",ss);
            goto _nnc;
        }
        
        switch ([[result objectForKey:@"nRet"] intValue]) {
            case 1:
            {
                NSArray*ary=[result objectForKey:@"ary"];
                if(ary)
                {
                    //恢复所有
                    for(NSDictionary*d1 in ary)
                    {
                        NSString*title=[d1 objectForKey:@"title"];
                        NSString*host=[d1 objectForKey:@"host"];
                        NSString*port=[d1 objectForKey:@"port"];
                        NSString*devid=[d1 objectForKey:@"devid"];
                        NSString*username=[d1 objectForKey:@"username"];
                        NSString*passwd=[d1 objectForKey:@"passwd"];
                        NSString*parameter=[d1 objectForKey:@"parameter"];
                        
                        if(!title){dev_err(@"缺少title");return;}
                        if(!host){dev_err(@"缺少host");return;}
                        if(!port){dev_err(@"缺少port");return;}
                        if(!devid){dev_err(@"缺少devid");return;}
                        if(!username){dev_err(@"缺少username");return;}
                        if(!passwd){dev_err(@"缺少passwd");return;}
                        if(!parameter){dev_err(@"缺少parameter");return;}
                        
                        TagHostInfo hostInfo={0};
                        strcpy(hostInfo.title,[title UTF8String]);
                        strcpy(hostInfo.host,[host UTF8String]);
                        hostInfo.port=[port intValue];
                        hostInfo.devID=[devid intValue];
                        strcpy(hostInfo.username,[username UTF8String]);
                        strcpy(hostInfo.password,[passwd UTF8String]);
                        strcpy(hostInfo.parameter,[parameter UTF8String]);
                        
                        if (![m_hostInfoMage insertHostInfo:hostInfo.title
                                                           :hostInfo.host
                                                           :hostInfo.port
                                                           :hostInfo.devID
                                                           :hostInfo.username
                                                           :hostInfo.password
                                                           :hostInfo.parameter])
                        {
                            alert_ok(self,0,@"alert",@"sqlite_read_fail");
                            return;
                        }
                    }
                    alert_ok(self,0,@"alert",@"camera info restore success.");
                }
                else
                {
                    dev_err(@"没有ary节点");
                }
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
    
_nnc:
    [ind setAlpha:0];
    [ind setHidden:YES];
    [ind stopAnimating];
}
-(void) WebProcCallBackFail:(NSURL*)url
{
    NSString *page=[url lastPathComponent];
    NSLog(@"page=%@",page);

    if([page isEqualToString:@"getcam_cnt.i.php"])
    {
        //继续获取设备记录条数
        NSString* str=[NSString stringWithFormat:@"k=%@",[GlobalParameter getLoginKey]];
        [_web sendData:[GlobalParameter getIOTAddrByCamera:@"getcam_cnt.i.php"] parameter:str];
    }
    else
    {
        alert_ok(self, 0, @"alert", @"connect network fail.");
        
        [ind setAlpha:0];
        [ind setHidden:YES];
        [ind stopAnimating];
    }
}


@end
