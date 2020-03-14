/*
 Cnetsocket.cpp: implementation of the C_NetSocket class.
 */

#include "dh_socket.h"
#include <stdio.h>

int g_nCount = 0;

bool dhs_NetStartUp(SOCKET s,int VersionHigh,int VersionLow)
{
#ifdef WIN32
    WORD wVersionRequested;
    WSADATA wsaData;
    int err;
    
    wVersionRequested = MAKEWORD(VersionHigh,VersionLow);
    err=WSAStartup(wVersionRequested, &wsaData);
    
    /* startup failed */
    if (err!=0)
    {
        PRINTF("WSAStartup Error");
        WSACleanup();
        return false;
    }
    
    /* version error */
    if (LOBYTE(wsaData.wVersion)!= VersionLow ||
        HIBYTE(wsaData.wVersion)!= VersionHigh )
    {
        PRINTF("WSAStartup Version Error");
        WSACleanup();
        return false;
    }
    PRINTF("WSAStartup OK");
#endif
    return true;
}

bool dhs_NetCleanUp(SOCKET s)
{
#ifdef WIN32
    WSACleanup();
#endif
    return true;
}

bool dhsInit(SOCKET *s,int protocol)
{
    if (g_nCount++==0)
        if (!dhs_NetStartUp(*s,1,1)) return false;
    
    if (protocol==ZH_SOCK_UDP)
    {
        *s=socket(AF_INET,SOCK_DGRAM,IPPROTO_UDP);
    }
    else
    {
        *s=socket(AF_INET,SOCK_STREAM,IPPROTO_TCP);
    }
    
    if(*s==INVALID_SOCKET)
    {
        return false;
    }
    return true;
}

bool dhsBindAddr(SOCKET s,char *ip,int port)
{
    struct sockaddr_in addrLocal;
    addrLocal.sin_family=AF_INET;
    addrLocal.sin_port=htons(port);
    if(ip)
    {
        addrLocal.sin_addr.s_addr=inet_addr(ip);
    }
    else
    {
        addrLocal.sin_addr.s_addr=htonl(INADDR_ANY);
    }
    if(bind(s,(SOCKADDR *)&addrLocal,sizeof(addrLocal))==SOCKET_ERROR)
    {
        //PRINTF("bind socket error");
        return false;
    }
    return true;
}

bool dhsListen(SOCKET s)
{
    if(listen(s,SOMAXCONN)==SOCKET_ERROR)
    {
        //PRINTF("NetSocket:listen error");
        return false;
    }
    return true;
}

bool dhsConnect(SOCKET s,char *szAddr, int port, unsigned long ip)
{
    struct sockaddr_in addrRemote;
    struct hostent *host;
    int err;
    
    host=NULL;
    
    memset(&addrRemote,0,sizeof(addrRemote));
    addrRemote.sin_family=AF_INET;
    addrRemote.sin_port=htons(port);
    
    if(szAddr)
        addrRemote.sin_addr.s_addr = inet_addr(szAddr);
    else
        addrRemote.sin_addr.s_addr = ip;
    
    if(addrRemote.sin_addr.s_addr==INADDR_NONE)
    {
        if(!szAddr) return false;
        host=gethostbyname(szAddr);
        if(!host) return false;
        memcpy(&addrRemote.sin_addr,host->h_addr_list[0],host->h_length);
    }
    
    if(connect(s,(SOCKADDR *)&addrRemote,sizeof(addrRemote))==SOCKET_ERROR)
    {
        err = GETERROR;
        if (err != CONN_INPRROGRESS)
        {
            //PRINTF("socket connect error = %d",err);
            return false;
        }
    }
    return true;
}

/*
 * return value
 * =  0 send failed
 * >  0	bytes send
 * = -1 net dead
 */
int dhsSend(SOCKET s,char *buf, int len)
{
    int ret;
    
    if (!dhsCanWrite(s)) return 0;
    /*
     in linux be careful of SIGPIPE
     */
    ret = send(s,buf,len,0);
    if (ret==SOCKET_ERROR)
    {
        int err=GETERROR;
        if (err==WSAEWOULDBLOCK) return 0;
        return -1;
    }
    return ret;
}

