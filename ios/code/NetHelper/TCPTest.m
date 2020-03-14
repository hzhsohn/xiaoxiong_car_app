//
//  TCPTest.m
//  hx-home
//
//  Created by Han.zh on 16/4/6.
//  Copyright © 2016年 Han.zhihong. All rights reserved.
//

#import "TCPTest.h"
#import "TestCommand.h"
#import "TcpManage.h"

@interface TCPTest ()<TestCommandDelegate,TcpManageDelegate>
{
    __weak IBOutlet UITextView *txtReback;
    __weak IBOutlet UITextView *txtCommand;
    __weak IBOutlet UITextField *txtIP;
    __weak IBOutlet UITextField *txtPort;
    __weak IBOutlet UIButton *btnStartTCP;
    __weak IBOutlet UIView *viInput;
    
    //IP地址和端口的位置
    CGRect _inputViewFrame;
    
    //TCP处理
    TcpManage *_tcp;
    
    //时间线
    NSTimer* _timer;
}
- (void) log:(NSString *)text;
-(int) trStrToCmd:(const char*)szTmp :(unsigned char*)pcmd :(int)pcmd_size;
- (IBAction)btnSend:(id)sender;
- (IBAction)btnStartTcp_click:(id)sender;
-(void)leftText:(UITextField*)target :(NSString*)title :(int)x;
-(void) handleTimer: (NSTimer *) timer;
- (IBAction)endExit:(id)sender;
@end

@implementation TCPTest

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
    // Do any additional setup after loading the view.
    
    txtReback.text=@"";
    txtIP.text=self.def_ip;
    txtPort.text=[NSString stringWithFormat:@"%d",self.def_port];
    [self leftText:txtIP :@"IP地址: " :65];
    [self leftText:txtPort :@"端口: " :45];
    
    _tcp=[[TcpManage alloc] init];
    _tcp.delegate=self;
    
    _timer = [NSTimer scheduledTimerWithTimeInterval: 0.001//秒
                                              target: self
                                            selector: @selector(handleTimer:)
                                            userInfo: nil
                                             repeats: YES];
    
    //注册事件
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardWillShow:)
     name:UIKeyboardWillShowNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(keyboardWillHide:)
     name:UIKeyboardWillHideNotification
     object:nil];
}

-(void)dealloc
{
    _tcp=nil;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _inputViewFrame=viInput.frame;
}

-(void)closeService
{
    
    [_timer invalidate];
    _timer = nil;
}

- (void) keyboardWillShow:(NSNotification *)note {
    NSLog(@"keyboard show");
    
    //上移输入框
    NSDictionary* info = [note userInfo];
    NSValue* aValue = [info objectForKey:@"UIKeyboardBoundsUserInfoKey"];
    CGSize keyboardRect = [aValue CGRectValue].size;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    
    CGRect rk;
    rk=self.view.frame;
    rk.origin.y=-keyboardRect.height;
    [self.view setFrame:rk];
    
    [UIView setAnimationTransition:0 forView:self.view cache:YES];
    [UIView commitAnimations];
    
}
- (void) keyboardWillHide:(NSNotification *)note
{
    NSLog(@"keyboard hide");
    //恢复输入框
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    
    CGRect rk;
    rk=self.view.frame;
    rk.origin.y=0;
    [self.view setFrame:rk];
    
    [UIView setAnimationTransition:0 forView:self.view cache:YES];
    [UIView commitAnimations];
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
 
    if ([segue.identifier isEqualToString:@"segEditCommand"])
    {
        TestCommand* frm=(TestCommand*)segue.destinationViewController;
        frm.sOldCommand=txtCommand.text;
        frm.delegate=self;
    }
}

//-------------------------------------
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

-(void)clearMessage
{
    txtReback.text=@"";
}

-(void)TestCommandCallBack:(NSString*)cmd
{
    txtCommand.text=cmd;
}


