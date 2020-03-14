//
//  CtrlMain_w1.m
//  discolor-led
//
//  Created by Han.zh on 15/2/17.
//  Copyright (c) 2015年 Han.zhihong. All rights reserved.
//

#import "Part_PM.h"
#import <libHxkNet/HxNetCacheCtrl.h>
#import "Part_PM_Cell_Ctrl.h"
#import "DevPasswdMagr.h"
#import "McuGlobalParameter.h"
#import  <libHxkNet/McuNet.h>
#import "HelpHeader.h"
#import "DefineHeader.h"

//网络控制
extern McuGlobalParameter *mcuParameter;

@implementation THxkKG
@end

@interface Part_PM ()<HxNetCacheCtrlDelegate,Part_PM_Cell_Delgate,MSDDelegate,McuYunDelegate>
{
    __weak IBOutlet UITableView *tbView;
    __weak IBOutlet UIActivityIndicatorView *inding;
    NSTimer *_timer;
    //按钮的数组
    NSMutableArray* aryOnOff;
    //MSD服务
    MSDService *msd;
    HxNetCacheCtrl *mcuCache;
    McuYun* yun;
    BOOL isYunConnectOK;
}

@property (weak, nonatomic) IBOutlet UIButton *btnAllOn;
@property (weak, nonatomic) IBOutlet UIButton *btnAllOff;

- (void)sendCtrl:(NSInteger) channel :(unsigned char)value;
- (void)sendCtrlALL:(uchar*)all_status :(int)len;
//查询状态
-(void) sendGetState;
- (IBAction)btnAllOn_click:(id)sender;
- (IBAction)btnAllOff_click:(id)sender;
//
-(void)loadNet;
@end

@implementation Part_PM


-(void)awakeFromNib
{
    [super awakeFromNib];
    aryOnOff=[[NSMutableArray alloc] init];
    //
    msd=[[MSDService alloc] init];
    [msd.delegateArray addObject:self];
    
    mcuCache=[[HxNetCacheCtrl alloc] init];
    [mcuCache.delegateArray addObject:self];
    
    yun=[[McuYun alloc] initWithDPID:IOT_DPID];
    [yun.delegateArray addObject:self];
    isYunConnectOK=FALSE;
}

-(void)dealloc
{
    [aryOnOff removeAllObjects];
    aryOnOff=nil;
    
    [msd stopService];
    [msd.delegateArray removeAllObjects];
    msd.delegateArray=nil;
    msd=nil;
    
    [mcuCache stopService];
    [mcuCache.delegateArray removeAllObjects];
    mcuCache.delegateArray=nil;
    mcuCache=nil;
    
    [yun stopService];
    [yun.delegateArray removeAllObjects];
    yun.delegateArray=nil;
    yun=nil;
}

- (IBAction)rightItemClick:(id)sender {
    UIStoryboard *frm=NULL;
    frm = [UIStoryboard storyboardWithName:@"ComponentPub" bundle:nil];
    UIViewController*tt = [frm instantiateInitialViewController];
    [self.navigationController pushViewController:tt animated:YES];
}

