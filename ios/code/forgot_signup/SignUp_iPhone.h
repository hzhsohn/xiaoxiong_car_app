//
//  AddAccount_iPhone.h
//  Smart
//
//  Created by sohn on 12-11-14.
//  Copyright (c) 2012年 sohn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebProc.h"


@interface SignUp_iPhone : UIViewController<WebPocDelegate>
{
    WebProc* _web;
    
    __weak IBOutlet UITextField* _txtEmail;
    __weak IBOutlet UITextField* _txtNickname;
    __weak IBOutlet UILabel *_txtUserID;
    
}

- (IBAction) txtDone:(id)sender;
- (IBAction) btnNext_click:(id)sender;

@end
