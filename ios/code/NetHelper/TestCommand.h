//
//  TestCommand.h
//  hx-home
//
//  Created by Han.zh on 16/4/6.
//  Copyright © 2016年 Han.zhihong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TestCommandDelegate <NSObject>

-(void)TestCommandCallBack:(NSString*)cmd;

@end

@interface TestCommand : UIViewController

@property(nonatomic,copy) NSString* sOldCommand;

@property(nonatomic,assign) id<TestCommandDelegate> delegate;

@end
