//
//  Part_HXLED_Sub1.m
//  home
//
//  Created by Han.zh on 2017/3/21.
//  Copyright © 2017年 Han.zhihong. All rights reserved.
//

#import "Part_Pub_Sub3.h"
#import "DevKeyMagr.h"
#import  <libHxkNet/McuNet.h>
#import "McuGlobalParameter.h"
#import "HelpHeader.h"

//网络控制
extern McuGlobalParameter *mcuParameter;

@interface Part_Pub_Sub3 ()<HxNetCacheCtrlDelegate>
{
    __weak IBOutlet UITextField *txt1;    //是否密码错误
    __weak IBOutlet UIButton *btn1;
    BOOL isShowPasswdErr;
    NSTimer *_timer;
    //
    __weak IBOutlet UIActivityIndicatorView *inding;
    //
    HxNetCacheCtrl *mcuCache;
    MSDService* msd;
    McuYun* yun;
    //////////
    NSInteger netType;
    NSString*host;
    NSString*devUUID;
    NSNumber*port;
    NSData*da;
}
- (IBAction)didOnExit:(id)sender;
- (IBAction)textFieldDidChange:(UITextField *)textField;

-(void)getCtrlAreaID;
-(void)setCtrlAreaID:(NSString*)str;

- (IBAction)btnOK_click:(id)sender;

@end

@implementation Part_Pub_Sub3

-(void)awakeFromNib
{
    [super awakeFromNib];
    //初始化缓存服务
    netType=[[mcuParameter getParameter:@"netType"] integerValue];
    devUUID=[mcuParameter getParameter:@"devUUID"];
    host=[mcuParameter getParameter:@"host"];
    port=[mcuParameter getParameter:@"port"];
    da=[mcuParameter getParameter:@"ctrlKey"];
    //
    msd=[mcuParameter getParameter:@"+msd"];
    yun=[mcuParameter getParameter:@"+yun"];
    //
    mcuCache=[mcuParameter getParameter:@"+cache"];
    [mcuCache.delegateArray addObject:self];
}

-(void)dealloc
{
    NSLog(@"Part_PM_Sub3 dealloc");
}

//--------------------------------------------------------
//检测是否返回
- (void)didMoveToParentViewController:(UIViewController*)parent{
    [super didMoveToParentViewController:parent];
    if(!parent){
        //NSLog(@"页面pop成功了");
        [mcuCache.delegateArray removeObject:self];
    }
}

//左边插入文字
-(void)leftText:(UITextField*)target :(NSString*)title :(int)x
{
    //左边插入LABEL文字
    UILabel *lb1;
    lb1=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, x, 24)];
    [lb1 setText:title];
    [lb1 setTextAlignment:NSTextAlignmentCenter];
    target.leftView = lb1;
    target.leftViewMode = UITextFieldViewModeAlways;
    lb1=nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self leftText:txt1 :NSLocalizedString(@"Ctrl Area ID:", nil) :150];
    
    [self getCtrlAreaID];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didOnExit:(id)sender {
    UITextField*txt=(UITextField*)sender;
    [txt resignFirstResponder];
}
- (IBAction)textFieldDidChange:(UITextField *)textField
{
    if (textField.text.length > 16) {
        textField.text = [textField.text substringToIndex:16];
    }
}

-(void)getCtrlAreaID
{
    //界面状态
    inding.alpha=1;
    inding.hidden=0;
    txt1.enabled=FALSE;
    
    uchar buf[32]={0};
    memcpy(buf,[da bytes],6);
    
    char sbuf[64]={0};
    int len=hxNetCreateFrame(">r_caid", 6, buf, true, (uchar*)sbuf);
    //
    if(0==netType)
        [msd sendMSUDP:sbuf datalen:len ipv4:host port:[port intValue]];
    else
        [yun iotSend:[devUUID UTF8String] buf:sbuf len:len];
}

-(void)setCtrlAreaID:(NSString*)str
{
    //界面状态
    inding.alpha=1;
    inding.hidden=0;
    txt1.enabled=FALSE;
    
    char buf[256]={0};
    char*strss=(char*)[str UTF8String];
    int n=(int)strlen(strss)+1;
    
    memcpy(buf,[da bytes],6);
    memcpy(&buf[6],strss,n);
    
    char sbuf[256]={0};
    int len=hxNetCreateFrame(">w_caid", n+6, (uchar*)buf, true, (uchar*)sbuf);
    //
    if(0==netType)
        [msd sendMSUDP:sbuf datalen:len ipv4:host port:[port intValue]];
    else
        [yun iotSend:[devUUID UTF8String] buf:sbuf len:len];
}

- (IBAction)btnOK_click:(id)sender {
    const char*s=[txt1.text UTF8String];
    if(strlen(s)>20)
    {
        alert_ok(self, 0, @"alert", @"devname too long");
        return;
    }
    
    [self setCtrlAreaID:txt1.text];
}
//-----------------------------------------
-(void)HxNetDataRecv:(TzhNetFrame_Cmd*)data devUUID:(NSString*)uuid
{
    NSLog(@"HxNetDataRecv YUN=%dbytes",data->frame_len);
    [self recvProc:data];
}
-(void)HxNetDataRecv:(TzhNetFrame_Cmd*)data ipv4:(NSString*)ipv4 port:(int)port
{
    NSLog(@"data->flag=%s",data->flag);
    [self recvProc:data];
}
-(void)recvProc:(TzhNetFrame_Cmd*)data
{
    //数据处理
    if(0==strcmp(data->flag,"<r_caid"))
    {
        uchar* param=&data->parameter[0];
        [txt1 setText:[NSString stringWithUTF8String:(char*)param]];
        inding.alpha=0;
        inding.hidden=1;
        txt1.enabled=TRUE;
    }
    else if(0==strcmp(data->flag,"<w_caid"))
    {
        inding.alpha=0;
        inding.hidden=1;
        txt1.enabled=TRUE;
        
        uchar* param=&data->parameter[0];
        NSString*retstr;
        if(param[0])
        {
            retstr=NSLocalizedString(@"set CAID ok.", nil);
        }
        else{
            retstr=NSLocalizedString(@"set CAID fail.", nil);
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:retstr
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                              otherButtonTitles:nil];
        alert.tag=555;
        [alert show];
        alert=NULL;
        isShowPasswdErr=TRUE;
    }
}

// 提示框
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case 555:
            [self.navigationController popToRootViewControllerAnimated:YES];
            break;
        case 777:
            [self.navigationController popToRootViewControllerAnimated:YES];
            break;
    }
}

@end
