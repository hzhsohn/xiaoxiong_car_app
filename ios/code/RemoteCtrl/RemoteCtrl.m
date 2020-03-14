//
//  RemoteCtrl.m
//  home
//
//  Created by Han.zh on 2017/6/16.
//  Copyright © 2017年 Han.zhihong. All rights reserved.
//

#import "RemoteCtrl.h"
#import "HelpHeader.h"
#import "WebProc.h"
#import "JSONKit.h"
#import "DefineHeader.h"
#import "ProjectAccountCfg.h"
#import "GlobalParameter.h"
#import "RemoteDev.h"

@interface RemoteCtrl ()<WebPocDelegate>
{
    WebProc* _web;
    __weak IBOutlet UIActivityIndicatorView *ind;
    __weak IBOutlet UITableView *tbView;
    NSMutableArray * _aryCAID;
    __weak IBOutlet UILabel *viNoLogin;
    __weak IBOutlet UILabel *lbNoLogin;

    NSMutableArray * aryOnlineDev;
}

- (NSString*) documentPath:(NSString*)str;
-(void)viewLoadingWeb;

@end

@implementation RemoteCtrl

- (void)awakeFromNib{
    [super awakeFromNib];
    _web=[[WebProc alloc] init];
    _web.delegate=self;
    _aryCAID=[[NSMutableArray alloc] init];

    //
    aryOnlineDev=[[NSMutableArray alloc] init];
}

-(void)dealloc
{
    _web.delegate=nil;
    _web=nil;
    
    [_aryCAID removeAllObjects];
    _aryCAID=nil;
    
    [aryOnlineDev removeAllObjects];
    aryOnlineDev=nil;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置标题
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [UIColor whiteColor],NSForegroundColorAttributeName,
                          [UIFont systemFontOfSize:17],NSFontAttributeName,
                          nil];
    self.navigationController.navigationBar.titleTextAttributes=dict;
    
    //初始化
    [ind setBounds:CGRectMake(0, 0, 130, 130)];
    [ind setBackgroundColor:[UIColor grayColor]];
    ind.alpha=0.0f;
    ind.layer.cornerRadius = 10;//设置那个圆角的有多圆
    ind.layer.borderWidth = 0;//设置边框的宽度
    [ind setHidden:YES];
    
    //加载设备
    [self viewLoadingWeb];
}

-(void)viewWillAppear:(BOOL)animated
{
    //去除那个选择后的条
    [tbView reloadData];
}

- (void)didReceiveMemoryWarning {
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

-(void)viewLoadingWeb
{
    NSString*key=[ProjectAccountCfg getKey];
    if(nil==key || [key isEqualToString:@""])
    {
        [lbNoLogin setText:NSLocalizedString(@"no login", nil)];
        [_aryCAID removeAllObjects];
        [tbView reloadData];
        viNoLogin.hidden=NO;
    }
    else
    {
        //获取CAID信息
        NSString* str=[NSString stringWithFormat:@"k=%@",key];
        [_web sendData:[GlobalParameter getIOTAddrByCAID:@"getcaid.i.php"] parameter:str];
        viNoLogin.hidden=YES;
    }
}


 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 
     if ([segue.identifier isEqualToString:@"segRDL"])
     {
         RemoteDev *p=(RemoteDev *)segue.destinationViewController;
         NSDictionary*dic=(NSDictionary*)sender;
         p.sCAID=[dic objectForKey:@"caid"];
         p.sTitle=[dic objectForKey:@"title"];
     }
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
    return 60;
}

//////////////////////////////////////////////////////////////////
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSDictionary*dic=[_aryCAID objectAtIndex:indexPath.row];
    
    NSString*str= [NSString stringWithFormat:@"  %@ -- %@",
                   [dic objectForKey:@"caid"],
                   [dic objectForKey:@"title"]];
    
    cell.textLabel.text = str;
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary*dic=[_aryCAID objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"segRDL" sender:dic];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @" ";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return nil;
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
                    [tbView reloadData];
                    //----------------------------------
                    //只有一条记录时自动跳转
                    if(1==[_aryCAID count])
                    {
                        NSDictionary*dic=[_aryCAID objectAtIndex:0];
                        [self performSegueWithIdentifier:@"segRDL" sender:dic];
                    }
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
    
    [ind setAlpha:0];
    [ind setHidden:YES];
    [ind stopAnimating];
}
-(void) WebProcCallBackFail:(NSURL*)url
{    
    [ind setAlpha:0];
    [ind setHidden:YES];
    [ind stopAnimating];
    
    alert_ok(self, 0, @"alert", @"connect network fail.");

}

@end
