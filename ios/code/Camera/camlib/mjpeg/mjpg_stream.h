//*********************************
// 
// this is canon mjpg-stream module
// 
//*********************************/

#pragma once
#ifndef _ZH_MJPG_STREAM_
#ifdef __cplusplus
extern "C"{
#endif

#include "dh_socket.h"
#include "dh_platform.h"
#include "c_base64.h"

#ifndef _WIN32
#ifndef strcmpi
#define strcmpi strcasecmp
#endif
#endif

#define CAMERA_PAGE_MJPG         "/?action=stream"
    
#define MJPG_JPG_SIZE		800*600*3

typedef struct _TagMjpg_Stream{
	SOCKET s;
	unsigned char btJpg[MJPG_JPG_SIZE];
	unsigned char btCache[MJPG_JPG_SIZE];
	int nCache;
	int nReadPos;
	char isget;
	char redraw;
    char ip[44];
    int port;
    char bAuthorized;
    char user[64];
    char pwd[32];
    char bVerifyNum;
}TagMjpg_Stream;

static bool mjpg_verify_connect(TagMjpg_Stream *mjpg)
{
    if(!mjpg)return false;
    mjpg->nCache=0;
    mjpg->nReadPos=0;
    mjpg->isget=0;
    mjpg->redraw=0;
    
    if(!dhsInit(&mjpg->s,ZH_SOCK_TCP))return false;
    if(!dhsConnect(mjpg->s,mjpg->ip,mjpg->port,0))return false;
    int nRecvBuf=64*1024;
    setsockopt(mjpg->s,SOL_SOCKET, SO_RCVBUF,(const char*)&nRecvBuf,sizeof(int));
    return true;
}

//验证授权
static int mjpg_check_authorized(TagMjpg_Stream *mjpg,char*buf,int len)
{
    char a[20];
    char b[10];
    char c[50];
    memset(a, 0, 20);
    memset(b, 0, 10);
    memset(c, 0, 50);
    
    if(mjpg->bAuthorized==0)
    {
        sscanf(buf,"%s %s %s",a,b,c);
        if(0==strcmpi("401",b) || 0==strcmpi("Unauthorized",c))
        {
            char info[100];
            char base[150];
            char sendbuf[256];
            memset(info,0, sizeof(info));
            memset(base,0, sizeof(base));
            memset(sendbuf,0, sizeof(sendbuf));
            
            dhsClose(mjpg->s);
            mjpg_verify_connect(mjpg);
            mjpg->bAuthorized++;
            //如果第一次验证不通过证明用户名和密码错误
            mjpg->bVerifyNum++;
            //发送授权码
            char *buf="GET %s\r\nAccept-Encoding: gzip, deflate \r\nConnection: Keep-Alive \r\nAuthorization: Basic %s\r\n\r\n";
            
            sprintf(info,"%s:%s",mjpg->user,mjpg->pwd);
            base64_encode(info,strlen(info),base);
            sprintf(sendbuf,buf,CAMERA_PAGE_MJPG,base);
            dhsSend(mjpg->s,sendbuf,strlen(sendbuf));
            return 0;
        }
        else if(0==strcmpi("200",b) || 0==strcmpi("OK",c))
        {
            mjpg->bAuthorized=2;
            mjpg->bVerifyNum=0;
        }
        else
        {
            mjpg->bAuthorized=2;
        }
    }
    else if(mjpg->bAuthorized==1)
    {
        //HTTP/1.0 200 OK
        sscanf(buf,"%s %s %s",a,b,c);
        if(0==strcmpi("200",b) || 0==strcmpi("OK",c))
        {
            mjpg->bAuthorized++;
            //验证清0
            mjpg->bVerifyNum=0;
        }
    }
    return 1;
}

static void mjpg_stream_filter(TagMjpg_Stream *mjpg,char *btBuf,int nSize)
{
	int nCucl=0;
	
	nCucl=mjpg->nCache+nSize;
	if(nCucl>MJPG_JPG_SIZE)
	{
		printf("mjpg->nCache overflow..\n");
		mjpg->nCache=0;
	}
	if(mjpg->nReadPos>MJPG_JPG_SIZE)
	{
		printf("mjpg->nReadPos overflow..\n");
		mjpg->nReadPos=0;
	}

	memcpy(&mjpg->btCache[mjpg->nCache],btBuf,nSize);
	mjpg->nCache=nCucl;
	
	for(;mjpg->nReadPos<nCucl;mjpg->nReadPos++)
	{
		if(mjpg->isget)
		{
			if(mjpg->btCache[mjpg->nReadPos]==0xFF && mjpg->nReadPos+3<=nCucl)
			if(mjpg->btCache[mjpg->nReadPos+1]==0xD9)
			{
				mjpg->isget=0;
				memcpy(mjpg->btJpg,mjpg->btCache,mjpg->nReadPos);
				nCucl=mjpg->nCache-=mjpg->nReadPos;
                if (mjpg->nCache>0) {
                    memmove(mjpg->btCache,&mjpg->btCache[mjpg->nReadPos],mjpg->nCache);
                }
				else
                {mjpg->nCache=0;}
				mjpg->nReadPos=0;
				mjpg->redraw=1;
				{
                    //btJpg 是图片数据 ，mjpg->nReadPos是大小
					int i;
					for(i=0;i<10;i++)
					printf("%02X ",(unsigned char)mjpg->btJpg[i]);
				}
			}
		}
		else
		{
			if(mjpg->btCache[mjpg->nReadPos]==0xFF && mjpg->nReadPos+3<=nCucl)
			if(mjpg->btCache[mjpg->nReadPos+1]==0xD8)
			if(mjpg->btCache[mjpg->nReadPos+2]==0xFF)
			{
				//printf("\rbegin recv pic time=%d   ",(int)Sys_GetTime());
				mjpg->isget=1;
				mjpg->nCache = nCucl-mjpg->nReadPos;
                if (mjpg->nCache>0) {
                    nCucl = mjpg->nCache;
                    memmove(mjpg->btCache,&mjpg->btCache[mjpg->nReadPos],mjpg->nCache);
                }
				else
                {
                    nCucl = mjpg->nCache=0;
                }
				mjpg->nReadPos =0;
			}
		}
	}

}


	
/* 循环执行 */
static void mjpg_thread(TagMjpg_Stream *mjpg)
{
	int nRet;
	char szTmp[65535];

	nRet=dhsRecv(mjpg->s,szTmp,sizeof(szTmp));
	if(nRet>0)
	{
        if(mjpg_check_authorized(mjpg,szTmp,nRet))
        {
			mjpg_stream_filter(mjpg,szTmp,nRet);
        }
	}
}
/* 执行:2 */
static int mjpg_connect(TagMjpg_Stream *mjpg,char *szIp,unsigned short wPort,const char *user,const char *pwd)
{
    mjpg->nCache=0;
	mjpg->nReadPos=0;
	mjpg->isget=0;
	mjpg->redraw=0;
    mjpg->bVerifyNum=0;

    
	if(!dhsInit(&mjpg->s,ZH_SOCK_TCP))return 1;
	if(!dhsConnect(mjpg->s,szIp,wPort,0))return 2;
    strcpy(mjpg->ip, szIp);
    mjpg->port=wPort;
	int nRecvBuf=64*1024;
	setsockopt(mjpg->s,SOL_SOCKET, SO_RCVBUF,(const char*)&nRecvBuf,sizeof(int));
    mjpg->bAuthorized=0;
    if (user) {
        strcpy(mjpg->user, user);
    }
    if (pwd) {
        strcpy(mjpg->pwd, pwd);
    }
	return 0;
}
    
/* 执行:3 */
static void mjpg_get_stream(TagMjpg_Stream *mjpg)
{
    char sendBuf[256];
    sprintf(sendBuf, "GET %s\r\n\r\n",CAMERA_PAGE_MJPG);
    dhsSend(mjpg->s,sendBuf,strlen(sendBuf));
}

/* 执行:1 */
static void mjpg_init(TagMjpg_Stream *mjpg)
{
    mjpg->bVerifyNum=0;
}

/* 退出时执行 */
static void mjpg_close(TagMjpg_Stream *mjpg)
{
    dhsClose(mjpg->s);
}


#ifdef __cplusplus
}
#endif
#define _ZH_MJPG_STREAM_
#endif
