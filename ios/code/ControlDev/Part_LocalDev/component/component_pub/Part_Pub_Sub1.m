//
//  Part_HXLED_Sub1.m
//  home
//
//  Created by Han.zh on 2017/3/21.
//  Copyright © 2017年 Han.zhihong. All rights reserved.
//

#import "Part_Pub_Sub1.h"
#import "DevKeyMagr.h"
#import "McuGlobalParameter.h"
#import <libHxkNet/McuNet.h>

//网络控制
extern McuGlobalParameter *mcuParameter;

@interface Part_Pub_Sub1()<HxNetCacheCtrlDelegate>
{
    __weak IBOutlet UIButton *btn1;
    __weak IBOutlet UITextField *txt1;    //是否密码错误
    BOOL isShowPasswdErr;
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

-(void)setDevname:(NSString*)str;

- (IBAction)btnOK_click:(id)sender;
@end

@implementation Part_Pub_Sub1

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
    NSLog(@"Part_PM_Sub1 dealloc");
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
    [self leftText:txt1 :NSLocalizedString(@"Devname:", nil) :150];
    txt1.text=[mcuParameter getParameter:@"devName"];
    
    //-----------------------
    inding.alpha=0;
    inding.hidden=1;
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
    if (textField.text.length > 20) {
        textField.text = [textField.text substringToIndex:20];
    }
}

- (IBAction)btnOK_click:(id)sender {
    [self setDevname:txt1.text];
}

-(void)setDevname:(NSString*)str
{
    //界面状态
    inding.alpha=1;
    inding.hidden=0;
    txt1.enabled=FALSE;
    
    char buf[512]={0};
    char*strss=(char*)[str UTF8String];
    int n=(int)strlen(strss)+1;
    
    memcpy(buf,[da bytes],6);
    memcpy(&buf[6],strss,n);
    
    char sendbuf[255]={0};
    int slen=hxNetCreateFrame(">w_name", n+6, (const uchar*)buf, true, (uchar*)sendbuf);
    
    //
    if(0==netType)
        [msd sendMSUDP:(char*)sendbuf datalen:slen ipv4:host port:[port intValue]];
    else
        [yun iotSend:[devUUID UTF8String] buf:sendbuf len:slen];
}

//-----------------------------------------
-(void)HxNetDataRecv:(TzhNetFrame_Cmd*)data devUUID:(NSString*)uuid
{
    NSLog(@"HxNetDataRecv YUN=%dbytes",data->frame_len);
    [self recvData:data->flag :&data->parameter[0]];
}
-(void)HxNetDataRecv:(TzhNetFrame_Cmd*)data ipv4:(NSString*)ipv4 port:(int)port
{
    NSLog(@"HxNetDataRecv LAN=%dbytes",data->frame_len);
    NSLog(@"data->flag=%s",data->flag);
    [self recvData:data->flag :&data->parameter[0]];
}
-(void)recvData:(const char*)flag :(uchar*) param
{
    //数据处理
    if(0==strcmp(flag,"<w_name"))
    {
        NSString*duid=[mcuParameter getParameter:@"devUUID"];
        
        //设置密码成功
        //修改数据库中的密码
        DevKeyMagr* devmgr=[[DevKeyMagr alloc] init];
        [devmgr updateDevname:txt1.text devUUID:duid];
        devmgr=nil;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        
        inding.alpha=0;
        inding.hidden=1;
        txt1.enabled=TRUE;
        
        [UIView setAnimationTransition:0 forView:inding cache:YES];
        [UIView commitAnimations];
        
        NSString*retstr;
        if(param[0])
        {
            retstr=NSLocalizedString(@"set devname ok.", nil);
        }
        else{
            retstr=NSLocalizedString(@"set devname fail.", nil);
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:retstr
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                              otherButtonTitles:nil];
        alert.tag=777;
        [alert show];
        alert=NULL;
        isShowPasswdErr=TRUE;
    }
}

// 提示框
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case 555:
            [self.navigationController popViewControllerAnimated:YES];
            break;
        case 777:
            [self.navigationController popToRootViewControllerAnimated:YES];
            break;
    }
}

@end
