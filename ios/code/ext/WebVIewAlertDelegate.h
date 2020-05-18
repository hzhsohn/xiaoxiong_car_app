//
//  WebVIewAlertDelegate.m
//  discolor-led
//
//  Created by Han.zh on 15/4/13.
//  Copyright (c) 2015年 Han.zhihong. All rights reserved.
//

#import <Foundation/Foundation.h>
////////////////////////////////////////

/* 测试例子
 
 <script>
 function aa(b)
 {
 document.write(b);
 }
 
 alert("message box");
 alert("cmd:close");
 cc=confirm("yes or no");
 aa(cc);
 
 cc=prompt("input box","!@#");
 aa(cc);
 </script>
 */

@interface UIWebView(JavaScriptAlertOfUIWebView)
@end

@implementation UIWebView(JavaScriptAlertOfUIWebView)

static BOOL diagStat = NO;
//这是委托的回调,检测无刷新执行命令的
//-(void) webView:(UIWebView *)sender CommandDelegate:(NSString*)cmd;
- (void)webView:(UIWebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame {
    
    if (0==strncmp([message UTF8String], "cmd:", 4))
    {
        //添加控制命令
      //  [self.delegate webView:sender CommandDelegate:[NSString stringWithUTF8String:[message UTF8String]+4]];
    }
    else
    {
        
        UIAlertView* customAlert = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [customAlert show];
       // [customAlert release];
        customAlert=nil;
    }
}


- (BOOL)webView:(UIWebView *)sender runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame
{
    UIAlertView *confirmDiag = [[UIAlertView alloc] initWithTitle:nil
                                                          message:message delegate:self
                                                cancelButtonTitle:@"确定"
                                                otherButtonTitles:@"取消", nil];
    
    [confirmDiag show];
    
    
    
    while (confirmDiag.hidden == NO && confirmDiag.superview != nil)
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01f]];
    
    
    //[confirmDiag release];
    confirmDiag=nil;
    
    return diagStat;
}

- (NSString *)webView:(UIWebView *)sender runJavaScriptTextInputPanelWithPrompt:(NSString *)str defaultText:(NSString *)mes initiatedByFrame:(WebFrame *)frame
{
    
    UIAlertView *promptDiag = [[UIAlertView alloc] initWithTitle:str
                                                         message:@"\n\n"
                                                        delegate:self
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:@"Cancel",nil];
    
    UITextField *nameField = [[UITextField alloc] initWithFrame:CGRectMake(10, 58, 265, 30)];
    //nameField.borderStyle =  UITextBorderStyleRoundedRect;
    nameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [nameField becomeFirstResponder];
    nameField.backgroundColor = [UIColor whiteColor];
    [nameField setText:mes];
    [promptDiag addSubview:nameField];
   // [nameField release];
    
    [promptDiag show];
    
    while (promptDiag.hidden == NO && promptDiag.superview != nil)
        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01f]];
    
    //[promptDiag release];
    
    if(diagStat)
        
    {
        
        return nameField.text;
        
    }
    
    nameField=nil;
    promptDiag=nil;
    return mes;
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    //index 0 : YES , 1 : NO
    if (buttonIndex == 0){
        //return YES;
        diagStat = YES;
        
    } else if (buttonIndex == 1) {
        //return NO;
        diagStat = NO;
    }
}

/* 这是web.delegate=self 的类回调的函数
 
 -(void) webView:(UIWebView *)sender CommandDelegate:(NSString*)cmd
 
 {
 NSLog(@"Command=%@",cmd);
 if (0==strcasecmp([cmd UTF8String],"close"))
 {
 [self.navigationController popViewControllerAnimated:YES];
 }
 }
 */

@end
