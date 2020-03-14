//
//  SignUpFail_iPhone.h
//  smart
//
//  Created by Han.zh on 14-8-21.
//  Copyright (c) 2014年 Han.zhihong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignUpFail_iPhone : UIViewController
{
    __weak IBOutlet UILabel *_lbReason;

}

-(void) setReason:(NSString*)str;
@end
