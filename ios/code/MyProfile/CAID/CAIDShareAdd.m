//
//  AccountManage.m
//  smart
//
//  Created by Han.zh on 14-8-6.
//  Copyright (c) 2014年 Han.zhihong. All rights reserved.
//

#import "CAIDShareAdd.h"
#import "HelpHeader.h"
#import "GlobalParameter.h"
#import "JSONKit.h"
#import "DefineHeader.h"
#import "WebBrower.h"
#import "WebProc.h"
#import "CAIDCell.h"
#import "CAIDEdit.h"
#import "CAIDShare.h"

@interface CAIDShareAdd ()<WebPocDelegate>
{
    __weak IBOutlet UIActivityIndicatorView *ind;
    __weak IBOutlet UITextField *txtCAID;
    __weak IBOutlet UITextField *txtSharekey;
    
    WebProc* _web;
}
- (IBAction)btnAddCAID_click:(id)sender;
@end

@implementation CAIDShareAdd

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


//左边插入文字
-(void)leftText:(UITextField*)target :(NSString*)title :(int)x
{
    //左边插入LABEL文字
    UILabel *lb1;
    lb1=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, x, 24)];
    [lb1 setText:title];
    [lb1 setTextAlignment:NSTextAlignmentRight];
    target.leftView = lb1;
    target.leftViewMode = UITextFieldViewModeAlways;
    lb1=nil;
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
    //
    [self leftText:txtCAID :NSLocalizedString(@"CAID: ", nil) :80];
    [self leftText:txtSharekey :NSLocalizedString(@"ShareKey: ", nil) :80];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//////////////////////////////////////////////////////////////////

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
    if([page isEqualToString:@"add_share_caid.i.php"])
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
            case 5://分享码错误
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert", nil)
                                    message:NSLocalizedString(@"Share key fail", nil)
                                   delegate:self
                          cancelButtonTitle:NSLocalizedString(@"ok", nil)
                          otherButtonTitles:nil];
                [alert show];
                alert=nil;
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

////////////////////////////////////////////////////////////

- (IBAction)btnAddCAID_click:(id)sender
{
    if([txtCAID.text isEqualToString:@""])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert", nil)
                                                        message:NSLocalizedString(@"CAID can't null", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                              otherButtonTitles:nil];
        [alert show];
        alert=nil;
        return ;
    }
    if([txtSharekey.text isEqualToString:@""] || [txtSharekey.text isEqualToString:@"0"])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert", nil)
                                                        message:NSLocalizedString(@"share key can't empty", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                              otherButtonTitles:nil];
        [alert show];
        alert=nil;
        return ;
    }
    NSString *ttCAID;
    ttCAID = [txtCAID.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *ttShareKey;
    ttShareKey = [txtSharekey.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString* str=[NSString stringWithFormat:@"k=%@&caid=%@&sharekey=%@",
                   [GlobalParameter getLoginKey],
                   ttCAID,
                   ttShareKey];
    [_web sendData:[GlobalParameter getIOTAddrByCAID:@"add_share_caid.i.php"] parameter:str];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"AlertView.tag%ld ,buttonIndex=%ld",alertView.tag,buttonIndex);
    
    switch (alertView.tag) {
        case 1822:
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
    }
}
@end
