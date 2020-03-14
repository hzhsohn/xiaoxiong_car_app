//
//  TcpManage.m
//  RegalConcise
//
//  Created by sohn on 13-6-2.
//  Copyright (c) 2013年 Han.zhihong. All rights reserved.
//

#import "TcpManage.h"
#import "dh_socket.h"
#include "dh_platform.h"

@interface TcpManage ()
{
    NSMutableString* m_sHost;
    int m_nPort;
    
    unsigned long lastConnectTime;
    SOCKET s;
    TTcpManageStatus status;
}

@end

@implementation TcpManage
@synthesize delegate;

-(id)init
{
    if((self=[super init]))
    {
        m_sHost=[[NSMutableString alloc] init];
        status=ZH_TCP_MANGE_DISCONNECT;
        lastConnectTime=0;
        s = INVALID_SOCKET;
    }
    return self;
}

-(void)dealloc
{
    //[super dealloc];

    //[m_sHost release];
    m_sHost=nil;
}


-(void)th_connect
{
    BOOL b;
    
    dhsInit(&s, ZH_SOCK_TCP);
    dhsSetNonBlocking(s,false);
    b=dhsConnect(s, (char*)[m_sHost UTF8String], m_nPort, 0);
    dhsSetNonBlocking(s,true);
    
    if (b) {
        [delegate TcpManageConnectCallback:YES];
        status=ZH_TCP_MANGE_CONNECTED;
        NSLog(@"connect success...");
    }
    else{
        [delegate TcpManageConnectCallback:NO];
        status=ZH_TCP_MANGE_DISCONNECTING;
        NSLog(@"connect fail...");
    }
}

-(BOOL)connect_start:(NSString*)host :(int)port
{
    if (0==port) {
        return false;
    }
    if ([host isEqualToString:@""]) {
        return false;
    }
    
    [m_sHost setString:host];
    m_nPort=port;
    
    status=ZH_TCP_MANGE_CONNECT_INIT;
    
    return TRUE;
}

-(void)disconnect_will_reconnect
{
    dhsClose(s);
    status=ZH_TCP_MANGE_DISCONNECTING;
}

-(void)disconnect_not_reconnect
{
    dhsClose(s);
    status=ZH_TCP_MANGE_NOT_RECONNECT;
}

-(BOOL)isConnected
{
    return ZH_TCP_MANGE_CONNECTED==status;
}

-(void)thread
{
    if (0==m_nPort) {
        return;
    }
    if ([m_sHost isEqualToString:@""]) {
        return;
    }
    
    switch (status) {
        case ZH_TCP_MANGE_DISCONNECT:
        {
            unsigned long tmp=time(NULL);
            if (tmp-lastConnectTime>7000) {
                lastConnectTime=tmp;
                status=ZH_TCP_MANGE_CONNECT_INIT; //重新连接
                dhsClose(s);
            }
        }
            break;
        case ZH_TCP_MANGE_DISCONNECTING:
        {
            [delegate TcpManageDisconnectCallback];
            status=ZH_TCP_MANGE_DISCONNECT;
        }
            break;
        case ZH_TCP_MANGE_CONNECT_INIT:
        {
            
            status=ZH_TCP_MANGE_CONNECTING;
            NSLog(@"Tcp Connect %@:%d",m_sHost, m_nPort);
            
            [delegate TcpManageBegin];
            NSThread* th = [[NSThread alloc] initWithTarget:self selector:@selector(th_connect) object:nil];
            [th setName:@"New Thread connect"];
            [th start];
            //[th release];
            th=nil;
        }
            break;
        case ZH_TCP_MANGE_CONNECTING:
            break;
        case ZH_TCP_MANGE_CONNECTED:
        {
            int len;
            char buf[1024];
            len=dhsRecv(s, buf, sizeof(buf));
            if(len>0)
            {
                //NSLog(@"socket recv len=%d",len);
                [delegate TcpManageRecvCallback:buf :len];
            }
            else if(len==SOCKET_ERROR)
            {
                status=ZH_TCP_MANGE_DISCONNECTING;
            }
        }
            break;
        case ZH_TCP_MANGE_NOT_RECONNECT:
            break;
    }
}

-(int)send:(char*)buf :(int)len
{
    return dhsSend(s, buf, len);

}

@end
