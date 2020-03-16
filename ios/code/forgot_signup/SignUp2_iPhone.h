//
//  SignUp2_iPhone.h
//  smart
//
//  Created by Han.zh on 14-8-21.
//  Copyright (c) 2014年 Han.zhihong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebProc.h"

@class SignUpFail_iPhone;
@interface SignUp2_iPhone : UIViewController<WebPocDelegate>
{
    __weak IBOutlet UITextField *_txtPassword1;
    __weak IBOutlet UITextField *_txtPassword2;
    
    NSMutableString* _sEmail;
    NSMutableString* _sNickname;
    
    WebProc* _web;
}

- (void)setInfo:(NSString*)email :(NSString*)nick;
- (IBAction)btnSave_click:(id)sender;

@end
