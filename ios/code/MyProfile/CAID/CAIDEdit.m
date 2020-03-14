//
//  AccountManage.m
//  smart
//
//  Created by Han.zh on 14-8-6.
//  Copyright (c) 2014年 Han.zhihong. All rights reserved.
//

#import "CAIDEdit.h"
#import "HelpHeader.h"
#import "GlobalParameter.h"
#import "JSONKit.h"
#import "DefineHeader.h"
#import "WebBrower.h"
#import "WebProc.h"
#import "CAIDModify.h"

@interface CAIDEdit ()<WebPocDelegate,CAIDModifyDelegate>
{
    __weak IBOutlet UIActivityIndicatorView *ind;
    
    WebProc* _web;
}
- (IBAction)btnDelete_click:(id)sender;
@end

@implementation CAIDEdit

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
    
    //初始化
    [ind setBackgroundColor:[UIColor grayColor]];
    ind.alpha=0.0f;
    ind.layer.cornerRadius = 0;//设置那个圆角的有多圆
    ind.layer.borderWidth = 0;//设置边框的宽度
    [ind setHidden:YES];
    
    [self showContent];
}

-(void)showContent
{
    //
    self.lbCAID.text=[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"CAID: ", nil),self.strCAID];
    self.lbTitle.text=[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"Title: ", nil),self.strTitle];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segTitle"])
    {
        CAIDModify *p=(CAIDModify *)segue.destinationViewController;
        p.strContent=self.strTitle;
        p.strTitle=NSLocalizedString(@"Title", nil);
        p.modify_autoid=self.strAutoid;
        p.delegate=self;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 1:
            [self performSegueWithIdentifier:@"segTitle" sender:self.strCAID];
            break;
    }
}


//////////////////////////////////////////////////////////////////
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
    
    if([page isEqualToString:@"delcaid.i.php"])
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


- (IBAction)btnDelete_click:(id)sender
{
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil
                                                  message:NSLocalizedString(@"is delete CAID ?", nil)
                                                 delegate:self
                                        cancelButtonTitle:NSLocalizedString(@"cancel", nil)
                                        otherButtonTitles:NSLocalizedString(@"ok", nil),nil];
    alert.tag=10011;
    [alert show];
    alert=NULL;
}

///////////////////////////////////
-(void)CAIDModifyContent_change:(NSString*)strContent
{
    self.strTitle=strContent;
    [self showContent];
}


//重载的函数
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case 10011:
        {
            if(buttonIndex==1)
            {
                //删除记录
                NSString* str=[NSString stringWithFormat:@"k=%@&autoid=%@",[GlobalParameter getLoginKey],self.strAutoid];
                [_web sendData:[GlobalParameter getIOTAddrByCAID:@"delcaid.i.php"] parameter:str];
            }
        }
            break;
    }
}

@end
