//
//  MyProfileBaseInfo.h
//  home
//
//  Created by Han.zh on 2017/4/25.
//  Copyright © 2017年 Han.zhihong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CAIDModifyDelegate <NSObject>

-(void)CAIDModifyContent_change:(NSString*)strContent;

@end

@interface CAIDModify : UITableViewController

@property (nonatomic,copy) NSString* strTitle;
@property (nonatomic,copy) NSString* strContent;
//修改的内容标识
@property (nonatomic,copy) NSString* modify_autoid;

@property (assign,nonatomic) id<CAIDModifyDelegate> delegate;

@end
