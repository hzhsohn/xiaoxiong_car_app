//
//  AddSence_w1.m
//  discolor-led
//
//  Created by Han.zh on 15/2/17.
//  Copyright (c) 2015年 Han.zhihong. All rights reserved.
//

#import "Part_LED_RGBW.h"
#import "KZColorPicker.h"
#import "UIImageExt.h"
#import <libHxkNet/McuNet.h>
#import "McuGlobalParameter.h"
#import "HelpHeader.h"
#import "DevPasswdMagr.h"
#import "DefineHeader.h"

//网络控制
extern McuGlobalParameter *mcuParameter;

#define CTRL_TAG_LED    "LED"

@interface Part_LED_RGBW ()<HxNetCacheCtrlDelegate,UIActionSheetDelegate,MSDDelegate,McuYunDelegate>
{
    __weak IBOutlet UILabel *lbRGB;
    __weak IBOutlet UIButton *btn1;
    __weak IBOutlet UIButton *btnSelectSence;
    __weak IBOutlet UIActivityIndicatorView *inding;
    __weak IBOutlet UIImageView *imgLightColor;
    __weak IBOutlet UIImageView *imgLightColorBG;
    
    //
    NSTimer *_timer;
    KZColorPicker *picker;
    
    BOOL isFristSyncDone;//是否第一次同步
    //当前值
    uchar curOnOff; //当前开关状态
    uchar curSenceID; //当前场景
    uchar curR,curG,curB,curW; //当前颜色
    
    //
    McuYun* yun;
    BOOL isYunConnectOK;
    
    //MSD服务
    MSDService *msd;
    HxNetCacheCtrl *mcuCache;
    //
    char sendColor[4];
    char sendColorOld[4];
}

-(void)setLightColor:(unsigned char)R :(unsigned char)G :(unsigned char)B; //小灯泡图标

- (IBAction)btnClick:(id)sender;

-(void) handleTimer: (NSTimer *) timer;
-(void)setTimer;
-(void)disTimer;

- (IBAction)selectSenceID:(id)sender;

////////////
-(void)sendChangeColor:(uchar)r :(uchar)g :(uchar)b :(uchar)w;
-(void)sendChangeMethod:(uchar)m;
-(void)sendOnOff:(BOOL)b;
-(void)sendGetState;

@end

@implementation Part_LED_RGBW

-(void)awakeFromNib
{
    [super awakeFromNib];
    isFristSyncDone=FALSE;
    
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
    //[picker release];
    picker=nil;
    
    [msd stopService];
    msd.delegateArray=nil;
    msd=nil;
    [mcuCache stopService];
    mcuCache.delegateArray=nil;
    mcuCache=nil;

    [[NSNotificationCenter defaultCenter] removeObserver:self];
   
}


//--------------------------------------------------------
//检测是否返回
- (void)didMoveToParentViewController:(UIViewController*)parent{
    [super didMoveToParentViewController:parent];
    if(!parent){
        //NSLog(@"页面pop成功了");
        [self disTimer];
        [msd.delegateArray removeObject:self];
        [mcuCache.delegateArray removeObject:self];
    }
}

