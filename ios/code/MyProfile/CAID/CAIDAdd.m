//
//  AccountManage.m
//  smart
//
//  Created by Han.zh on 14-8-6.
//  Copyright (c) 2014年 Han.zhihong. All rights reserved.
//

#import "CAIDAdd.h"
#import "HelpHeader.h"
#import "GlobalParameter.h"
#import "JSONKit.h"
#import "DefineHeader.h"
#import "WebBrower.h"
#import "WebProc.h"
#import "CAIDCell.h"
#import "CAIDEdit.h"
#import "CAIDShare.h"

@interface CAIDAdd ()<WebPocDelegate>
{
    __weak IBOutlet UIActivityIndicatorView *ind;
    __weak IBOutlet UILabel *lbCAID;
    __weak IBOutlet UITextField *txtTitle;
    
    WebProc* _web;
    NSMutableArray * _aryCAID;
    NSString* randCAID;
}
- (IBAction)btnAddCAID_click:(id)sender;
@end

@implementation CAIDAdd

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
    randCAID=@"";
    //
    srand((unsigned int)time(NULL));
    lbCAID.text=[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"CAID: ", nil),@""];
    [self leftText:txtTitle :NSLocalizedString(@"Title: ", nil) :60];
    txtTitle.text=[NSString stringWithFormat:NSLocalizedString(@"NODE%d", nil),rand()%10000+1000];
    //
    //获取随机CAID
    [_web sendData:[GlobalParameter getIOTAddrByCAID:@"rand_caid.i.php"] parameter:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
    if([page isEqualToString:@"rand_caid.i.php"])
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
                randCAID=[result objectForKey:@"caid"];
                lbCAID.text=[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"CAID: ", nil),randCAID];
            }
                break;
                default:
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert", nil)
                                                                message:NSLocalizedString(@"get rand CAID fail.", nil)
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                                      otherButtonTitles:nil];
                alert.tag=1822;
                [alert show];
                alert=nil;
                goto _nnc;
            }
                break;
        }
    }
    else if([page isEqualToString:@"newcaid.i.php"])
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
                NSDictionary*dct=[result objectForKey:@"ary"];
                [_aryCAID addObject:dct];
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
            case 5://CAID already exist
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert", nil)
                                                                message:NSLocalizedString(@"CAID already exist", nil)
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
    if([txtTitle.text isEqualToString:@""])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert", nil)
                                                        message:NSLocalizedString(@"CAID title can't empty", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                              otherButtonTitles:nil];
        [alert show];
        alert=nil;
        return ;
    }
    NSString *ttTitle;
    ttTitle = [txtTitle.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString* str=[NSString stringWithFormat:@"k=%@&caid=%@&title=%@",
                   [GlobalParameter getLoginKey],
                   randCAID, ttTitle];
    [_web sendData:[GlobalParameter getIOTAddrByCAID:@"newcaid.i.php"] parameter:str];
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
