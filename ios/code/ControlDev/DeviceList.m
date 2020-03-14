//
//  DeviceList.m
//  discolor-led
//
//  Created by Han.zh on 15/2/7.
//  Copyright (c) 2015年 Han.zhihong. All rights reserved.
//

#import "JSONKit.h"
#import "DeviceList.h"
#import "DevListCell.h"
#import "DevKeyMagr.h"
#import "DeviceIDTemplate.h"
#import  <libHxkNet/McuNet.h>
#import "DevlistCellLoadForm.h"
#import "HelpHeader.h"
#import "DefineHeader.h"
#import "WebProc.h"
#import "Reachability.h"
#import "DevPasswdMagr.h"

//搜索服务
MSDSearchDev *msdSearchDev;
//
@interface DeviceList ()<MSDSearchDevDelegate,WebPocDelegate>
{
    //当前网络状态
    Reachability* rbty;
    //
    WebProc* _web;
    __weak IBOutlet UIBarButtonItem *itmRight;
    
    DevKeyMagr* _devmgr;   //数据库操作对象
    DevPasswdMagr* _devPasswd;
    NSMutableArray *_aryDevInDB;//数据库中有保存的设备
    NSMutableArray *_aryDevYunOnline;//云在线的设备

    __weak IBOutlet UITableView *tbView;
    __weak IBOutlet UIView *viToolBtn;

    //
    DevlistCellLoadForm* loadFrm;
    //
    NSInteger cur_indexPath_row;
    //最后检测云在线的时间
    time_t lastChckYunOnline;
    NSTimer *_timer;
}
//
-(void)checkDevWebOnline;
//
-(NSArray *)cellsForTableView:(UITableView *)tableView;
//界面恢复初始化操作
-(void)viewInitOperator;

//更新网络信息
-(void)updateInfo:(NSString*)devname :(NSString*)devflag :(NSString*)dvar;
//保存到数据库
-(void)saveNewDev:(NSString*)devUUID :(NSString*)devtype :(NSString*)devname;

@end

@implementation DeviceList

-(void)awakeFromNib
{
    [super awakeFromNib];

    _web=[[WebProc alloc] init];
    _web.delegate=self;
    
    //钥匙数据库
    _devmgr=[[DevKeyMagr alloc] init];
    _devPasswd=[[DevPasswdMagr alloc] init];
    //读取钥匙的列表
    _aryDevInDB=[[NSMutableArray alloc] init];
    //
    loadFrm=[[DevlistCellLoadForm alloc] init];
    //云在线
    _aryDevYunOnline=[[NSMutableArray alloc] init];
    //
    msdSearchDev=[[MSDSearchDev alloc] init];
    [msdSearchDev.delegateArray addObject:self];
}

-(void)dealloc
{
    //[super dealloc];
    NSLog(@"DeviceList dealloc");
    
    _web.delegate=nil;
    _web=nil;
    
    [_aryDevInDB removeAllObjects];
    _aryDevInDB=nil;
    
    _devmgr=nil;
    _devPasswd=nil;

    [msdSearchDev stopService];
    msdSearchDev.delegateArray=nil;
    msdSearchDev=nil;
    
    loadFrm=nil;
    
    [_aryDevYunOnline removeAllObjects];
    _aryDevYunOnline=nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //修改背景----------------------------------------
#if 0
    UIImageView*backView = [[UIImageView alloc] initWithFrame:tbView.frame];
    [backView setImage:[UIImage imageNamed:@"bg"]];
    [backView setAutoresizingMask: UIViewAutoresizingFlexibleLeftMargin |
                                    UIViewAutoresizingFlexibleWidth |
                                    UIViewAutoresizingFlexibleRightMargin |
                                    UIViewAutoresizingFlexibleTopMargin |
                                    UIViewAutoresizingFlexibleHeight |
                                    UIViewAutoresizingFlexibleBottomMargin];
    [backView setContentMode:UIViewContentModeScaleAspectFit];
    [tbView setBackgroundView:backView];
    backView=nil;
#endif
    //-----------------------------------------------/
    
    // Do any additional setup after loading the view, typically from a nib.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(devlstActive:)
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fuckBack:)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    //去除UITableView空白的多余的分割线
    tbView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    //
    [self viewInitOperator];
    //netStatus值,启用蜂窝网络时值为2,启用WIFI为1,什么网络都没有为0
    rbty = [Reachability reachabilityForInternetConnection];
    [rbty startNotifier];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //设置标题
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [UIColor whiteColor],NSForegroundColorAttributeName,
                          [UIFont systemFontOfSize:17],NSFontAttributeName,
                          nil];
    self.navigationController.navigationBar.titleTextAttributes=dict;

    //
    [self viewInitOperator];
    
    //判断是否在局域网内
    NetworkStatus netStatus = [rbty currentReachabilityStatus];
    if(ReachableViaWiFi==netStatus)
    {
        [msdSearchDev startService];
    }
    
    //一个定时器
    if(nil==_timer)
    {
    _timer = [NSTimer scheduledTimerWithTimeInterval: 1//秒
                                              target: self
                                            selector: @selector(handleTimer:)
                                            userInfo: nil
                                             repeats: YES];
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    if(_timer)
    {
        [_timer invalidate];
        _timer = nil;
    }
    [super viewDidDisappear:animated];
    [msdSearchDev stopService];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) handleTimer: (NSTimer *) timer
{
    time_t tmp=time(NULL);
    //定时检测云在线
    if(tmp-lastChckYunOnline > 20) //20秒
    {
        NSLog(@"重新检测云在线...");
        lastChckYunOnline=tmp;
        [self checkDevWebOnline];
    }
}

