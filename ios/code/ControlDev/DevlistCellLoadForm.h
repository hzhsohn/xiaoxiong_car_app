//
//  DevlistCellLoadForm.h
//  home
//
//  Created by Han.zh on 2017/6/16.
//  Copyright © 2017年 Han.zhihong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeviceIDTemplate.h"
#import "DevListCell.h"

@interface DevlistCellLoadForm : NSObject

-(BOOL) checkDevDepend:(const char*)flag;
-(DeviceIDTemplate*) loadDevDepend:(const char*)flag;

-(DeviceIDTemplate *)loadStoryboard :(int)netType
                                    :(const char*)flag
                                    :(const char*)devUUID
                                    :(const char*)devname
                                    :(const char*)dvar
                                    :(const char*)host
                                    :(int)port;

-(void)updateCell :(const char*)flag :(DevListCell*)dcell :(NSString*)dvar;

@end