//--------------------------------------------------------
//检测是否返回
- (void)didMoveToParentViewController:(UIViewController*)parent{
    [super didMoveToParentViewController:parent];
    if(!parent){
        NSLog(@"页面pop成功了");
        [self disTimer];
        [yun.delegateArray removeObject:self];
        [msd.delegateArray removeObject:self];;
        [mcuCache.delegateArray removeObject:self];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //
    self.btnAllOn.layer.cornerRadius = 10;//设置那个圆角的有多圆
    self.btnAllOn.layer.borderWidth = 0;//设置边框的宽度
    //
    self.btnAllOff.layer.cornerRadius = 10;//设置那个圆角的有多圆
    self.btnAllOff.layer.borderWidth = 0;//设置边框的宽度
    [self.navigationController setNavigationBarHidden:NO];
    
    
    
    //初始化公共参数
    [mcuParameter clearAllParameter];
    [mcuParameter setParameter:@"netType" :[NSNumber numberWithInt:self.netType]];
    [mcuParameter setParameter:@"host" :self.host];
    [mcuParameter setParameter:@"port" :[NSNumber numberWithInt:self.port]];
    [mcuParameter setParameter:@"devUUID" :self.devUUID];
    [mcuParameter setParameter:@"devName" :self.devName];
    [mcuParameter setParameter:@"+msd" :msd];
    [mcuParameter setParameter:@"+cache" :mcuCache];
    [mcuParameter setParameter:@"+yun" :yun];
    NSData*ckey=[self getPasswordKey:self.devUUID];
    if(ckey)
    {
        [self loadNet];
    }
    else
    {
        //等待输入密码
        inding.hidden=YES;
        inding.alpha=0;
    }

}

-(void)loadNet
{
    [mcuParameter setParameter:@"ctrlKey" :self.ctrlKey];
    if(0==self.netType)
    {
        [self sendGetState];
    }
    else if(1==self.netType)
    {
        //连接到网络
        [yun getIotDispath];
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //设置标题
    self.title=self.devName;
    //
    [self setTimer];
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self disTimer];
}

-(void)fuckActive:(NSNotification*)notification
{
    NSLog(@"fuckActive");
    //
    [self setTimer];
    
}

-(void)fuckBack:(NSNotification*)notification
{
    [self disTimer];
    //返回到主界面,防止IP地址或者端口信息改变后不能控制
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

-(void) handleTimer: (NSTimer *) timer
{
     if(0==self.netType || TRUE==isYunConnectOK)
     {
         [self sendGetState];
     }
}


-(void)setTimer
{
    if (nil==_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval: 3//秒
                                                  target: self
                                                selector: @selector(handleTimer:)
                                                userInfo: nil
                                                 repeats: YES];
    }
}
-(void)disTimer
{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

//-----------------------------------------
-(void) send_cb:(MSDPacket*) packet
{
    NSLog(@"send_cb=%d",packet.packetID);
}
-(void) recvfrom:(char*)buff :(int) len :(NSString*) ipv4 :(int) port
{
    NSLog(@"recvfrom=%dbytes",len);
    [mcuCache recvCache:buff :len ipv4:ipv4 port:port];
}
-(void) err:(int)codeid :(NSString*) msg :(MSDPacket*) packet;
{
    NSLog(@"err=%@",msg);
}
//////////////////////////
-(void)McuYunGetDispatch:(NSString*)ip :(int)port
{
    [yun connect_start:ip port:port];
}
-(void)McuYunGetDispatchErr:(int)codeID errMsg:(NSString*)msg
{
    [yun getIotDispath];
}
//////////////////////////
-(void)McuYunConnectCallback:(BOOL) b
{
    if(b)
    {
        NSLog(@"连IOT接服务器成功");
    }
    else
    {
        NSLog(@"连IOT接服务器失败");
    }
}
-(void)McuYunConnectedDTRS
{
    NSLog(@"连接DTRS系统成功");
    [yun iotSubscr:[self.devUUID UTF8String]];
}
//////////////////////////
//保活包
-(void) eventKeep:(time_t)rtt
{}
//通讯数据
-(void) eventRecvData:(NSString*) devUUID buf:(const char*) buf len:(int) len
{
    [mcuCache recvCache:buf :len devUUID:devUUID];
}
//订阅数据回调成功
-(void) eventSubscrDev:(NSString*) devUUID
{
    if([devUUID isEqualToString:self.devUUID])
    {
        isYunConnectOK=TRUE;
        inding.hidden=YES;
        inding.alpha=0;
        //获取状态
        [self sendGetState];
    }
}
//取消订阅数据回调成功
-(void) eventUnsubscrDev:(NSString*) devUUID
{}
//是否在线
-(void) eventIsOnline:(NSString*) devUUID :(BOOL) online
{}
//////////////////////////
-(void)McuYunDisconnectCallback
{
    isYunConnectOK=FALSE;
    //
    inding.hidden=NO;
    inding.alpha=1;
    [yun getIotDispath];
}
//-----------------------------------------
-(void)HxNetDataRecv:(TzhNetFrame_Cmd*)data devUUID:(NSString*)uuid
{
    NSLog(@"HxNetDataRecv YUN=%dbytes",data->frame_len);
     [self recvProc:data];}
-(void)HxNetDataRecv:(TzhNetFrame_Cmd*)data ipv4:(NSString*)ipv4 port:(int)port
{
    [self recvProc:data];
}

-(void)recvProc:(TzhNetFrame_Cmd*)data
{
    //数据处理
    if(0==strcmp(data->flag,"<keyerr"))
    {
        alert_ok(self,888,@"alert",@"ctrl key fail.");
        [self disTimer];
    }
    else
        if(0==strcmp(data->flag,"PM"))
        {
            switch(data->parameter[0])
            {
                case 0x10 :
                {
                    //0x10 & uchar 通道数量n,循环[uchar 通道号码0~n的状态] ::::::::::::: 通道状态
                    int nnntmp=data->parameter[1];
                    //NSLog(@"[aryOnOff count]=%d, nnntmp=%d",[aryOnOff count],nnntmp);
                    if(0==[aryOnOff count]|| [aryOnOff count]!=nnntmp)
                    {
                        [aryOnOff removeAllObjects];
                        for(int i=0;i<nnntmp;i++)
                        {
                            THxkKG *tkg=[[THxkKG alloc] init];
                            tkg.channelName=[NSString stringWithFormat:NSLocalizedString(@"channel %d", nil),i];
                            tkg.isOn=data->parameter[2+i]?true:false;
                            [aryOnOff addObject:tkg];
                            tkg=nil;
                        }
                        [tbView reloadData];
                    }
                    else
                    {
                        //更新当前状态
                        for(int i=0;i<nnntmp;i++)
                        {
                            BOOL tmpb=false;
                            THxkKG *tkg=[aryOnOff objectAtIndex:i];
                            if(0x00!=data->parameter[2+i])
                            {
                                tmpb=true;
                            }
                            //NSLog(@"tkg.isOn=%d, i=%d ,tmpb=%d",tkg.isOn,i,tmpb);
                            if(tkg.isOn!=tmpb)
                            {
                                tkg.isOn=tmpb;
                                //如果开关状态不一样就更新那行的状态
                                [tbView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                            }
                            else{
                                tkg.isOn=tmpb;
                            }
                        }
                        
                    }
                    NSLog(@"kg channelCount=%ld",[aryOnOff count]);
                }
                    break;
            }
        }
}
//////////////////////////////////////////////////////////////////
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //隐藏加载
    if([aryOnOff count]>0)
    {
        inding.hidden=YES;
        inding.alpha=0;
    }
    return [aryOnOff count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Part_PM_Cell_Ctrl*cell;
    cell=[Part_PM_Cell_Ctrl loadTableCell:tableView];
    cell.cellRow=indexPath.row;
    cell.delegate=self;
    
    THxkKG*pkg=[aryOnOff objectAtIndex:indexPath.row];
    [cell setOnOff:pkg.isOn];
    [cell setText:pkg.channelName];
    [cell.lbTitle setText:pkg.channelName];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

//设行高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return tableView.rowHeight;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:NSLocalizedString(@"kg %d channel", nil),[aryOnOff count]];
}

//修改头头的高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60;
}

////////////////////////
-(void) Part_PM_Cell_Click:(NSInteger)cellRow btnIndex:(int)index
{
    NSLog(@"Part_PM_Cell_Click cellRow=%ld index=%d",cellRow,index);
    switch(index)
    {
        case 0:
            [self sendCtrl:cellRow :0xA2]; //点击200MS;
            break;
        case 1:
            [self sendCtrl:cellRow :0x64]; //开
            break;
        case 2:
            [self sendCtrl:cellRow :0x00]; //关
            break;
    }
}

- (IBAction)btnAllOn_click:(id)sender
{
    int n=(int)[aryOnOff count];
    uchar * p=(uchar*)malloc(n);
    memset(p,0x64,n);
    [self sendCtrlALL:p :n];
}

- (IBAction)btnAllOff_click:(id)sender
{
    int n=(int)[aryOnOff count];
    uchar * p=(uchar*)malloc(n);
    memset(p,0,n);
    [self sendCtrlALL:p :n];
}

//////////////////////////////////////////////////////////////////////////
- (void)sendCtrlALL:(uchar*)all_status :(int)len
{
    if(self.ctrlKey)
    {
        if([aryOnOff count]>0)
        {
            uchar buf[255]={0};
            //密码
            memcpy(buf,[self.ctrlKey bytes],6);
            //
            buf[6]=0x01;
            memcpy(&buf[7],all_status,len);
            //
            int slen=0;
            char sbuf[255]={0};
            slen=hxNetCreateFrame("PM",7+len,buf, true, (uchar*)sbuf);
            //发送到网络
            if(0==self.netType)
            [msd sendMSUDP:sbuf datalen:slen ipv4:self.host port:self.port];
            else
            [yun iotSend:(char*)[self.devUUID UTF8String] buf:sbuf len:slen];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:NSLocalizedString(@"no device status", nil)
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                                  otherButtonTitles:nil];
            [alert show];
            alert=NULL;
        }
    }
}

- (void)sendCtrl:(NSInteger) channel :(unsigned char)value
{
    if(self.ctrlKey)
    {
        if([aryOnOff count]>0)
        {
            uchar buf[9]={0};
            //密码
            memcpy(buf,[self.ctrlKey bytes],6);
            //
            buf[6]=0x02;
            buf[7]=channel;
            buf[8]=value;
            //
            int slen=0;
            char sbuf[255]={0};
            slen=hxNetCreateFrame("PM",9,buf, true, (uchar*)sbuf);
            //
            //发送到网络
            if(0==self.netType)
                [msd sendMSUDP:sbuf datalen:slen ipv4:self.host port:self.port];
            else
                [yun iotSend:(char*)[self.devUUID UTF8String] buf:sbuf len:slen];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                            message:NSLocalizedString(@"no device status", nil)
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                                  otherButtonTitles:nil];
            [alert show];
            alert=NULL;
        }
    }
}