-(void)viewInitOperator
{
    //读取数据库中的设备,重载当前数据库结构
    NSMutableArray *arytmp=[[NSMutableArray alloc] init];
    NSMutableArray *aryIsOnline2=[[NSMutableArray alloc] init];
    [_devmgr getDevInfoAllKeyMgr:arytmp];
    //在线设备
    [msdSearchDev getDevNSDataArray:aryIsOnline2];
   // NSLog(@"aryonline count=%ld",aryIsOnline2.count);
    
    //重置列表数据
    [_aryDevInDB removeAllObjects];
    
    for (NSData*d in arytmp) {
        DevListInfo* dp=[[DevListInfo alloc] init];
        TzhKeyMgr *p=(TzhKeyMgr*)[d bytes];
        dp.dbInfo=*p;
        dp.devUUID=[NSString stringWithUTF8String:p->devUUID];
        dp.devname=[NSString stringWithUTF8String:p->devname];
        dp.devflag=[NSString stringWithUTF8String:p->devflag];
        dp.dvar=@"";
        dp.isLANOnline=FALSE;
        dp.isYunOnline=FALSE;
        //恢复局域网在线设备
        for (MSDSearchInfo*pa in aryIsOnline2) {
            if([pa.devname isEqualToString:dp.devname] &&
               [pa.devflag isEqualToString:dp.devflag])
            {
                dp.isLANOnline=TRUE;
                dp.ip=pa.ip;
                dp.port=pa.port;
            }
        }
        //恢复Yun在线
        for(NSString *uuid in _aryDevYunOnline)
        {
            if([dp.devUUID isEqualToString:uuid])
            {
                dp.isYunOnline=TRUE;
            }
        }
        //
        [_aryDevInDB addObject:dp];
    }
    
    [arytmp removeAllObjects];
    arytmp=nil;
    [aryIsOnline2 removeAllObjects];
    aryIsOnline2=nil;
    //
    [tbView reloadData];
}

-(void)devlstActive:(NSNotification*)notification
{
    NSLog(@"devlstActive");
    [self viewInitOperator];
    [msdSearchDev startService];
    [msdSearchDev resetQuickSearch];
}

-(void)fuckBack:(NSNotification*)notification
{
    [msdSearchDev stopService];
}

//////////////////////////////////////////////////
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_aryDevInDB count];
}