/*
 * return value
 * =  0 recv failed
 * >  0	bytes recv
 * = -1 net dead
 */
int dhsRecv(SOCKET s,char *buf, int len)
{
    int ret;
    
    if (dhsCanRead(s)==false)
        return 0;
    
    /* in linux be careful of SIGPIPE */
    ret = recv(s,buf,len,0);
    
    if (ret==0)
    {
        /* remote closed */
        return -1;
    }
    
    if (ret==SOCKET_ERROR)
    {
        int err=GETERROR;
        if (err!=WSAEWOULDBLOCK)
        {
            return -1;
        }
    }
    return ret;
}


bool dhsCanRead(SOCKET s)
{
    int ret;
    fd_set readfds;
    struct timeval timeout;
    
    timeout.tv_sec=0;
    timeout.tv_usec=0;
    FD_ZERO(&readfds);
    FD_SET(s,&readfds);
    ret = select(FD_SETSIZE,&readfds,NULL,NULL,&timeout);
    if(ret > 0 && FD_ISSET(s,&readfds))
        return true;
    else
        return false;
}

bool dhsCanWrite(SOCKET s)
{
    int ret;
    
    fd_set writefds;
    struct timeval timeout;
    
    timeout.tv_sec=0;
    timeout.tv_usec=0;
    FD_ZERO(&writefds);
    FD_SET(s,&writefds);
    ret = select(FD_SETSIZE,NULL,&writefds,NULL,&timeout);
    if(ret > 0 && FD_ISSET(s,&writefds))
        return true;
    else
        return false;
}

bool dhsClose(SOCKET s)
{
    if (s == INVALID_SOCKET) return false;
    CLOSESOCKET(s);
    dhsReset(s);
    if (--g_nCount==0)
        dhs_NetCleanUp(s);
    return true;
}

SOCKET dhsAccept(SOCKET s)
{
    struct sockaddr_in addr;
    int len = sizeof(addr);
    SOCKET tmp;
    tmp = accept(s,(SOCKADDR *)&addr,(socklen_t *)&len);
    if (tmp == INVALID_SOCKET || tmp == 0)
    {
        //PRINTF("accept error");
        return 0;
    }
    g_nCount++;
    return tmp;
}

int dhsSendTo(SOCKET s,char *buf, int len, struct sockaddr_in *addr)
{
    int ret;
    int err;
    if (!dhsCanWrite(s)) return 0;
    
    ret = sendto(s,buf,len,0,(SOCKADDR *)addr,sizeof(struct sockaddr_in));
    if (ret==SOCKET_ERROR)
    {
        err=GETERROR;
        if (err!=WSAEWOULDBLOCK)
        {
            return -1;
        }
    }
    return ret;
}

int dhsRecvFrom(SOCKET s,char *buf, int len, struct sockaddr_in *addr ,int *addrlen)
{
    int ret;
    if (!dhsCanRead(s)) return 0;
    
    ret = recvfrom(s,buf,len,0,(SOCKADDR *)addr,(socklen_t *)addrlen);
    if (ret==SOCKET_ERROR)
    {
        int err=GETERROR;
        if (err!=WSAEWOULDBLOCK)
        {
            return -1;
        }
    }
    return ret;
}

bool dhsHasExcept(SOCKET s)
{
    int ret;
    fd_set exceptfds;
    struct timeval timeout;
    
    timeout.tv_sec=0;
    timeout.tv_usec=0;
    FD_ZERO(&exceptfds);
    FD_SET(s,&exceptfds);
    ret = select(FD_SETSIZE,NULL,NULL,&exceptfds,&timeout);
    if(ret > 0 && FD_ISSET(s,&exceptfds))
        return true;
    else
        return false;
}

void dhsReset(SOCKET s)
{
    s = INVALID_SOCKET;
}

bool dhsSetNonBlocking(SOCKET s,bool bSetBlock)
{
    /* set to nonblocking mode */
    u_long arg;
    arg = bSetBlock;
    if (IOCTLSOCKET(s,FIONBIO,&arg)==SOCKET_ERROR)
    {
        return false;
    }
    else
    {
        return true;
    }
}