-(void) sendGetState
{
    if(self.ctrlKey)
    {
        uchar buf[10]={0};
        //密码
        memcpy(buf,[self.ctrlKey bytes],6);
        //
        buf[6]=0x00;
        
        int slen=0;
        char sbuf[255]={0};
        slen=hxNetCreateFrame("PM",7,buf, true, (uchar*)sbuf);
        //发送到网络
        if(0==self.netType)
        {
            [msd sendMSUDP:sbuf datalen:slen ipv4:self.host port:self.port];
        }
        else
        {
            [yun iotSend:(char*)[self.devUUID UTF8String] buf:sbuf len:slen];
        }
    }
}

// 提示框
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 199:
                if(buttonIndex==0)
                {
                    char ckey[6]={0};
                    UITextField *textField1 = [alertView textFieldAtIndex:0];
                    //插入记录
                    NSString*toDBpassword;
                    toDBpassword=[textField1.text isEqualToString:@""]?DEFAUT_LOCAL_PASSWD_NULL_VAL:textField1.text;
                    [DevPasswdMagr newPasswdByDevUUID:@"" :toDBpassword :self.devUUID];
                    //输出密码的key
                    [McuKeyGen genKey:ckey :textField1.text];
                    self.ctrlKey=[NSData dataWithBytes:ckey length:6];
                    //开始运行
                    inding.hidden=NO;
                    inding.alpha=1;
                    [self loadNet];
                }
                else
                {
                    [self.navigationController popViewControllerAnimated:YES];
                }
            break;
        case 888:
            //清空密码然后返回
            [DevPasswdMagr deletePasswdByDevUUID:self.devUUID];
            [self.navigationController popViewControllerAnimated:YES];
            break;
    }
}


@end
