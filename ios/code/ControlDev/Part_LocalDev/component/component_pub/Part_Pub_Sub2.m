//
//  Part_HXLED_Sub1.m
//  home
//
//  Created by Han.zh on 2017/3/21.
//  Copyright © 2017年 Han.zhihong. All rights reserved.
//

#import "Part_Pub_Sub2.h"
#import "DevPasswdMagr.h"
#import  <libHxkNet/McuNet.h>
#import "McuGlobalParameter.h"
#import "ComponentBase.h"

//网络控制
extern McuGlobalParameter *mcuParameter;

@interface Part_Pub_Sub2 ()<HxNetCacheCtrlDelegate>
{
    __weak IBOutlet UITextField *txtPasswd1;
    __weak IBOutlet UITextField *txtPasswd2;
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
- (IBAction)btnOK_click:(id)sender;

-(void)savePasswd;

@end

@implementation Part_Pub_Sub2

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
    NSLog(@"Part_PM_Sub2 dealloc");
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
    [lb1 setTextAlignment:NSTextAlignmentRight];
    target.leftView = lb1;
    target.leftViewMode = UITextFieldViewModeAlways;
    lb1=nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self leftText:txtPasswd1 :NSLocalizedString(@"New Password:", nil) :120];
    [self leftText:txtPasswd2 :NSLocalizedString(@"Confirm Password:", nil) :120];
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
    if (textField.text.length > 4) {
        textField.text = [textField.text substringToIndex:4];
    }
}

-(void)savePasswd
{
    char buf[256]={0};
    char keyv[6]={0};
    [McuKeyGen genKey:keyv :txtPasswd1.text];
    
    memcpy(buf,[da bytes],6);
    memcpy(&buf[6],keyv, 6);
    
    char sbuf[256]={0};
    int len=hxNetCreateFrame(">passwd", 12, (uchar*)buf, true, (uchar*)sbuf);
    
    //
    if(0==netType)
        [msd sendMSUDP:sbuf datalen:len ipv4:host port:[port intValue]];
    else
        [yun iotSend:[devUUID UTF8String] buf:sbuf len:len];
}

- (IBAction)btnOK_click:(id)sender
{
    
    if ([txtPasswd1.text length]>24) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:NSLocalizedString(@"No more than 24 characters!!", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                              otherButtonTitles:nil];
        [alert show];
        alert=NULL;
        return;
    }
    
    if (![txtPasswd1.text isEqualToString:txtPasswd2.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:NSLocalizedString(@"not same password!!", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                              otherButtonTitles:nil];
        [alert show];
        alert=NULL;
        return;
    }
    
    if ([txtPasswd1.text length]==0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:NSLocalizedString(@"is save empty password?", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"cancel", nil)
                                              otherButtonTitles:NSLocalizedString(@"ok", nil),nil];
        alert.tag=666;
        [alert show];
        alert=NULL;
        return;
    }
    
    //发送修改密码
    [self savePasswd];
    inding.alpha=1;
    inding.hidden=0;
}

//-----------------------------------------
-(void)HxNetDataRecv:(TzhNetFrame_Cmd*)data devUUID:(NSString*)uuid
{
    NSLog(@"HxNetDataRecv YUN=%dbytes",data->frame_len);
    [self recvProc:data];
}
-(void)HxNetDataRecv:(TzhNetFrame_Cmd*)data ipv4:(NSString*)ipv4 port:(int)port
{
    [self recvProc:data];
}
-(void)recvProc:(TzhNetFrame_Cmd*)data
{
    //数据处理
    if(0==strcmp(data->flag,"<passwd"))
    {
        NSString*duid=[mcuParameter getParameter:@"devUUID"];
        
        //设置密码成功
        NSString*toDBpassword;
        toDBpassword=[txtPasswd1.text isEqualToString:@""]?DEFAUT_LOCAL_PASSWD_NULL_VAL:txtPasswd1.text;
        //修改数据库中的密码
        DevPasswdMagr* devpwd=[[DevPasswdMagr alloc] init];
        [devpwd updatePassword:@"" :toDBpassword devUUID:duid];
        devpwd=nil;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"password change success",nil)
                                                        message:NSLocalizedString(@"permission reset,please login again!!", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                              otherButtonTitles:nil];
        alert.tag=777;
        [alert show];
        alert=NULL;
        //
        inding.alpha=0;
        inding.hidden=1;
    }
    else if(0==strcmp(data->flag,"<keyerr"))
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:NSLocalizedString(@"permission error", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                              otherButtonTitles:nil];
        alert.tag=777;
        [alert show];
        alert=NULL;
        //
        inding.alpha=0;
        inding.hidden=1;
    }
}

// 提示框
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case 666:
            if(buttonIndex==1)
            {
                //发送修改密码
                [self savePasswd];
                inding.alpha=1;
                inding.hidden=0;
            }
            break;
        case 777:
            [self.navigationController popToRootViewControllerAnimated:YES];
            break;
    }
}

@end
