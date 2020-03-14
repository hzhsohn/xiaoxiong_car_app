//
//  AccountManage.m
//  smart
//
//  Created by Han.zh on 14-8-6.
//  Copyright (c) 2014年 Han.zhihong. All rights reserved.
//

#import "CAIDShare.h"
#import "HelpHeader.h"
#import "GlobalParameter.h"
#import "JSONKit.h"
#import "DefineHeader.h"
#import "WebBrower.h"
#import "WebProc.h"

@interface CAIDShare ()<WebPocDelegate>
{
    __weak IBOutlet UIActivityIndicatorView *ind;
    __weak IBOutlet UIButton *btnShare;
    __weak IBOutlet UILabel *lbShareCAID;
    __weak IBOutlet UILabel *lbCAID;
    
    WebProc* _web;
    NSMutableArray * _aryCAID;
    BOOL isCurShareKey;
}

- (IBAction)btnDoShare_click:(id)sender;

@end

@implementation CAIDShare

- (void)awakeFromNib{
    [super awakeFromNib];
    _web=[[WebProc alloc] init];
    _web.delegate=self;
    
    _aryCAID=[[NSMutableArray alloc] init];
}

-(void)dealloc
{
    _web.delegate=nil;
    _web=nil;
    
    [_aryCAID removeAllObjects];
    _aryCAID=nil;
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
    
    self.title=self.strTitle;
    lbShareCAID.text=[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"Share Key: ", nil),self.strSharekey];
    lbCAID.text=[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"CAID: ", nil),self.strCAID];
    
    NSInteger nSharekey=[self.strSharekey integerValue];
    if(nSharekey>0)
    {
        [btnShare setTitle:NSLocalizedString(@"Cancel Share", nil) forState:0];
        [btnShare setTintColor:[UIColor redColor]];
        isCurShareKey=TRUE;
    }
    else
    {
        [btnShare setTitle:NSLocalizedString(@"Share Node", nil) forState:0];
        [btnShare setTintColor:[UIColor blueColor]];
        isCurShareKey=FALSE;
    }
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
    
    if([page isEqualToString:@"set_share_caid.i.php"])
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
                [btnShare setTitle:NSLocalizedString(@"Cancel Share", nil) forState:0];
                [btnShare setTintColor:[UIColor redColor]];
                isCurShareKey=TRUE;
                NSString*nshkey=[result objectForKey:@"sharekey"];
                NSInteger shkey=0;
                if(nshkey)
                {
                    shkey=[nshkey integerValue];
                }
                lbShareCAID.text=[NSString stringWithFormat:@"%@%ld",NSLocalizedString(@"Share Key: ", nil),shkey];
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
    else if([page isEqualToString:@"set_unshare_caid.i.php"])
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
                [btnShare setTitle:NSLocalizedString(@"Share Node", nil) forState:0];
                [btnShare setTintColor:[UIColor blueColor]];
                isCurShareKey=FALSE;
                int shkey=0;
                lbShareCAID.text=[NSString stringWithFormat:@"%@%d",NSLocalizedString(@"Share Key: ", nil),shkey];
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
    alert_ok(self, 0, @"alert", @"connect network fail.");
    
    [ind setAlpha:0];
    [ind setHidden:YES];
    [ind stopAnimating];
}


- (IBAction)btnDoShare_click:(id)sender
{
    if(isCurShareKey)
    {
        //获取分享CAID信息
        NSString* str=[NSString stringWithFormat:@"k=%@&autoid=%@",[GlobalParameter getLoginKey],self.strAutoid];
        [_web sendData:[GlobalParameter getIOTAddrByCAID:@"set_unshare_caid.i.php"] parameter:str];
    }
    else
    {
        //获取分享CAID信息
        NSString* str=[NSString stringWithFormat:@"k=%@&autoid=%@",[GlobalParameter getLoginKey],self.strAutoid];
        [_web sendData:[GlobalParameter getIOTAddrByCAID:@"set_share_caid.i.php"] parameter:str];
    }
}
@end