//---------------------------------------------
-(int) trStrToCmd:(const char*)szTmp :(unsigned char*)pcmd :(int)pcmd_size
{
    int ret_cmd_len;
    char *split;
    char *szbuf;
    int nbufLen;
    char *psz;
    int nHex;
    
    nbufLen=(int)strlen(szTmp)+1;
    szbuf=(char *)malloc(nbufLen);
    memset(szbuf,0,nbufLen);
    memset(pcmd,0,pcmd_size);
    
    strcpy(szbuf,szTmp);
    psz=strtok_r(szbuf," ",&split);
    ret_cmd_len=0;
    do
    {
        nHex=0;
        sscanf(psz,"%x",&nHex);
        
        if(nHex>255)
        {
            memset(pcmd,0,pcmd_size);
            free(szbuf);
            szbuf=NULL;
            return 0;
        }
        pcmd[ret_cmd_len++]=(unsigned char)nHex;
    }while((psz=strtok_r(NULL," ",&split)));
    
    free(szbuf);
    szbuf=NULL;
    return ret_cmd_len;
}


- (IBAction)btnSend:(id)sender
{
    if (!btnStartTCP.selected)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"TCP服务未启用..."
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        alert=nil;
        return;
    }
    
    if ([txtCommand.text isEqualToString:@""])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"指令不能为空"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        alert=nil;
        return;
    }
    
    //发送
    unsigned char sendbuf[2048]={0};
    int sendlen=0;
    sendlen=[self trStrToCmd:[txtCommand.text UTF8String] :sendbuf :sizeof(sendbuf)];
    if(sendlen>0)
    {
        //发送
        [_tcp send:(char*)sendbuf :sendlen];
        //日志
        NSMutableString * str=[[NSMutableString alloc] init];
        [str appendFormat:@"->%d字节=",sendlen];
        for (int i=0; i<sendlen; i++) {
            [str appendFormat:@"%02X ",sendbuf[i]];
        }
        [self performSelectorOnMainThread:@selector(log:) withObject:str waitUntilDone:YES];
        str=nil;
    }
    else
    {
        [self performSelectorOnMainThread:@selector(log:) withObject:@"发送内容转换失败" waitUntilDone:YES];
    }
}

- (IBAction)btnStartTcp_click:(id)sender
{
    if ([txtIP.text isEqualToString:@""])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"IP地址不能为空"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
        alert=nil;
        return;
    }
    
    btnStartTCP.selected=!btnStartTCP.selected;
    if (btnStartTCP.selected) {
        [txtIP setEnabled:NO];
        [txtPort setEnabled:NO];
        [_tcp connect_start:txtIP.text :[txtPort.text intValue]];
        [self performSelectorOnMainThread:@selector(log:) withObject:@"打开tcp服务..." waitUntilDone:YES];
    }
    else{
        [txtIP setEnabled:YES];
        [txtPort setEnabled:YES];
        [_tcp disconnect_not_reconnect];
        [self performSelectorOnMainThread:@selector(log:) withObject:@"关闭tcp服务.!!" waitUntilDone:YES];
    }
}

//------------------------------------------------
-(void) handleTimer: (NSTimer *) timer
{
    //在这里进行处理
    [_tcp thread];
    
}

- (IBAction)endExit:(id)sender
{
    UITextField*txt=(UITextField*)sender;
    [txt resignFirstResponder];
}


-(void)TcpManageBegin
{
    NSLog(@"TcpManageBegin 开始连接.");
}

-(void)TcpManageConnectCallback:(BOOL) b
{
    if(b)
    {
        NSLog(@"连接成功.");
        [self performSelectorOnMainThread:@selector(log:) withObject:@"连接成功..." waitUntilDone:YES];
    }
    else
    {
        NSLog(@"TcpManageConnectCallback 连接失败.");
        [self performSelectorOnMainThread:@selector(log:) withObject:@"连接失败.!!" waitUntilDone:YES];
        [txtIP setEnabled:YES];
        [txtPort setEnabled:YES];
        btnStartTCP.selected=false;
    }
}

-(void)TcpManageRecvCallback:(char*)buf :(int)len
{
    //日志
    NSMutableString * str=[[NSMutableString alloc] init];
    [str appendFormat:@"<-%d字节=",len];
    for (int i=0; i<len; i++) {
        [str appendFormat:@"%02X ",(unsigned char)buf[i]];
    }
    [self performSelectorOnMainThread:@selector(log:) withObject:str waitUntilDone:YES];
    str=nil;
}

-(void)TcpManageDisconnectCallback
{
    NSLog(@"TcpManageDisconnectCallback 断开连接.");
    [self performSelectorOnMainThread:@selector(log:) withObject:@"断开连接.!!" waitUntilDone:YES];
    [txtIP setEnabled:YES];
    [txtPort setEnabled:YES];
    btnStartTCP.selected=false;
}

@end
