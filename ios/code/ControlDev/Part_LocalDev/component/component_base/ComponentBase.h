//
//  ComponentBase.h
//  code
//
//  Created by Han.zh on 2019/10/13.
//  Copyright © 2019年 Han.zhihong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeviceIDTemplate.h"


#define DEFAUT_LOCAL_PASSWD_NULL_VAL    @"^_^_i_am_hx-kong_,i_am_very_good_>.<"

@interface ComponentBase : DeviceIDTemplate

@property (nonatomic,copy) NSData* ctrlKey;

-(void) setUserPassword:(NSString*)devUUID u:(NSString*)user p:(NSString*)password;
-(BOOL) getUserPassword:(NSString*)devUUID u:(char*)user p:(char*)password;
-(NSData*) getPasswordKey:(NSString*)devUUID;

@end
