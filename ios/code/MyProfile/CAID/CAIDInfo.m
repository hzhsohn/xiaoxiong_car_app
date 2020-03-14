//
//  AccountManage.m
//  smart
//
//  Created by Han.zh on 14-8-6.
//  Copyright (c) 2014年 Han.zhihong. All rights reserved.
//

#import "CAIDInfo.h"
#import "HelpHeader.h"
#import "GlobalParameter.h"
#import "JSONKit.h"
#import "DefineHeader.h"
#import "WebBrower.h"
#import "WebProc.h"
#import "CAIDCell.h"
#import "CAIDEdit.h"
#import "CAIDShare.h"
#import "CAIDShareAdd.h"

@interface CAIDInfo ()<WebPocDelegate,CAIDCellDelegate,UIActionSheetDelegate>
{
    __weak IBOutlet UIActivityIndicatorView *ind;
    
    WebProc* _web;
    NSMutableArray * _aryCAID;
}
- (NSString*) documentPath:(NSString*)str;
- (IBAction)btnAdd_click:(id)sender;
@end

@implementation CAIDInfo

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
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //获取CAID信息
    NSString* str=[NSString stringWithFormat:@"k=%@",[GlobalParameter getLoginKey]];
    [_web sendData:[GlobalParameter getIOTAddrByCAID:@"getcaid.i.php"] parameter:str];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString*) documentPath:(NSString*)str
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    if (nil!=str) {
        return [NSString stringWithFormat:@"%@/%@",documentsDirectory,str];
    }
    return [NSString stringWithFormat:@"%@",documentsDirectory];
}

//////////////////////////////////////////////////////////////////
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_aryCAID count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 76;
}
//////////////////////////////////////////////////////////////////
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //CELL
    CAIDCell* cell = (CAIDCell *)[tableView dequeueReusableCellWithIdentifier: @"CAIDCell_ID"];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CAIDCell"
                                                     owner:self options:nil];
        // NSLog(@"nib %d",[nib count]);
        for (id oneObject in nib)
            if ([oneObject isKindOfClass:[CAIDCell class]])
                cell = (CAIDCell *)oneObject;
    }
    
    NSDictionary*dic=[_aryCAID objectAtIndex:indexPath.row];
    cell.aryInfo=dic;
    cell.delegate=self;
    [cell.lbTitle setText:[dic objectForKey:@"title"]];
    [cell.lbCAID setText:[dic objectForKey:@"caid"]];
    
    NSString*sharekey=[dic objectForKey:@"sharekey"];
    if(sharekey)
    {
        cell.btnShare.selected=([sharekey integerValue]>0?TRUE:FALSE);
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    
    if ([segue.identifier isEqualToString:@"segEdit"])
    {
        NSDictionary*dic=(NSDictionary*)sender;
        CAIDEdit *p=(CAIDEdit *)segue.destinationViewController;
        NSString* strAutoid=[dic objectForKey:@"autoid"];
        NSString* strCAID=[dic objectForKey:@"caid"];
        NSString* strTitle=[dic objectForKey:@"title"];
        if(strAutoid)
        {
            p.strAutoid=strAutoid;
            p.strCAID=strCAID;
            p.strTitle=strTitle;
        }
    }
    else if ([segue.identifier isEqualToString:@"segShare"])
    {
        NSDictionary*dic=(NSDictionary*)sender;
        CAIDShare *p=(CAIDShare *)segue.destinationViewController;
        NSString* strAutoid=[dic objectForKey:@"autoid"];
        NSString* strCAID=[dic objectForKey:@"caid"];
        NSString* strTitle=[dic objectForKey:@"title"];
        NSString* strSharekey=[dic objectForKey:@"sharekey"];
        if(strAutoid)
        {
            p.strAutoid=strAutoid;
            p.strCAID=strCAID;
            p.strSharekey=strSharekey;
            p.strTitle=strTitle;
        }
    }
    else if ([segue.identifier isEqualToString:@"segAddShare"])
    {
        NSDictionary*dic=(NSDictionary*)sender;
        CAIDShareAdd *p=(CAIDShareAdd *)segue.destinationViewController;
        NSString* strAutoid=[dic objectForKey:@"autoid"];
        NSString* strCAID=[dic objectForKey:@"caid"];
        NSString* strTitle=[dic objectForKey:@"title"];
        NSString* strSharekey=[dic objectForKey:@"sharekey"];
        if(strAutoid)
        {
            p.strAutoid=strAutoid;
            p.strCAID=strCAID;
            p.strSharekey=strSharekey;
            p.strTitle=strTitle;
        }
    }
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
    
    if([page isEqualToString:@"getcaid.i.php"])
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
                    //----------------------------------
                    [_aryCAID removeAllObjects];
                    [_aryCAID addObjectsFromArray:aryy];
                    [self.tableView reloadData];
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
            default:
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
                [self.tableView reloadData];
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

////////////////////////////////////////////////////////////
-(void)CAIDCell_Modify_click:(NSDictionary*)info
{
    [self performSegueWithIdentifier:@"segEdit" sender:info];
}
-(void)CAIDCell_ShareKey_click:(NSDictionary*)info
{
    [self performSegueWithIdentifier:@"segShare" sender:info];
}

- (IBAction)btnAdd_click:(id)sender
{
    // 创建时仅指定取消按钮
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"ADD CAID", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                         destructiveButtonTitle:NSLocalizedString(@"Add My New CAID", nil)
                                              otherButtonTitles:NSLocalizedString(@"Add Share CAID", nil),nil];
    [sheet showFromRect:CGRectMake(0, 0,500,500) inView:self.view animated:YES];
    sheet=nil;
}
//---------------
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"buttonIndex=%ld",buttonIndex);
    switch (buttonIndex) {
        case 0:
            [self performSegueWithIdentifier:@"segAdd" sender:nil];
            break;
        case 1:
            [self performSegueWithIdentifier:@"segAddShare" sender:nil];
            break;
    }
}
@end
