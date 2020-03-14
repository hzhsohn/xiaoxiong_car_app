//
//  XMapMenu_Password.m
//  code
//
//  Created by Be-Service on 2019/12/23.
//  Copyright © 2019 Han.zhihong. All rights reserved.
//

#import "XMapMenu_Password.h"
#import <libxmap/libxmap.h>
#import "JSONKit.h"
#import "McuGlobalParameter.h"
#import "XMapWallElement.h"
#import "XMBaseStatus.h"
#import "Part_XMap_Cell_UserList.h"
#import "SVProgressHUD.h"
extern McuGlobalParameter *mcuParameter;

@interface XMapMenu_Password ()<XMapDTRSListener>
{
    XMapDTRS* xmap;
    __weak IBOutlet UITextField *oldPassword;
    __weak IBOutlet UITextField *newPassword;
    __weak IBOutlet UITextField *newPassword2;
    char newPass[256];
}
@end

@implementation XMapMenu_Password

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"用户列表";
    oldPassword.secureTextEntry = true;
    newPassword.secureTextEntry = true;
    newPassword2.secureTextEntry = true;
    xmap=(XMapDTRS*)[mcuParameter getParameter:@"+xmap"];
    [xmap.delegateList addObject:self];
    

    //返回键
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"back", nil) style:UIBarButtonItemStyleDone target:self action:@selector(onBackButtonClicked:)]];
    self.navigationItem.hidesBackButton = YES;
}

- (void)onBackButtonClicked:(id)sender{
    //返回主界面
       [self.navigationController popViewControllerAnimated:true];
}




- (IBAction)submit:(UIButton *)sender {
    if (!(oldPassword.text.length > 0)){
        [SVProgressHUD showErrorWithStatus:@"旧密码不能为空"];
        return;
    }
    if (!(newPassword.text.length > 0)){
        [SVProgressHUD showErrorWithStatus:@"新密码不能为空"];
        return;
    }
    if (!(newPassword2.text.length > 0)){
        [SVProgressHUD showErrorWithStatus:@"重复新密码不能为空"];
        return;
    }
    if (![newPassword.text isEqualToString:newPassword2.text]){
        [SVProgressHUD showErrorWithStatus:@"两次新密码不一致"];
        return;
    }
    
    strcpy(newPass,[newPassword.text UTF8String]);
    [xmap sendPack:[XMapCommand modifyPassword :[oldPassword.text UTF8String] :newPass]];
}

//检测是否返回
- (void)didMoveToParentViewController:(UIViewController*)parent{
    [super didMoveToParentViewController:parent];
    if(!parent){
        NSLog(@"XMapWallList 页面pop成功了");
        [xmap.delegateList removeObject:self];
    }
}

// XMapDTRS 的回调
//
-(void) XMapDTRS_devuuid_subscr_success
{
    
}
-(void) XMapDTRS_sign_success
{
    
}

-(void) XMapDTRS_new_data:(char*) data :(int)len
{
    short cmd=0;
    memcpy(&cmd,data,2);
    NSLog(@"XMapWallList new_data len=%d , cmd=%d",len,cmd);
    
    switch (cmd) {
           case ecpuSToCJsonCommand:
           {
               NSString* pjsonData=[NSString stringWithUTF8String:&data[2]];

               NSData*jsonData=[NSData dataWithData:[pjsonData dataUsingEncoding: NSUTF8StringEncoding]];
               NSDictionary *result = [jsonData objectFromJSONData];
               NSString*jcmd=[result objectForKey:@"cmd"];
               
               if([jcmd isEqualToString:@"my_password_rb"])
               {
                   NSDictionary* its = [result objectForKey:@"its"];
                   BOOL b = its[@"ret"];
                   if (b){
                       strcpy(g_XMBaseStatus.XMapUser.userpasswd,newPass );
                       [SVProgressHUD showSuccessWithStatus:@"修改密码成功"];
                       [SVProgressHUD dismissWithDelay:1.5];
                       [self.navigationController popViewControllerAnimated:true];
                   }else{
                       [SVProgressHUD showSuccessWithStatus:@"修改密码失败"];
                       [SVProgressHUD dismissWithDelay:1.5];
                   }
                   
                   
               }
           }
           break;
       }
}

//通讯异常
-(void) XMapDTRS_abnormal_communication:(int)errid :(NSString*) msg
{
}
-(void) XMapDTRS_disconnect
{
}


@end
