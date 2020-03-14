//
//  Forgot_iPhone.h
//  smart
//
//  Created by Han.zh on 14-8-21.
//  Copyright (c) 2014年 Han.zhihong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebProc.h"

@interface Forgot_iPhone : UIViewController<WebPocDelegate>
{
    __weak IBOutlet UITextField *_txtEmail;
    WebProc* _web;
}
- (IBAction)itmNext_click:(id)sender;
- (IBAction)txtDone:(id)sender;

@end
