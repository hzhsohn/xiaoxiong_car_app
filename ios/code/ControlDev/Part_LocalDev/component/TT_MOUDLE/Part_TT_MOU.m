//
//  CtrlMain_w1.m
//  discolor-led
//
//  Created by Han.zh on 15/2/17.
//  Copyright (c) 2015年 Han.zhihong. All rights reserved.
//

#import "Part_TT_MOU.h"
#import "Part_PM_Cell_Ctrl.h"
#import "DevKeyMagr.h"
#import "McuGlobalParameter.h"
#import  <libHxkNet/McuNet.h>
#import "HelpHeader.h"
#import "DefineHeader.h"

//网络控制
extern McuGlobalParameter *mcuParameter;


@interface Part_TT_MOU ()<HxNetCacheCtrlDelegate,MSDDelegate,McuYunDelegate>
{
    __weak IBOutlet UIActivityIndicatorView *inding;
    __weak IBOutlet UITextView *txtReback;
    __weak IBOutlet UITextField *txtSend;
    
    //MSD服务
    MSDService *msd;
    HxNetCacheCtrl *mcuCache;
    McuYun* yun;
    BOOL isYunConnectOK;
}

- (IBAction)btn1:(id)sender;
- (IBAction)txtOnExit:(id)sender;

@end

@implementation Part_TT_MOU


-(void)awakeFromNib
{
    [super awakeFromNib];
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
        [yun.delegateArray removeObject:self];
        [msd.delegateArray removeObject:self];;
        [mcuCache.delegateArray removeObject:self];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化公共参数
    [mcuParameter clearAllParameter];
    [mcuParameter setParameter:@"netType" :[NSNumber numberWithInt:self.netType]];
    [mcuParameter setParameter:@"host" :self.host];
    [mcuParameter setParameter:@"port" :[NSNumber numberWithInt:self.port]];
    [mcuParameter setParameter:@"devUUID" :self.devUUID];
    [mcuParameter setParameter:@"devName" :self.devName];
    [mcuParameter setParameter:@"ctrlKey" :self.ctrlKey];
    [mcuParameter setParameter:@"+msd" :msd];
    [mcuParameter setParameter:@"+cache" :mcuCache];
    [mcuParameter setParameter:@"+yun" :yun];
    
    
    //清空内容
    txtReback.text=@"";
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.navigationController setNavigationBarHidden:NO];
    
    if(0==self.netType)
    {
        //开始读取当前状态
        inding.hidden=YES;
        inding.alpha=0;
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
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

-(void)fuckActive:(NSNotification*)notification
{
    NSLog(@"fuckActive");
    
}

-(void)fuckBack:(NSNotification*)notification
{
    //返回到主界面,防止IP地址或者端口信息改变后不能控制
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

//-----------------------------------------
-(void) send_cb:(MSDPacket*) packet
{
    NSLog(@"send_cb=%d",packet.packetID);
}
-(void) recvfrom:(char*)buff :(int) len :(NSString*) ipv4 :(int) port
{
    NSLog(@"recvfrom=%dbytes",len);
    //[mcuCache recvCache:buff :len ipv4:ipv4 port:port];
    [self recvProc:(char*)buff :len];
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
    NSLog(@"连接DTRS系统成功 ,订阅=%@",self.devUUID);
    [yun iotSubscr:[self.devUUID UTF8String]];
}
//////////////////////////
//保活包
-(void) eventKeep:(time_t)rtt
{}
//通讯数据
-(void) eventRecvData:(NSString*) devUUID buf:(const char*) buf len:(int) len
{
    //[mcuCache recvCache:buf :len devUUID:devUUID];
    [self recvProc:(char*)buf :len];
}
//订阅数据回调成功
-(void) eventSubscrDev:(NSString*) devUUID
{
    if([devUUID isEqualToString:self.devUUID])
    {
        isYunConnectOK=TRUE;
        inding.hidden=YES;
        inding.alpha=0;
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
}
-(void)HxNetDataRecv:(TzhNetFrame_Cmd*)data ipv4:(NSString*)ipv4 port:(int)port
{
}

//------------------------------
- (void) log:(NSString *)text
{
    txtReback.editable = YES;
    txtReback.text= [txtReback.text stringByAppendingString:text];
    txtReback.text= [txtReback.text stringByAppendingString:@"\n\n"];
    NSRange range={0};
    range.location= [txtReback.text length];
    range.length=[text length];
    [UIView setAnimationsEnabled:YES];
    [txtReback scrollRangeToVisible:range];
    txtReback.editable = NO;
}
-(void)recvProc:(char*)data :(int)len
{
    char* buf2=malloc(len+1);
    memset(buf2,0,len+1);
    memcpy(buf2,data,len);
    [self performSelectorOnMainThread:@selector(log:)
                           withObject:[NSString stringWithUTF8String:buf2]
                        waitUntilDone:YES];
    free(buf2);
    buf2=NULL;
}

-(void)sendString:(NSString*)str
{
    //发送到网络
    if(0==self.netType)
        [msd sendMSUDP:(char*)[str UTF8String] datalen:(int)strlen([str UTF8String]) ipv4:self.host port:self.port];
    else
        [yun iotSend:(char*)[self.devUUID UTF8String] buf:(char*)[str UTF8String] len:(int)strlen([str UTF8String])];
}


- (IBAction)btn1:(id)sender {
    [self sendString:txtSend.text];
}

- (IBAction)txtOnExit:(id)sender {
    UITextView*t=(UITextView*)sender;
    [t resignFirstResponder];
}
@end
