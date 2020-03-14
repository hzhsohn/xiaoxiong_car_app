//
//  AccountManage.m
//  smart
//
//  Created by Han.zh on 14-8-6.
//  Copyright (c) 2014年 Han.zhihong. All rights reserved.
//

#import "ModifyNickame.h"
#import "HelpHeader.h"
#import "GlobalParameter.h"
#import "JSONKit.h"
#import "DefineHeader.h"
#import "WebBrower.h"
#import "WebProc.h"
#import "LoginInfo.h"

@interface ModifyNickame ()<WebPocDelegate>
{
    __weak IBOutlet UIActivityIndicatorView *ind;
    __weak IBOutlet UITextField *txtContent;
    
    WebProc* _web;
}
- (IBAction)btnModify_click:(id)sender;
@end

@implementation ModifyNickame

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
    
    NSString* nickname;
    nickname=[LoginInfo get:@"nickname"];
    txtContent.text=nickname;
    
    //初始化
    [ind setBackgroundColor:[UIColor grayColor]];
    ind.alpha=0.0f;
    ind.layer.cornerRadius = 0;//设置那个圆角的有多圆
    ind.layer.borderWidth = 0;//设置边框的宽度
    [ind setHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    if([page isEqualToString:@"mod_nickname.i.php"])
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
                [ind setAlpha:0];
                [ind setHidden:YES];
                [LoginInfo set:txtContent.text key:@"nickname"];
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


- (IBAction)btnModify_click:(id)sender
{
    NSString *ttCnt;
    ttCnt = [txtContent.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //更新记录
    NSString* str=[NSString stringWithFormat:@"k=%@&c=%@",
                   [GlobalParameter getLoginKey],
                   ttCnt];
    [_web sendData:[GlobalParameter getAccountAddrByMob:@"mod_nickname.i.php"] parameter:str];
}
@end