-(void)setLightColor:(unsigned char)R :(unsigned char)G :(unsigned char)B
{
    UIColor* color=[UIColor colorWithRed:R/255.0f green:G/255.0f blue:B/255.0f alpha:1];
    UIGraphicsBeginImageContextWithOptions(imgLightColor.frame.size, NO, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, imgLightColor.frame.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, imgLightColor.frame.size.width,imgLightColor.frame.size.height);
    [color setFill];
    CGContextFillRect(context, rect);
    UIImage*newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //设置那个圆角的有多圆
    newImage=[newImage roundedRectWith:15 cornerMask:UIImageRoundedCornerTopLeft|
              UIImageRoundedCornerTopRight|
              UIImageRoundedCornerBottomRight|
              UIImageRoundedCornerBottomLeft];
    [imgLightColor setImage:newImage];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.navigationController.navigationBar.translucent = NO;
    //标题
    self.title=self.devName;
    NSLog(@"self.host=%@ self.port=%d",self.host,self.port);
    
    //
    picker = [[KZColorPicker alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    picker.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    //设置初始化颜色
    [picker setSelectedColorNoEvent:[UIColor colorWithRed:0 green:0 blue:0 alpha:0]];

    [picker addTarget:self action:@selector(pickerChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:picker];

    [self.view bringSubviewToFront:btn1];
    [self.view bringSubviewToFront:lbRGB];
    [self.view bringSubviewToFront:btnSelectSence];
    [lbRGB setText:[NSString stringWithFormat:@"R: %d\nG: %d\nB: %d",0,0,0]];
    [self.view bringSubviewToFront:imgLightColor];
    [self.view bringSubviewToFront:imgLightColorBG];
    [self setLightColor:0 :0 :0];
    
    //初始化
    [inding setBackgroundColor:[UIColor grayColor]];
    inding.alpha=0.8f;
    inding.layer.cornerRadius = 10;//设置那个圆角的有多圆
    inding.layer.borderWidth = 0;//设置边框的宽度
    [inding setHidden:NO];
    [self.view bringSubviewToFront:inding];
    
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
    //设置标题和字体大小
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [UIColor whiteColor],NSForegroundColorAttributeName,
                          [UIFont systemFontOfSize:17.0],NSFontAttributeName,
                          nil];
    self.navigationController.navigationBar.titleTextAttributes = dict;
    self.title=self.devName;

    //启用定时器
    [self setTimer];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    //关闭定时器
    [self disTimer];
}


- (IBAction)rightItemClick:(id)sender {
    UIStoryboard *frm=NULL;
    frm = [UIStoryboard storyboardWithName:@"ComponentPub" bundle:nil];
    UIViewController*tt = [frm instantiateInitialViewController];
    [self.navigationController pushViewController:tt animated:YES];
}

-(void) handleTimer: (NSTimer *) timer
{
    
        //定时搜索硬件状态
        static int searhDev=0;
        if(0==searhDev || NO==isFristSyncDone)
        {
             if(0==self.netType || TRUE==isYunConnectOK)
             {
                 [self sendGetState];
             }
        }
        searhDev++;
        searhDev%=50;
    
    //
        if(memcmp(sendColorOld,sendColor,4))
        {
            [self sendChangeColor:sendColor[0] :sendColor[1] :sendColor[2] :sendColor[3]];
            memcpy(sendColorOld,sendColor,4);
        }
}

-(void)setTimer
{
    if (nil==_timer) {
        [self handleTimer:_timer];
        _timer = [NSTimer scheduledTimerWithTimeInterval: 0.1//秒
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

- (IBAction)selectSenceID:(id)sender
{
    // 创建时仅指定取消按钮
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"灯光场景"
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:nil];
    // 逐个添加按钮（比如可以是数组循环）
    [sheet addButtonWithTitle:@"呼吸灯"];
    [sheet addButtonWithTitle:@"跳格灯"];
    [sheet addButtonWithTitle:@"渐变灯"];
    //[sheet showInView:self.view];
    [sheet showFromRect:CGRectMake(0, 0,500,500) inView:self.view animated:YES];
    sheet=nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    NSLog(@"segue.identifier=%@",segue.identifier);
}

- (void) pickerChanged:(KZColorPicker *)cp
{
    //self.selectedColor = cp.selectedColor;
    CGFloat R, G, B,W;
    CGFloat _R, _G, _B ,_W;
    
    UIColor *uiColor = cp.selectedColor;
    CGColorRef color = [uiColor CGColor];
    size_t numComponents = CGColorGetNumberOfComponents(color);
    
    if (numComponents == 4)
    {
        const CGFloat *components = CGColorGetComponents(color);
        _R = components[0];
        _G = components[1];
        _B = components[2];
        _W = components[3];
        
        R=_R*255;
        G=_G*255;
        B=_B*255;
        W=_W*255;
        
        if(R==0 && G==0 && B==0&& W==0)
        {
            _R=1.0f/255.0f;
            _G=1.0f/255.0f;
            _B=1.0f/255.0f;
            _W=1.0f/255.0f;
            picker.selectedColor = [UIColor colorWithRed:_R  green:_G blue:_B alpha:_W];
            R=_R*255;
            G=_G*255;
            B=_B*255;
            W=_W*255;
        }
        if(isFristSyncDone)//防止初始化时将值发到硬件
        {
            sendColor[0]=R;
            sendColor[1]=G;
            sendColor[2]=B;
            sendColor[3]=W;
        }
    }
}

- (IBAction)btnClick:(id)sender
{
    [self sendOnOff:!curOnOff];
}

//设行高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

//---------------
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"buttonIndex=%ld",(long)buttonIndex);
    switch (buttonIndex) {
        case 1:
            //呼吸灯
            [self sendChangeMethod:1];
            break;
        case 2:
            //跳格
            [self sendChangeMethod:2];
            break;
        case 3:
            //渐变
            [self sendChangeMethod:3];
            break;
    }
}

//////////////////////////////////////////////////////////////////////////////
-(void)sendChangeColor:(uchar)r :(uchar)g :(uchar)b :(uchar)w
{
    if(self.ctrlKey)
    {
        uchar buf[20]={0};
        //密码
        memcpy(buf,[self.ctrlKey bytes],6);
        //
        buf[6]=0x01;
        buf[7]=r;
        buf[8]=g;
        buf[9]=b;
        buf[10]=w;

        int slen=0;
        char sbuf[255]={0};
        slen=hxNetCreateFrame(CTRL_TAG_LED,11,buf, true, (uchar*)sbuf);
        
        //发送到网络
        if(0==self.netType)
            [msd sendMSUDP:sbuf datalen:slen ipv4:self.host port:self.port];
        else
            [yun iotSend:(char*)[self.devUUID UTF8String] buf:sbuf len:slen];
    }
}
-(void)sendChangeMethod:(uchar)m
{
    if(self.ctrlKey)
    {
    uchar buf[20]={0};
    //密码
    memcpy(buf,[self.ctrlKey bytes],6);
    //
    buf[6]=0x02;
    buf[7]=m;
    
    int slen=0;
    char sbuf[255]={0};
    slen=hxNetCreateFrame(CTRL_TAG_LED,8,buf, true, (uchar*)sbuf);
        //发送到网络
        if(0==self.netType)
            [msd sendMSUDP:sbuf datalen:slen ipv4:self.host port:self.port];
        else
            [yun iotSend:(char*)[self.devUUID UTF8String] buf:sbuf len:slen];
    }
}
-(void)sendOnOff:(BOOL)b
{
    if(self.ctrlKey)
    {
        int slen=0;
        char sbuf[255]={0};
        if(b)
        {
            slen=hxNetCreateFrame(">1",6,[self.ctrlKey bytes], true, (uchar*)sbuf);
        }
        else{
            slen=hxNetCreateFrame(">0",6,[self.ctrlKey bytes], true, (uchar*)sbuf);
        }
    
        //发送到网络
        if(0==self.netType)
            [msd sendMSUDP:sbuf datalen:slen ipv4:self.host port:self.port];
        else
            [yun iotSend:(char*)[self.devUUID UTF8String] buf:sbuf len:slen];
    }
}

-(void)sendGetState
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
        slen=hxNetCreateFrame(CTRL_TAG_LED,7,buf, true, (uchar*)sbuf);
        //发送到网络
        if(0==self.netType)
            [msd sendMSUDP:sbuf datalen:slen ipv4:self.host port:self.port];
        else
            [yun iotSend:(char*)[self.devUUID UTF8String] buf:sbuf len:slen];
        
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
    if(0==strcmp(data->flag,"<0"))
    {
        btn1.selected=curOnOff=false;
    }
    else if(0==strcmp(data->flag,"<1"))
    {
        btn1.selected=curOnOff=true;
    }
    else if(0==strcmp(data->flag,"<keyerr"))
    {
        alert_ok(self,888,@"alert",@"ctrl key fail.");
        [inding setHidden:YES];
        [self disTimer];
    }
    else if(0==strcmp(data->flag,CTRL_TAG_LED))
    {
        //控制命令
        uchar cmd=data->parameter[0];
        [self setLightColor:0 :0 :0];
        
        //控制参数
        uchar* parm=&data->parameter[1];
        
        switch(cmd)
        {
            case 0x10 ://当前颜色
            {
                curOnOff=parm[0];
                curSenceID=parm[1];
                curR=parm[2];
                curG=parm[3];
                curB=parm[4];
                curW=parm[5];
                NSLog(@"Part_HXLED_Main=%d,%d -- %d,%d,%d,%d",curOnOff,curSenceID,curR,curG,curB,curW);
                
                //调整颜色
                if(curOnOff)
                {
                    if(curSenceID)
                    {
                        [lbRGB setText:[NSString stringWithFormat:NSLocalizedString(@"\n\nSENCE: %d", nil), curSenceID]];
                    }
                    else{
                        [lbRGB setText:[NSString stringWithFormat:@"R: %d\nG: %d\nB: %d\nW: %d",curR,curG,curB,curW]];
                    }
                    
                    //调整界面
                    [self setLightColor:curR :curG :curB];
                }
                else
                {
                    [lbRGB setText:[NSString stringWithFormat:@"----"]];
                    [self setLightColor:0 :0 :0];
                }
                
                btn1.selected=curOnOff;
                if(FALSE==isFristSyncDone)
                {
                    //隐藏
                    [UIView beginAnimations:nil context:nil];
                    [UIView setAnimationDuration:0.5];
                    
                    CGFloat _R, _G, _B,_W;
                    _R=curR/255.0f;
                    _G=curG/255.0f;
                    _B=curB/255.0f;
                    _W=curW/255.0f;
                    [picker setSelectedColorNoEvent:[UIColor colorWithRed:_R  green:_G blue:_B alpha:_W]];
                    
                    inding.alpha=0;
                    [inding setHidden:YES];
                    isFristSyncDone=TRUE;
                    self.navigationItem.rightBarButtonItem.enabled=YES;
                    [UIView setAnimationTransition:0 forView:inding cache:YES];
                    [UIView commitAnimations];
                }
            }
                break;
            default:
            {
                NSLog(@"硬件返回未知数据");
            }
                break;
        }

    }
}
@end
