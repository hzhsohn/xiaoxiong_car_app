/*
 MFNetSocket.h: interface for the C_NetSocket class.
 */

#ifndef __C_NET_SOCKET_H__
#define __C_NET_SOCKET_H__
#ifdef __cplusplus
extern "C"{
#endif
    
#include "dh_platform.h"
    
#ifdef WIN32
    /*
     for windows
     */
#include <winsock.h>
#define GETERROR			WSAGetLastError()
#define CLOSESOCKET(s)		closesocket(s)
#define IOCTLSOCKET(s,c,a)  ioctlsocket(s,c,a)
#define CONN_INPRROGRESS	WSAEWOULDBLOCK
    typedef int socklen_t;
#pragma comment(lib, "Ws2_32.lib")
#else
    /*
     for linux
     */
#include <sys/time.h>
#include <stddef.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/wait.h>
    
#define TRUE  1
#define FALSE 0
    
    /*
     for socket
     */
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <netdb.h>
#include <sys/errno.h>
#include <arpa/inet.h>
#include <net/if.h>
    
    typedef int SOCKET;
    typedef struct sockaddr_in			 sockaddr_in;
    typedef struct sockaddr			SOCKADDR;
#define INVALID_SOCKET	    (-1)
#define SOCKET_ERROR        (-1)
#define GETERROR			errno
#define WSAEWOULDBLOCK		EWOULDBLOCK
#define CLOSESOCKET(s)		close(s)
#define IOCTLSOCKET(s,c,a)  ioctl(s,c,a)
#define CONN_INPRROGRESS	EINPROGRESS
#endif
    
#define		ZH_SOCK_UDP		1
#define		ZH_SOCK_TCP		2
    
    bool dhsClose(SOCKET s);
    bool dhsInit(SOCKET *s,int protocol);
    bool dhsConnect(SOCKET s,char *szAddr,int port,unsigned long ip);
    bool dhsBindAddr(SOCKET s,char *ip,int port);
    bool dhsListen(SOCKET s);
    SOCKET dhsAccept(SOCKET s);
    
    int dhsRecv(SOCKET s,char *buf,int len);
    int dhsSend(SOCKET s,char *buf,int len);
    int dhsRecvFrom(SOCKET s,char *buf,int len,struct sockaddr_in *addr,int *addrlen);
    int dhsSendTo(SOCKET s,char *buf,int len,struct sockaddr_in *addr);
    
    bool dhsCanWrite(SOCKET s);
    bool dhsCanRead(SOCKET s);
    bool dhsHasExcept(SOCKET s);
    //设置成非阻塞
    bool dhsSetNonBlocking(SOCKET s,bool bSetBlock);
    void dhsReset(SOCKET s);
    
    bool dhsSetSendBufferSize(SOCKET s,int len);
    bool dhsSetRecvBufferSize(SOCKET s,int len);
    bool dhsSetReuseAddr(SOCKET s,bool reuse);
    
    bool dhsGetLocalAddr (SOCKET s,char *addr,unsigned short *port,unsigned long *ip);
    bool dhsGetRemoteAddr(SOCKET s,char *addr,unsigned short *port,unsigned long *ip);
    
    
    int dhsGetCount();
    
    bool dhs_NetStartUp(SOCKET s,int VersionHigh,int VersionLow);
    bool dhs_NetCleanUp(SOCKET s);
    
    //获取域名IP
    char* dhsGetIp(char*dn_or_ip);
    
#ifdef __cplusplus
}
#endif
#endif