/////////////////////////////////////////////
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        //内容
        DevListCell*cell;
        DevListInfo *p=(DevListInfo *)[_aryDevInDB objectAtIndex:indexPath.row];
        
        cell=[DevListCell loadTableCell:p.dbInfo.devflag Table:tableView];
    
        cell.pDevInfo=p;
        [cell setOnline:p.isLANOnline :p.isYunOnline];
        [cell setTitle:p.devname];
        cell.indexPathRow=indexPath.row;
        cell.IndexPathSection=indexPath.section;
        //设置支持的设备
        [cell setUnkonwDev:![loadFrm checkDevDepend:p.dbInfo.devflag]];

        return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
        DevListInfo *p=(DevListInfo *)[_aryDevInDB objectAtIndex:indexPath.row];
        int netType=0;
        if(p.isLANOnline)
        {
            netType=0;
        }
        else if(p.isYunOnline)
        {
            netType=1;
        }

        if(p.isLANOnline || p.isYunOnline)
        {
            //-------------------------
            //一体界面
            DeviceIDTemplate *frm;
            frm=[loadFrm loadStoryboard:netType :p.dbInfo.devflag :(char*)[p.devUUID UTF8String] :p.dbInfo.devname :[p.dvar UTF8String] :(char*)[p.ip UTF8String] :p.port];
            if(frm)
            {
                [self.navigationController pushViewController:frm animated:YES];
            }
        }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @" ";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return nil;
}
////////////////////////////
-(void)updateInfo:(NSString*)devname :(NSString*)devflag :(NSString*)dvar
{
    if([dvar isEqualToString:@""])
    {return ;}
    
    NSArray* pary=[self cellsForTableView:tbView];
    for(DevListCell* dcell in pary)
    {
        //更新当前网络信息
        for (DevListInfo*dp in _aryDevInDB)
        {
            if(dcell.pDevInfo==dp && [dcell.devflag isEqualToString:dp.devflag])
            {
                    if (0==strcmp(dp.dbInfo.devname, [devname UTF8String]) &&
                        0==strcmp(dp.dbInfo.devflag, [devflag UTF8String]))
                    {
                        [loadFrm updateCell:dp.dbInfo.devflag :dcell :dvar];
                    }
            }
        }
    }
}

////////////////////////////////////////////////////////
//搜索在线硬件设备
-(void)MSDSearchDevOnLine:(MSDSearchInfo*)info
{
        NSLog(@"McuSearchDevOnLine:->(%@)%@:%d >var:>%@",
              info.devflag,
              info.ip,
              info.port,
              info.dvar);
        if ([info.devflag isEqualToString:@""])
        {
            return;
        }
    
        //查询是否已经在数据库里
        BOOL haveOnDB;
        if(nil==info.devUUID || [info.devUUID isEqualToString:@""])
        {            
            haveOnDB=[_devmgr getDevCheckDevname:info.devflag :info.devname];
        }
        else
        {
            haveOnDB=[_devmgr getDevCheckDevUUID:info.devUUID];
        }
        //查找不到就添加到数据库里
        if(NO==haveOnDB)
        {
            [self saveNewDev:info.devUUID :info.devflag :info.devname];
            [self viewInitOperator];
        }
    
        [self MSDSearchDevUpdate:info];
}

-(void)MSDSearchDevUpdate:(MSDSearchInfo*)info
{
        NSArray* pary=[self cellsForTableView:tbView];
        for(DevListCell* dcell in pary)
        {
            DevListInfo*difo=dcell.pDevInfo;
            if((info.devUUID!=nil &&
                ![info.devUUID isEqualToString:@""] &&
                [info.devUUID isEqualToString:difo.devUUID])
               ||
               ([info.devname isEqualToString:difo.devname] &&
                [info.devflag isEqualToString:difo.devflag]))
            {
                    difo.isLANOnline=TRUE;
                    difo.ip=info.ip;
                    difo.port=info.port;
                    difo.devUUID=info.devUUID;
                    difo.dvar=info.dvar;
                    [dcell setOnline:difo.isLANOnline :difo.isYunOnline];
                    [dcell.lbRemark setText:difo.ip];
                
                    //判断名称是否已经更新
                    if(![info.devname isEqualToString:difo.devname])
                    {
                        difo.devname=info.devname;
                        //更新数据库
                        [_devmgr updateDevname:difo.devname :difo.dbInfo.autoID];
                        dcell.lbTitle.text=difo.devname;
                    }
                
                    //更新CELL信息状态
                    [self updateInfo:info.devname :info.devflag :info.dvar];
                    
            }
        }
}

-(void)MSDSearchDevOffLine:(MSDSearchInfo*)info
{
        NSLog(@"McuSearchDevOffLine->%@:%d",info.ip,info.port);
        //重刷当前数据网络信息
        for (DevListInfo* dp in _aryDevInDB) {
            if ([dp.ip isEqualToString:info.ip] &&
                dp.port ==info.port &&
                [dp.devflag isEqualToString:info.devflag])
            {
                dp.isLANOnline=FALSE;
                NSArray* pary=[self cellsForTableView:tbView];
                for(DevListCell* dcell in pary)
                {
                    if(dcell.pDevInfo==dp)
                    {
                        [dcell setOnline:FALSE :dp.isLANOnline];
                        //刷新行
                        [tbView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:dcell.indexPathRow inSection:dcell.IndexPathSection]] withRowAnimation:UITableViewRowAnimationFade];
                    }
                }
            }
        }
}