bool dhsSetSendBufferSize(SOCKET s,int len)
{
    int ret;
    ret = setsockopt(s,SOL_SOCKET,SO_SNDBUF,(char *)&len,sizeof(len));
    if (ret == SOCKET_ERROR) return false;
    return true;
}

bool dhsSetRecvBufferSize(SOCKET s,int len)
{
    int ret;
    ret = setsockopt(s,SOL_SOCKET,SO_RCVBUF,(char *)&len,sizeof(len));
    if (ret == SOCKET_ERROR) return false;
    return true;
}

/*
 * get local address
 */
bool dhsGetLocalAddr(SOCKET s,char *addr,unsigned  short *port, unsigned long *ip)
{
    char *tmp;
    struct sockaddr_in addrLocal;
    socklen_t len = sizeof(addrLocal);
    if(getsockname(s,(SOCKADDR*)&addrLocal,&len)==SOCKET_ERROR)
        return false;
    
    tmp = inet_ntoa(addrLocal.sin_addr);
    if(!tmp)
        return false;
    if(addr)
        strcpy(addr,tmp);
    if(port)
        *port = ntohs(addrLocal.sin_port);
    if(ip)
        *ip = addrLocal.sin_addr.s_addr;
    return true;
}

/*
 * get remote address
 */
bool dhsGetRemoteAddr(SOCKET s,char *addr,unsigned short *port,unsigned long *ip)
{
    struct sockaddr_in addrRemote;
    char *tmp;
    int len = sizeof(addrRemote);
    if(getpeername(s,(struct sockaddr *)&addrRemote,(socklen_t *)&len)==SOCKET_ERROR)
        return false;
    
    tmp = inet_ntoa(addrRemote.sin_addr);
    if(!tmp)
        return false;
    if(addr)
        strcpy(addr,tmp);
    if(port)
        *port = ntohs(addrRemote.sin_port);
    if(ip)
        *ip = addrRemote.sin_addr.s_addr;
    return true;
}

bool dhsSetReuseAddr(SOCKET s,bool reuse)
{
#ifndef WIN32
    /* only useful in linux */
    unsigned int len;
    int opt;
    opt = 0;
    len = sizeof(opt);
    
    if(reuse) opt = 1;
    if(setsockopt(s,SOL_SOCKET,SO_REUSEADDR,
                  (const void*)&opt,len)==SOCKET_ERROR)
    {
        return false;
    }
    else
    {
        return true;
    }
#endif
    return true;
}

int dhsGetCount()
{
    return g_nCount;
}


char* dhsGetIp(char*dn_or_ip)
{
#ifdef _WIN32
    WSADATA wsaData;
    PHOSTENT hostinfo; 
    char*ip=NULL;
    if(WSAStartup(MAKEWORD(2,0), &wsaData)== 0)
    { 
        if((hostinfo = gethostbyname(dn_or_ip)) != NULL)
        {
            ip = inet_ntoa (*(struct in_addr *)*hostinfo->h_addr_list); 
        } 
        WSACleanup();
    }
    return ip;
#else
    struct hostent *host;    
    struct ifreq req;
    int sock;
    
    if (dn_or_ip == NULL) return NULL;
    
    if (strcmp(dn_or_ip, "localhost") == 0) {
        sock = socket(AF_INET, SOCK_DGRAM, 0);
        strncpy(req.ifr_name, "eth0", IFNAMSIZ);
        
        if ( ioctl(sock, SIOCGIFADDR, &req) < 0 ) {
            printf("ioctl error: %s\n", strerror (errno));
            return NULL;
        }
        
        dn_or_ip = (char *)inet_ntoa(*(struct in_addr *) &((struct sockaddr_in *) &req.ifr_addr)->sin_addr);
        shutdown(sock, 2);
        close(sock);
    } else {
        host = gethostbyname(dn_or_ip);
        if (host == NULL) return NULL;
        dn_or_ip = (char *)inet_ntoa(*(struct in_addr *)(host->h_addr));
    }
    return dn_or_ip;
#endif
}

