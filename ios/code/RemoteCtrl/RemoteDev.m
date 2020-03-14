//
//  RemoteCtrl.m
//  home
//
//  Created by Han.zh on 2017/6/16.
//  Copyright © 2017年 Han.zhihong. All rights reserved.
//

#import "RemoteDev.h"
#import "HelpHeader.h"
#import "WebProc.h"
#import "JSONKit.h"
#import "DefineHeader.h"
#import "ProjectAccountCfg.h"
#import "GlobalParameter.h"
#import "Remote_DevCell.h"
#import "DevKeyMagr.h"
#import "DevPasswdMagr.h"
#import "DevlistCellLoadForm.h"

@interface RemoteDev ()<WebPocDelegate>
{
    WebProc* _web;
    __weak IBOutlet UIActivityIndicatorView *ind;
    __weak IBOutlet UITableView *tbView;
    NSMutableArray * aryObj;
    int aryCAID_ObjPos;
    
    
    //
    DevlistCellLoadForm * loadFrm;
}

-(void)loadingWeb;
- (IBAction)btnEdit_click:(id)sender;

@end

@implementation RemoteDev

- (void)awakeFromNib{
    [super awakeFromNib];
    _web=[[WebProc alloc] init];
    _web.delegate=self;
    aryObj=[[NSMutableArray alloc] init];
    //
    loadFrm=[[DevlistCellLoadForm alloc] init];
}

-(void)dealloc
{
    _web.delegate=nil;
    _web=nil;
    
    [aryObj removeAllObjects];
    aryObj=nil;
    
    loadFrm=nil;
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
    
    //
    self.title=self.sTitle;
    
    //加载设备
    [self loadingWeb];
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

-(void)loadingWeb
{
    NSString* str=[NSString stringWithFormat:@"%@/get-dev.php?caid=%@",
                   IOT_URL_DEV,
                   self.sCAID];
    [_web sendData:str parameter:nil];
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

//////////////////////////////////////////////////////////////////
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [aryObj count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @" ";
}

//////////////////////////////////////////////////////////////////
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //内容
    Remote_DevCell*cell=NULL;
    
    //
    NSDictionary*dic=[aryObj objectAtIndex:indexPath.row];
    char* devflag=(char*)[[dic objectForKey:@"flag"] UTF8String];
    
    //////
    cell = (Remote_DevCell *)[tableView dequeueReusableCellWithIdentifier: @"Remote_DevCell"];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"Remote_DevCell"
                                                     owner:self options:nil];
        // NSLog(@"nib %d",[nib count]);
        for (id oneObject in nib)
            if ([oneObject isKindOfClass:[Remote_DevCell class]])
                cell = (Remote_DevCell *)oneObject;
    }
    
    /////
    BOOL b=[[dic objectForKey:@"online"] boolValue];
    [cell setOnline:b];
    cell.devflag=[NSString stringWithUTF8String:devflag];
    cell.uuid=[dic objectForKey:@"uuid"];
    cell.lbTitle.text = [NSString stringWithFormat:@"%@",[dic objectForKey:@"name"]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* devUUID=nil;
    NSString* devname=nil;
    NSString* devflag=nil;
    
    NSLog(@"section=%ld row=%ld",indexPath.section,indexPath.row);

    NSDictionary*dic=[aryObj objectAtIndex:indexPath.row];
    if(dic)
    {
        BOOL b=[[dic objectForKey:@"online"] boolValue];
        if(b)
        {
            //设备在线
            devUUID=[dic objectForKey:@"uuid"];
            devname=[dic objectForKey:@"name"];
            devflag=[dic objectForKey:@"flag"];
            
            /////////////////////////////////
            //一体界面
            DeviceIDTemplate *frm;
            frm=[loadFrm loadStoryboard:1
                                       :[devflag UTF8String]
                                       :[devUUID UTF8String]
                                       :[devname UTF8String]
                                       :""
                                       :"" :0];
            if(frm)
            {
                [self.navigationController pushViewController:frm animated:YES];
            }
        }
    }
}

//删除
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath!=nil)
    {
        NSDictionary*dic=[aryObj objectAtIndex:indexPath.row];
        if(dic)
        {
            BOOL b=[[dic objectForKey:@"online"] boolValue];
            if(b)
            {
                //设备在线,不允许删除
                alert_err(@"alert",@"online device can't remove");
            }
            else
            {
                NSString* str=[NSString stringWithFormat:@"%@/remove-dev.php?caid=%@&uuid=%@",
                               IOT_URL_DEV,
                               self.sCAID,
                               [dic objectForKey:@"uuid"]];
                [_web sendData:str parameter:nil];
                
                //删除表格内的
                [aryObj removeObjectAtIndex:indexPath.row];
                //
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
        }
    }
}

- (IBAction)btnEdit_click:(id)sender
{
    [tbView setEditing:!tbView.editing animated:YES];
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
    
    NSLog(@"url=%@",[url relativeString]);
    NSString *page=[url lastPathComponent];
    NSLog(@"page=%@",page);
    
    NSData *safeJsonData = [_web getSafeJsonData:data];
    NSString *ss = [[NSString alloc] initWithData:safeJsonData encoding:NSUTF8StringEncoding];
    
    if (0==[safeJsonData length]) {
        return;
    }
    
    if([page isEqualToString:@"get-dev.php"])
    {
        //解释data
        NSDictionary *result = [safeJsonData objectFromJSONData];
        if(nil==result)
        {
            alert_err(@"json_data_fail",ss);
            
        }
        else{
            [aryObj removeAllObjects];
            NSArray *dev = [result objectForKey:@"dev"];
            NSLog(@"%@",dev);
            [aryObj addObjectsFromArray:dev];
            [tbView reloadData];
        }
    }
    else if([page isEqualToString:@"remove-dev.php"])
    {
        //解释data
        NSDictionary *result = [safeJsonData objectFromJSONData];
        if(nil==result)
        {
            alert_err(@"json_data_fail",ss);
            [self loadingWeb];
        }
        else{
            NSString*json_caid= [result objectForKey:@"caid"];
            if([json_caid isEqualToString:self.sCAID])
            {
                NSString*json_uuid= [result objectForKey:@"uuid"];
                if(json_uuid)
                {
                    for(int i=0;i<[aryObj count];i++)
                    {
                        NSDictionary*dic=[aryObj objectAtIndex:i];
                        if([json_uuid isEqualToString:[dic objectForKey:@"uuid"]])
                        {
                            [tbView reloadData];
                        }
                    }
                }
            }
            else
            {
                alert_err(@"alert",ss);
            }
        }
    }
}
-(void) WebProcCallBackFail:(NSURL*)url
{
    [ind setAlpha:0];
    [ind setHidden:YES];
    [ind stopAnimating];
    
    NSLog(@"url=%@",[url relativeString]);
    NSString *page=[url lastPathComponent];
    NSLog(@"page=%@",page);
    
    if([page isEqualToString:@"remove-dev.php"])
    {
        //删除失败
        alert_err(@"alert",@"remove device fail. please retry");
        [self loadingWeb];
    }
    else
    {
        alert_ok(self, 0, @"alert", @"connect network fail.");
    }
}

@end