//////////////////////////////////////////////////////////////////
-(NSArray *)cellsForTableView:(UITableView *)tableView
{
    //只遍历LocalDev的CELL
    int dodoSection=0;
    
    NSMutableArray *cells = [[NSMutableArray alloc]  init];
    NSInteger rows =  [tableView numberOfRowsInSection:dodoSection];
    for (int row = 0; row < rows; row++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:dodoSection];
        UITableViewCell*stdCell=[tableView cellForRowAtIndexPath:indexPath];
        if(stdCell)
        {
            [cells addObject:stdCell];
        }
    }
    return cells;
}

//////////////////////////////////////////////////////
-(void)saveNewDev:(NSString*)devUUID :(NSString*)devtype :(NSString*)devname
{
    TzhKeyMgrSaveInfo info={0};
    
    if(devUUID)
        strcpy(info.devUUID, (char*)[devUUID UTF8String]);
    if(devtype)
        strcpy(info.devflag,(char*)[devtype UTF8String]);
    if(devname)
        strcpy(info.devname, (char*)[devname UTF8String]);
   
    if (NO==[_devmgr insertDevInfo:&info])
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:nil
                                                      message:@"访问数据库失败!"
                                                     delegate:self
                                            cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                            otherButtonTitles:nil];
        [alert show];
        alert=NULL;
    }
}

////////////////////////////////////////////////////////
//网络回调
-(void)checkDevWebOnline
{
    NSMutableString*param=[NSMutableString string];
    
    NSMutableArray *arytmp=[[NSMutableArray alloc] init];
    [_devmgr getDevInfoAllKeyMgr:arytmp];
    for(NSData*da in arytmp)
    {
        TzhKeyMgr*p=(TzhKeyMgr*)[da bytes];
        if(strcmp(p->devUUID,""))
        {
            NSString* s1=[NSString stringWithFormat:@"%s",p->devUUID];
            s1=[s1 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [param appendString:@"&uuid="];
            [param appendString:s1];
        }
    }
    
    if(param)
    {
        NSString* str=[NSString stringWithFormat:@"%@/check-online.php?%@",IOT_URL_DEV,param];
        [_web sendData:str parameter:nil];
    }
}

-(void) WebProcCallBackBegin:(NSURL*)url
{
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
    
    if([page isEqualToString:@"check-online.php"])
    {
        //解释data
        NSDictionary *result = [safeJsonData objectFromJSONData];
        if(nil==result)
        {
            alert_err(@"json_data_fail",ss);
        }
        else{
            //更新重复检测时间
            lastChckYunOnline=time(NULL);
            //
            [_aryDevYunOnline removeAllObjects];
            NSArray *uuid = [result objectForKey:@"uuid"];
            [_aryDevYunOnline addObjectsFromArray:uuid];
            [self viewInitOperator];
        }
        
    }
}

-(void) WebProcCallBackFail:(NSURL*)url
{
    NSLog(@"url=%@",[url relativeString]);
    NSString *page=[url lastPathComponent];
    NSLog(@"page=%@",page);
    
    if([page isEqualToString:@"check-online.php"])
    {
        [self performSelector:@selector(checkDevWebOnline) withObject:nil afterDelay:1000];
    }
}

//当前网络状态改变后---------------
//Called by Reachability whenever status changes.
- (void) reachabilityChanged: (NSNotification* )note
{
    Reachability* curReach = [note object];
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    BOOL connectionRequired= [curReach connectionRequired];
    
    switch (netStatus)
    {
        case NotReachable:
        {
            //网络不可用
            connectionRequired= NO;
            NSLog(@"网络不可用");
            [_aryDevYunOnline removeAllObjects];
            [msdSearchDev stopService];
            [msdSearchDev clearAllDev];
            [self viewInitOperator];
            break;
        }
        case ReachableViaWiFi:
        {
            //WIFI网络
            NSLog(@"使用WIFI网络");
            [msdSearchDev startService];
            [self viewInitOperator];
            [self checkDevWebOnline];
            break;
        }
        case ReachableViaWWAN:
        {
            //Reachable WWAN蜂窝网络
            NSLog(@"WWAN蜂窝网络");
            [msdSearchDev stopService];
            [msdSearchDev clearAllDev];
            [self checkDevWebOnline];
            break;
        }
    }
}


@end
