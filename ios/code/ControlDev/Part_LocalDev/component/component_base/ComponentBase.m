//
//  ComponentBase.m
//  code
//
//  Created by Han.zh on 2019/10/13.
//  Copyright © 2019年 Han.zhihong. All rights reserved.
//

#import "ComponentBase.h"
#import "DevPasswdMagr.h"
#import  <libHxkNet/McuNet.h>

@interface ComponentBase()

-(void) showInputPasswd;

@end

@implementation ComponentBase

-(void) setUserPassword:(NSString*)devUUID u:(NSString*)user p:(NSString*)password
{
    [DevPasswdMagr newPasswdByDevUUID:user
                                     :password
                                     :self.devUUID];
}

-(BOOL) getUserPassword:(NSString*)devUUID u:(char*)user p:(char*)password
{
    BOOL ret=FALSE;
    
    TzhPasswdMgr pm=[DevPasswdMagr infoByDevUUID:devUUID];
    if(strcmp(pm.devUUID,""))
    {
        strcpy(user,pm.username);
        strcpy(password,pm.passwd);
        if(0==strcmp(password,[DEFAUT_LOCAL_PASSWD_NULL_VAL UTF8String]))
        {
            strcpy(password,"");
        }
        ret=TRUE;
    }
    
    return ret;
}

-(NSData*) getPasswordKey:(NSString*)devUUID
{
    //查询数据库里面有没有这个设备的密码
    TzhPasswdMgr pm=[DevPasswdMagr infoByDevUUID:devUUID];
    if(strcmp(pm.devUUID,""))
    {
        char ckey[6]={0};
        NSString*password=[NSString stringWithUTF8String:pm.passwd];
        if([password isEqualToString:@""])
        {
            [self showInputPasswd];
        }
        else
        {
            if([password isEqualToString:DEFAUT_LOCAL_PASSWD_NULL_VAL])
            {
                [McuKeyGen genKey:ckey :@""];
            }
            else
            {
                [McuKeyGen genKey:ckey :password];
            }
            self.ctrlKey=[NSData dataWithBytes:ckey length:6];
        }
    }
    else
    {
        [self showInputPasswd];
    }
    return self.ctrlKey;
}

-(void) showInputPasswd
{
    //第一次使用弹出输入密码的框
    NSLog(@"打开密码输入窗体");
    //输入设备密码的框
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert", nil)
                                                    message:NSLocalizedString(@"frist_use_dev", nil)
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"ok", nil)
                                          otherButtonTitles:NSLocalizedString(@"cancel", nil),nil];
    [alert setAlertViewStyle:UIAlertViewStyleSecureTextInput];
    UITextField *nameField = [alert textFieldAtIndex:0];
    nameField.placeholder = NSLocalizedString(@"input_passwd_tip",nil);
    alert.tag=199;
    [alert show];
    alert=NULL;
}

//这段代码要复制到各个子窗体中重载的函数
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
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
                }
                else
                {
                    [self.navigationController popViewControllerAnimated:YES];
                }
            break;
    }
}

@end
