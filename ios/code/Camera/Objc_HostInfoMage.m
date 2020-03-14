//
//  Objc_HostInfoMage.m
//  monitor
//
//  Created by Han Sohn on 12-6-16.
//  Copyright (c) 2012年 Han.zhihong. All rights reserved.
//

#import "Objc_HostInfoMage.h"

extern CLLocationCoordinate2D g_WGS84Location;
extern CLLocationCoordinate2D g_GoogleLocation;

@implementation Objc_HostInfoMage

-(id) init
{
    if((self=[super init]))
    {
        m_aryHostInfo=[[NSMutableArray alloc] init];
        m_sDatabasePath=[[NSMutableString alloc] init];

        //连接数据库取数据
        m_sqlMage=[[Objc_Sqlite alloc] init];
        
        [m_sDatabasePath setString:[m_sqlMage documentPath:@"ios.zh.monitor.1.sqlite"]];
        NSLog(@"Database Path=%@",m_sDatabasePath);
        if (0==access([m_sDatabasePath UTF8String], 0)) {
            [self openDB];
        }
        else {
            [self createDB];
        }
    }
    
    return self;
}

-(void) dealloc
{
    NSLog(@"HostInfoMage dealloc");
    m_aryHostInfo=nil;

    m_sDatabasePath=nil;

    [m_sqlMage close];
    m_sqlMage=nil;
}

-(BOOL) createDB
{
    //文件不存在即建立数据库并创建数据表
    if ([m_sqlMage open:m_sDatabasePath]) {
        if (NO==[m_sqlMage createHostInfoTable])        //创建流量信息数据表
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", nil) 
                                                            message:NSLocalizedString(@"sqlite_create_table_fail", nil)
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
            [alert setTag:100];
            [alert show];
            alert=nil;
            return NO;
        }
    }
    else {
        //创建数据库失败
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", nil) 
                                                        message:NSLocalizedString(@"sqlite_create_db_fail", nil)
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
        [alert setTag:101];
        [alert show];
        alert=nil;
        return NO;
    }
    return YES;
}

-(BOOL) openDB
{
    //直接打开不新建表格
    if (NO==[m_sqlMage open:m_sDatabasePath])
    {
        //打开数据表失败 
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", nil) 
                                                        message:NSLocalizedString(@"sqlite_open_db_fail", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"no", nil)
                                              otherButtonTitles:NSLocalizedString(@"yes", nil), nil];
        [alert setTag:102];
        [alert show];
        alert=nil;
        return NO;
    }
    return YES;
}

-(BOOL) deleteDB
{
    return [[NSFileManager defaultManager] removeItemAtPath:m_sDatabasePath error:nil];
}

/////////////////////////////////////////////
//设备主机信息
-(void) reloadHostInDB
{
    [m_aryHostInfo removeAllObjects];
    [m_sqlMage getHostInfo:m_aryHostInfo];
}

-(NSArray*) getHostInfoList
{
    return m_aryHostInfo;
}

//插入主机信息
-(BOOL) insertHostInfo:(char*) title
                      :(char*) host
                      :(int) port
                      :(TDevceID) devID
                      :(char*) username
                      :(char*) password
                      :(char*) parameter
{
    //////插入到数据库
    if ([m_sqlMage insertHostInfo:title :host :port 
                                 :devID :username :password 
                                 :parameter])
    {
        //////添加到链表
        TagHostInfo info;
        memset(&info, 0, sizeof(TagHostInfo));
        info.autoID=[m_sqlMage getHostInfoLastInsertID];
        strcpy(info.title,title);
        strcpy(info.host,host);
        info.port=port;
        info.devID=devID;
        strcpy(info.username,username);
        strcpy(info.password,password);
        strcpy(info.parameter,parameter);

        NSData *nsData=[NSData dataWithBytes:&info length:sizeof(TagHostInfo)];
        [m_aryHostInfo addObject:nsData];
        return YES;
    }

    //写入新记录失败
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", nil) 
                                                    message:NSLocalizedString(@"sqlite_insert_fail", nil)
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
    [alert setTag:106];
    [alert show];
    alert=nil;
    return NO;
}

- (BOOL) updateHostInfo:(int)autoID :(char*)title :(char*)host :(int)port 
                       :(TDevceID)devID :(char*)username :(char*)password
                       :(char*)parameter
{
    if ([m_sqlMage updateHostInfo:autoID :title :host :port 
                                 :devID :username :password :parameter]) 
    {
        TagHostInfo *p=(TagHostInfo *)[self getHostByAutoID:autoID];
        p->autoID=autoID;
        strcpy(p->title, title);
        strcpy(p->host, host);
        p->port=port;
        p->devID=devID;
        strcpy(p->username, username);
        strcpy(p->password, password);
        strcpy(p->parameter, parameter);
        return YES;
    }
    //更新记录失败
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", nil) 
                                                    message:NSLocalizedString(@"sqlite_update_fail", nil)
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
    [alert setTag:107];
    [alert show];
    alert=nil;
    return NO;
}

-(TagHostInfo*) getHostByAutoID:(int)autoID
{
    TagHostInfo *p;
    for (int i=0; i<[m_aryHostInfo count]; i++) {
        p=(TagHostInfo*)[[m_aryHostInfo objectAtIndex:i] bytes];
        if (autoID==p->autoID) {
            return p;
        }
    }
    return NULL;
}

-(void) deleteHostByIndex:(int)index
{
    TagHostInfo*p=(TagHostInfo*)[[m_aryHostInfo objectAtIndex:index] bytes];
    //删除数据库里的记录
    [m_sqlMage deleteHostInfo:p->autoID];
    //移除链表
    [m_aryHostInfo removeObjectAtIndex:index];
}

//重载的函数
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	switch (alertView.tag) {
        case 102://打开数据表失败 
        {
            if (buttonIndex==1) {
                //删除数据库并重新打开
                if ([self deleteDB]) {
                    [self createDB];
                }
                else {
                    //删除数据库失败
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"error", nil) 
                                                                    message:NSLocalizedString(@"sqlite_delete_db_fail", nil)
                                                                   delegate:self
                                                          cancelButtonTitle:nil
                                                          otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
                    [alert setTag:103];
                    [alert show];
                    alert=nil;
                }
            }
            else {
                //不删除数据库
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert", nil) 
                                                                message:NSLocalizedString(@"sqlite_cant_operated", nil)
                                                               delegate:self
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:NSLocalizedString(@"ok", nil), nil];
                [alert setTag:104];
                [alert show];
                alert=nil;
            }
        }
            break;
        case 103:
        {
            //退出程序
            exit(0);
        }
            break;
        case 104:
        {
            //退出程序
            exit(0);
        }
            break;
        case 105:
        {
            //退出程序
            exit(0);
        }
            break;
    }
}


@end
