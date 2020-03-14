//
//  DevlistCellLoadForm.m
//  home
//
//  Created by Han.zh on 2017/6/16.
//  Copyright © 2017年 Han.zhihong. All rights reserved.
//

#import "DevlistCellLoadForm.h"
#import "JSONKit.h"
#import "DevPasswdMagr.h"
#import "DefineHeader.h"
#import  <libHxkNet/McuNet.h>

@implementation DevlistCellLoadForm
{
    DevKeyMagr *_devmgr;
    DevPasswdMagr* _devpwd;   //数据库操作对象
}


-(id)init
{
    if((self=[super init]))
    {
        _devmgr=[[DevKeyMagr alloc] init];
        _devpwd=[[DevPasswdMagr alloc] init];
    }
    return self;
}

-(void)dealloc
{
    _devmgr=nil;
    _devpwd=nil;
}

/*
 设置支持的设备
*/
-(BOOL) checkDevDepend:(const char*)flag
{
    if(0==strcasecmp(flag, "TT_MODULE")) //透传调试界面
    {
        return TRUE;
    }
    else if(0==strcasecmp(flag, "PM"))
    {
        return TRUE;
    }
    else if(0==strcasecmp(flag, "LED-RGBW"))
    {
        return TRUE;
    }
    else if(0==strcasecmp(flag, "XMAP"))
    {
        return TRUE;
    }
    return FALSE;
}

/*
 设置支持的设备
*/
-(DeviceIDTemplate*) loadDevDepend:(const char*)flag
{
    //进入界面
    DeviceIDTemplate*tt=NULL;
    UIStoryboard *frm=NULL;
    if(0==strcasecmp(flag, "TT_MODULE")) //透传调试界面
    {
        frm = [UIStoryboard storyboardWithName:@"Part_TT_MOU" bundle:nil];
        tt = [frm instantiateViewControllerWithIdentifier:@"Part_TT_MOU"];
    }
    else if(0==strcasecmp(flag, "PM"))
    {
        frm = [UIStoryboard storyboardWithName:@"Part_PM" bundle:nil];
        tt = [frm instantiateViewControllerWithIdentifier:@"Part_PM"];
    }
    else if(0==strcasecmp(flag, "LED-RGBW"))
    {
        frm = [UIStoryboard storyboardWithName:@"Part_LED_RGBW" bundle:nil];
        tt = [frm instantiateViewControllerWithIdentifier:@"Part_LED_RGBW"];
    }
    else if(0==strcasecmp(flag, "XMAP"))
    {
        frm = [UIStoryboard storyboardWithName:@"Part_XMap" bundle:nil];
        tt = [frm instantiateViewControllerWithIdentifier:@"Part_XMap"];
    }
    return tt;
}

-(DeviceIDTemplate *)loadStoryboard :(int)netType
                                    :(const char*)flag
                                    :(const char*)devUUID
                                    :(const char*)devname
                                    :(const char*)dvar
                                    :(const char*)host
                                    :(int)port
{
    //------------------------------
    if(![_devmgr getDevCheckDevUUID:[NSString stringWithUTF8String:devUUID]])
    {
        TzhKeyMgrSaveInfo msi={0};
        strcpy(msi.devUUID,devUUID);
        strcpy(msi.devflag,flag);
        strcpy(msi.devname,devname);
        [_devmgr insertDevInfo:&msi];
    }
    
    //判断字符串是否正确
    NSString*devU=[NSString stringWithUTF8String:devUUID];
    if(nil==devU)
    {
        return NULL;
    }
    
    //------------------------------
    //进入界面
    DeviceIDTemplate*tt=[self loadDevDepend:flag];
    if(tt)
    {
        if(NULL==host)
        {host="";}
        [tt setDeviceInfo:netType
                         :[NSString stringWithUTF8String:devUUID]
                         :[NSString stringWithUTF8String:devname]
                         :[NSString stringWithUTF8String:flag]
                         :[NSString stringWithUTF8String:host]
                         :port];
        return tt;
    }
    return NULL;
}

-(void)updateCell :(const char*)flag :(DevListCell*)dcell :(NSString*)dvar
{
}

@end
