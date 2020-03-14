#include "dahua_dvr.h"

#ifndef _WIN32
#include <sys/socket.h> 
#include <sys/ioctl.h> 
#include <net/if.h> 
#include <netdb.h>
#include <string.h>
#include <errno.h>
#define h_addr h_addr_list[0]
#endif

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//+发送消息的标识
char DH_LOGIN[]={0xA0,0x00,0x00,0x60,0x00,0x00,0x00,0x00,0x61,0x64,0x6D,0x69,0x6E,0x00,0x00,0x00,0x61,0x64,0x6D,0x69,0x6E,0x00,0x00,0x00,0x04,0x01,0x00,0x00,0x00,0x00,0xA1,0xAA };
char DH_SECOND[]={0xF1,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xCF,0x07,0x00,0x00,0x02,0x05,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};
char DH_KEEP_SEND[] ={0xA1,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00}; 

//退出,收到退出设备的回复消息就结束掉连接
char DH_QUIT_DRIVE[]={0x0A,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x12,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};


char DH_GET_DRIVE1[]={0xA4,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};
char DH_GET_DRIVE2[]={0xA4,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x07,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};
char DH_GET_DRIVE3[]={0xA4,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};

char DH_OPEN_CAMERA_MAIN[]={0x11,0x00,0x00,0x00,0x10,0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};
char DH_OPEN_CAMERA_NEW[]={0xF1,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xCF,0x07,0x00,0x00,0x01,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};

//云台控制
char DH_CTRL_CAMERA[]={0x12,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x02,0x00,0x00,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//+
//+处理DVR的二进制传输消息函数
//+
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

bool _ZH_DvrSockConnect(TagDvrSession*sion,SOCKET s)
{
	return dhsConnect(s,sion->szIp,sion->wPort,0);
}

void ZH_DisconnectAll(TagDvrSession*sion)
{
	int i;

	for(i=0;i<ZH_DVR_CAMERA_SOCK;i++)
	if(true==sion->CamaSock[i].bConnect)
	{
		dhsClose(sion->CamaSock[i].socket);
		sion->CamaSock[i].bUsing=false;
		sion->CamaSock[i].bConnect=false;
		sion->CamaSock[i].bDhav=false;
		sion->CamaSock[i].nPackPos=0;
		sion->CamaSock[i].nPackSize=0;
		if(sion->CamaSock[i].btPack)
		{
			free(sion->CamaSock[i].btPack);
			sion->CamaSock[i].btPack=NULL;
		}
	}
	if(sion->bConnect)
	{
		dhsClose(sion->MainSock);
		free(sion->btMainBuf);
		sion->btMainBuf=NULL;
		dhsClose(sion->SecondSock);
		free(sion->btSecondBuf);
		sion->btSecondBuf=NULL;
	}
	sion->bLogin=false;
	sion->bThreadStaus=false;
	sion->dwActiveTime=0;
	printf("Disconnect All Socket!!\n");
}

bool ZH_SetCtrl(TagDvrSession*sion,int pos,bool b)
{
    if(sion)
    {
        sion->CamaSock[pos].bSetCtrl=b;
        return true;
    }
    else
    {
        return false;
    }
}

int _ZH_RecvProc(TagDvrSession*sion,char*szRecv)
{
	int nType;
	short *prTmp;
	char *pcTmp;
	int nResult=0;

	memcpy(&nType,&szRecv[0],sizeof(int));
	switch(nType)
	{
		case 0x680001B0://新版协议登录结果
			prTmp=(short *)&szRecv[8];
				sion->dwActiveTime=0;
				switch(*prTmp)
				{
				case 0x0101://没有账号
						//PRINTF("not find account.!");
						nResult=1;
					break;
				case 0x0001://密码错误
						//PRINTF("password error.!");
						nResult=2;
					break;
				case 0x0401://账户锁定
						//PRINTF("account lock.!");
						nResult=3;
					break;
				case 0x0601://同一连接重复登录
						//PRINTF("re login.!");
						nResult=3;
					break;
				case 0x0800://登录成功
						//PRINTF("login success.!");
						nResult=4;
						memcpy(&sion->nKey,&szRecv[16],sizeof(int));
						memcpy(&DH_SECOND[8],&sion->nKey,sizeof(int));
						dhsSend(sion->SecondSock,DH_SECOND,sizeof(DH_SECOND));
					break;
				default:
						nResult=3;
					break;
				}
		break;
		case 0x580000B0://登录结果 连接1
				prTmp=(short *)&szRecv[8];
				sion->dwActiveTime=0;
				switch(*prTmp)
				{
				case 0x0101://没有账号
						//PRINTF("not find account.!");
						nResult=1;
					break;
				case 0x0001://密码错误
						//PRINTF("password error.!");
						nResult=2;
					break;
				case 0x0401://账户锁定
						//PRINTF("account lock.!");
						nResult=3;
					break;
				case 0x0601://同一连接重复登录
						//PRINTF("re login.!");
						nResult=3;
					break;
				case 0x0800://登录成功
						//PRINTF("login success.!");
						nResult=4;
						memcpy(&sion->nKey,&szRecv[16],sizeof(int));
						memcpy(&DH_SECOND[8],&sion->nKey,sizeof(int));
						dhsSend(sion->SecondSock,DH_SECOND,sizeof(DH_SECOND));
					break;
				default:
						nResult=3;
					break;
				}
			break;
		case 0x580000F1://未知 连接2
						if(false==sion->bLogin)
						{
							sion->bLogin=true;
							sion->dwKeepTime=0;
							sion->cKeepValue=1;//初始值为1
						}
			break;
		case 0x000000B1://未知 连接2
			break;
		case 0x580000B1://保活包 连接1
				if(1==sion->cKeepValue)
				{
					sion->cKeepValue++;
					//是否登录后自动获取设备信息
					if(sion->bAutoGetDrive)
                    {ZH_DvrGetDrive(sion);}
				}
                sion->dwRecvKeepTime=Sys_GetTime();
			break;
		case 0x580000B4://DVR设备信息 连接1
				pcTmp=&szRecv[8];
				switch(*pcTmp)
				{
				case 0x01:
						memcpy(&sion->dvrInfo.btChanNum,&szRecv[34],1);
						//获取0x07设备信息
						dhsSend(sion->MainSock,DH_GET_DRIVE2,sizeof(DH_GET_DRIVE2));
                        nResult=8;
					break;
				case 0x07:
						memcpy(sion->dvrInfo.szSerialNumber,&szRecv[32],21);
						//获取0x02设备信息
						//ZH_SockSend(sion->MainSock,DH_GET_DRIVE3,sizeof(DH_GET_DRIVE3));
                        nResult=9;
					break;
				case 0x02:
						//未知设备信息
					break;
				}
			break;
		case 0x5800000B://退出设备 连接1
				ZH_DisconnectAll(sion);
				nResult=5;
				sion->bConnect=false;
			break;
	}
	
	return nResult;
}

void _ZH_RecvCameraProc(TagDvrSession*sion,char*szRecv,int nRet,TagCamaSock*CamSock)
{
	int nType,i;
	
	if((CamSock->nPackPos+nRet)>ZH_DVR_DEFAULT_CACHE)
	{
		CamSock->nPackPos=0;
		printf("Pack Error Reset\n");
		_ZH_ResetConnect(sion,CamSock);
		return;
	}

	memcpy(&CamSock->btPack[CamSock->nPackPos],szRecv,nRet);
	CamSock->nPackPos+=nRet;

	if(false==CamSock->bBeginH264)
	{
		if(CamSock->nPackPos>=32)
		{
			memcpy(&nType,&CamSock->btPack[0],sizeof(int));

			switch(nType)
			{
			case 0x580000F1://开始标记
					CamSock->nPackPos=0;
					CamSock->nPackSize=0;
				return;
			case 0x000000BC://数据包
				return;
			default:
					//抛弃不知道什么东东的数据
					//PRINTF("lost data");
					for(i=0;(i < CamSock->nPackPos)&&((int)(i+sizeof(int))<=CamSock->nPackPos);i++)
					{
						memcpy(&nType,&CamSock->btPack[i],sizeof(int));
						if(0x000000BC==nType)
						{
							CamSock->nPackPos-=i;
							memmove(&CamSock->btPack[0],&CamSock->btPack[i],CamSock->nPackPos);
							return;
						}
					}
					CamSock->nPackPos-=i;
					memmove(&CamSock->btPack[0],&CamSock->btPack[i],CamSock->nPackPos);
				return;
			}
		}
	}
}

//+++初始化+++
void ZH_DvrInit(TagDvrSession*sion)
{
	if(!dhsInit(&sion->MainSock,ZH_SOCK_TCP))return;
	dhsSetNonBlocking(sion->MainSock,true);
	if(!dhsInit(&sion->SecondSock,ZH_SOCK_TCP))return;
	dhsSetNonBlocking(sion->SecondSock,true);
	sion->bLogin=false;
	sion->bConnect=false;
	sion->bThreadStaus=false;
	sion->dwActiveTime=0;

}

void ZH_DvrGetDrive(TagDvrSession*sion)
{
	dhsSend(sion->MainSock,DH_GET_DRIVE1,sizeof(DH_GET_DRIVE1));
}

bool ZH_DvrConnect(char*szIp,WORD wPort,char*szUser,char*szPasswd,TagDvrSession*sion,bool bAutoGetDrive)
{
	int i;

	//登录信息修改
	memset(&DH_LOGIN[8],0,8);//重置登录用户
	memset(&DH_LOGIN[16],0,8);//重置登录密码
	memcpy(&DH_LOGIN[8],szUser,strlen(szUser));
	memcpy(&DH_LOGIN[16],szPasswd,strlen(szPasswd));

	for(i=0;i<ZH_DVR_CAMERA_SOCK;i++)
	{
		sion->CamaSock[i].bUsing=false;
		sion->CamaSock[i].bConnect=false;
		sion->CamaSock[i].bDhav=false;
		sion->CamaSock[i].nPackPos=0;
		sion->CamaSock[i].nPackSize=0;
		if(sion->CamaSock[i].btPack)
		{
			free(sion->CamaSock[i].btPack);
			sion->CamaSock[i].btPack=NULL;
		}
	}

	strcpy(sion->szIp,szIp);
	sion->wPort=wPort;
	_ZH_DvrSockConnect(sion,sion->MainSock);
	_ZH_DvrSockConnect(sion,sion->SecondSock);
	sion->cMainPos=0;
	if(sion->btMainBuf)
		free(sion->btMainBuf);
		sion->btMainBuf=NULL;
	sion->btMainBuf=(BYTE*)malloc(ZH_DVR_MAINBUF_SIZE);
	sion->cSecondPos=0;
	if(sion->btSecondBuf)
		free(sion->btSecondBuf);
		sion->btSecondBuf=NULL;
	sion->btSecondBuf=(BYTE*)malloc(ZH_DVR_SECONDBUF_SIZE);
	sion->bAutoGetDrive=bAutoGetDrive;

	sion->bActive=true;
	sion->dwActiveTime=Sys_GetTime();
	sion->bConnect=true;
	sion->dwBeginTime=Sys_GetTime();
	sion->bThreadStaus=true;

    sion->dwRecvKeepTime=Sys_GetTime();

	return true;
}

//打开摄像头
bool ZH_DvrConnectCamera(TagDvrSession*sion,char cPos,char cType)
{
	char i;

	if(!sion->bLogin)return false;

    ///////////////////////////////////////
	{
		dhsInit(&sion->CamaSock[cPos].socket,ZH_SOCK_TCP);
		dhsSetNonBlocking(sion->CamaSock[cPos].socket,false);
		sion->CamaSock[cPos].bConnect=true;
		sion->CamaSock[cPos].bDhav=false;
		sion->CamaSock[cPos].cType=cType;
		if(sion->CamaSock[cPos].btPack)
		{
			free(sion->CamaSock[cPos].btPack);
			sion->CamaSock[cPos].btPack=NULL;
		}
		sion->CamaSock[cPos].btPack=(BYTE*)malloc(ZH_DVR_DEFAULT_CACHE);
		if(_ZH_DvrSockConnect(sion,sion->CamaSock[cPos].socket))
		{
			dhsSetNonBlocking(sion->CamaSock[cPos].socket,true);
		}
		//Sys_Sleep(200);

		//修改SOCKET缓冲区大小
		dhsSetSendBufferSize(sion->CamaSock[cPos].socket,1024*80);
		dhsSetRecvBufferSize(sion->CamaSock[cPos].socket,1024*80);
	}

    sion->CamaSock[cPos].bSetCtrl=false;
	sion->CamaSock[cPos].bUsing=true;
	sion->CamaSock[cPos].bBeginH264=false;
	sion->CamaSock[cPos].nPackPos=0;
	sion->CamaSock[cPos].nPackSize=0;
	sion->CamaSock[cPos].dwLTime=Sys_GetTime();
	sion->CamaSock[cPos].dwReTime=Sys_GetTime();
	
	//主SOCKET信息
	memset(&DH_OPEN_CAMERA_MAIN[8],0,16);
	for(i=0;i<ZH_DVR_CAMERA_SOCK;i++)
	{
		if(true==sion->CamaSock[i].bUsing)
		{
			DH_OPEN_CAMERA_MAIN[8+i]=1;
			DH_OPEN_CAMERA_MAIN[32+i]=cType;
		}
	}	
	dhsSend(sion->MainSock,DH_OPEN_CAMERA_MAIN,sizeof(DH_OPEN_CAMERA_MAIN));
	//新SOCKET的信息
	memcpy(&DH_OPEN_CAMERA_NEW[8],&sion->nKey,sizeof(int));
	DH_OPEN_CAMERA_NEW[13]=cPos+1;
	dhsSend(sion->CamaSock[cPos].socket,DH_OPEN_CAMERA_NEW,sizeof(DH_OPEN_CAMERA_NEW));
	printf("Open Camera , Pos=%d\n",cPos);
	return true;
}

bool ZH_DvrConnectOnceCamera(TagDvrSession*sion,char cPos,char cType)
{
	short i;

	if(!sion->bLogin)return false;

	{
		dhsInit(&sion->CamaSock[cPos].socket,ZH_SOCK_TCP);
		dhsSetNonBlocking(sion->CamaSock[cPos].socket,false);
		sion->CamaSock[cPos].bConnect=true;
		sion->CamaSock[cPos].bDhav=false;
		sion->CamaSock[cPos].cType=cType;
		if(sion->CamaSock[cPos].btPack)
		{
			free(sion->CamaSock[cPos].btPack);
			sion->CamaSock[cPos].btPack=NULL;
		}
		sion->CamaSock[cPos].btPack=(BYTE*)malloc(ZH_DVR_DEFAULT_CACHE);
		if(_ZH_DvrSockConnect(sion,sion->CamaSock[cPos].socket))
		{
			dhsSetNonBlocking(sion->CamaSock[cPos].socket,true);
		}
		//Sys_Sleep(200);
	}

	for(i=0;i<ZH_DVR_CAMERA_SOCK;i++)
		sion->CamaSock[i].bUsing=false;

    sion->CamaSock[cPos].bSetCtrl=false;
	sion->CamaSock[cPos].bUsing=true;
	sion->CamaSock[cPos].bBeginH264=false;	
	sion->CamaSock[cPos].nPackPos=0;
	sion->CamaSock[cPos].nPackSize=0;
	sion->CamaSock[cPos].dwLTime=Sys_GetTime();
	sion->CamaSock[cPos].dwReTime=Sys_GetTime();
	//主SOCKET信息
	memset(&DH_OPEN_CAMERA_MAIN[8],0,16);
	DH_OPEN_CAMERA_MAIN[8+cPos]=1;
	DH_OPEN_CAMERA_MAIN[32+cPos]=cType;
	
	dhsSend(sion->MainSock,DH_OPEN_CAMERA_MAIN,sizeof(DH_OPEN_CAMERA_MAIN));
	//新SOCKET的信息
	memcpy(&DH_OPEN_CAMERA_NEW[8],&sion->nKey,sizeof(int));
	DH_OPEN_CAMERA_NEW[13]=cPos+1;
	dhsSend(sion->CamaSock[cPos].socket,DH_OPEN_CAMERA_NEW,sizeof(DH_OPEN_CAMERA_NEW));
	printf("Open Once Camera , Pos=%d\n",cPos);
	return true;
}

//关闭摄像头
void ZH_DvrCloseCamera(TagDvrSession*sion,char cPos)
{
	char i;

	if(!sion->bLogin)return;
	if(!sion->bConnect)return;
	//不关闭SOCKET
	sion->CamaSock[cPos].bUsing=false;
	sion->CamaSock[cPos].bBeginH264=false;
	sion->CamaSock[cPos].bDhav=false;
	sion->CamaSock[cPos].nPackPos=0;
	//主SOCKET信息
	memset(&DH_OPEN_CAMERA_MAIN[8],0,16);
	for(i=0;i<ZH_DVR_CAMERA_SOCK;i++)
	{
		if(true==sion->CamaSock[i].bUsing)
		DH_OPEN_CAMERA_MAIN[8+i]=1;
	}
	DH_OPEN_CAMERA_MAIN[8+cPos]=0;
	dhsSend(sion->MainSock,DH_OPEN_CAMERA_MAIN,sizeof(DH_OPEN_CAMERA_MAIN));
	printf("Close Once Camera , Pos=%d\n",cPos);
}

void ZH_DvrCloseAllCamera(TagDvrSession*sion)
{
	char i;

	if(!sion->bLogin)return;
	memset(&DH_OPEN_CAMERA_MAIN[8],0,16);
	for(i=0;i<ZH_DVR_CAMERA_SOCK;i++)
	{
		sion->CamaSock[i].bUsing=false;
	}
	dhsSend(sion->MainSock,DH_OPEN_CAMERA_MAIN,sizeof(DH_OPEN_CAMERA_MAIN));
	printf("Close All Camera\n");
}

//非回调方式使用,提供在嵌入式里面使用,例如object C语言
int ZH_MainThread(TagDvrSession*sion)
{
	DWORD dwTmp;
	char szBuf[512];
	int nRecv=0;
	int nResult=0;

	if(false==sion->bThreadStaus){
		//nResult=-1;
		//goto nnc;
		return -1;
	}

	//主Socket
	nRecv=dhsRecv(sion->MainSock,szBuf,sizeof(szBuf));
	if(nRecv>0 && nRecv<ZH_DVR_MAINBUF_SIZE)
	{
		//解决粘包
		memcpy(&sion->btMainBuf[sion->cMainPos],szBuf,nRecv);
		sion->cMainPos+=nRecv;
		if(sion->cMainPos>=32)
		{
			nResult=_ZH_RecvProc(sion,(char*)sion->btMainBuf);
			//不取用这方法原因是有些消息长度不明确
			//sion->cMainPos-=32;
			//memmove(sion->btMainBuf,&sion->btMainBuf[32],sion->cMainPos-rRecv);
			sion->cMainPos=0;
		}
	}
	else if(nRecv==-1)
	{
		//Socket断开连接
		nResult=6;
		goto nnc;
	}
	
	//保活包
	dwTmp=Sys_GetTime();
	if(sion->bLogin)
	{
	
		if(dwTmp-sion->dwKeepTime>8000)
		{
			sion->dwKeepTime=Sys_GetTime();
			dhsSend(sion->MainSock,DH_KEEP_SEND,sizeof(DH_KEEP_SEND));
		}
        //17秒内都没有收到返回的保活包视为断开
        if(dwTmp-sion->dwRecvKeepTime>17000)
		{
			//Socket断开连接
            nResult=6;
            ZH_DisconnectAll(sion);
            goto nnc;
		}
	}
	else//超时
	{
		if(sion->bConnect)
		{
			//发送登录消息
			if(sion->dwActiveTime>0)
			{
				if(sion->bActive)
					nRecv=300;
				else
					nRecv=3000;
				if((int)(dwTmp-sion->dwActiveTime)>nRecv)
				{
					sion->bActive=false;
					sion->dwActiveTime=Sys_GetTime();
					dhsSend(sion->MainSock,DH_LOGIN,sizeof(DH_LOGIN));
				}
			}
			
			if(dhsHasExcept(sion->MainSock) || dwTmp-sion->dwBeginTime>ZH_DVR_TIMEOUT)
			{
				nResult=7;
				ZH_DisconnectAll(sion);				
				goto nnc;
			}
		}
	}
	_ZH_SecondThread(sion);
nnc:
	return nResult;
}

void _ZH_SecondThread(TagDvrSession*sion)
{
	char szBuf[128];
	int rRecv=0;

	//副Socket
	rRecv=dhsRecv(sion->SecondSock,szBuf,sizeof(szBuf));
	if(rRecv>0)
	{
		//解决粘包
		memcpy(&sion->btSecondBuf[sion->cSecondPos],szBuf,rRecv);
		sion->cSecondPos+=rRecv;
		if(sion->cSecondPos>=32)
		{
			_ZH_RecvProc(sion,(char*)sion->btSecondBuf);
			
			sion->cSecondPos-=32;
			if(sion->cSecondPos<0)sion->cSecondPos=0;
			memmove(sion->btSecondBuf,&sion->btSecondBuf[32],sion->cSecondPos);
		}
	}		
	else if(rRecv==-1)
	{
		//Socket断开连接
		ZH_DisconnectAll(sion);
	}

	//return rRecv;
}

//重置连接 与 ZH_DvrData函数里的
//if(false==sion->CamaSock[rSockPos].bLTimeUsing)有关
void _ZH_ResetConnect(TagDvrSession*sion,TagCamaSock*CamSock)
{
	char i;
	DWORD dwTmp;
	
	if(!sion->bLogin)return;
	
	dwTmp=Sys_GetTime();
	dwTmp-=CamSock->dwReTime;
	if(dwTmp>2000)
	{
		CamSock->bUsing=true;
		CamSock->bBeginH264=false;
		CamSock->nPackPos=0;
		CamSock->nPackSize=0;

		//主SOCKET信息
		memset(&DH_OPEN_CAMERA_MAIN[8],0,16);
		for(i=0;i<ZH_DVR_CAMERA_SOCK;i++)
		{
			if(true==sion->CamaSock[i].bUsing)
			{
				DH_OPEN_CAMERA_MAIN[8+i]=1;
				DH_OPEN_CAMERA_MAIN[32+i]=sion->CamaSock[i].cType;
			}
		}	
		dhsSend(sion->MainSock,DH_OPEN_CAMERA_MAIN,sizeof(DH_OPEN_CAMERA_MAIN));

		printf("Reset ZH_DvrConnectCamera\n");
		CamSock->dwLTime=CamSock->dwReTime=Sys_GetTime();
	}
}

bool ZH_DvrData(TagDvrSession*sion,short rPos,char*szData,int*nLen,TDvrDataType*type)
{
	bool bRet=false;
	DWORD dwTmp=0;
	int nRecvLen;
	char szBuf[65535];	

	*nLen=0;
	*szData=0;

	if(!sion->CamaSock[rPos].bUsing)return false;

	//如果超过两秒间隔重新发打开视频信息
	
	dwTmp=Sys_GetTime();
	if(dwTmp-sion->CamaSock[rPos].dwLTime>2000)
	{
		printf("Reset ZH_DvrConnectCamera\n");
		ZH_DvrConnectCamera(sion,rPos,sion->CamaSock[rPos].cType);
		sion->CamaSock[rPos].dwLTime = sion->CamaSock[rPos].dwReTime = Sys_GetTime();
		return false;
	}
	
	if(true==sion->CamaSock[rPos].bConnect)
	{
		nRecvLen=dhsRecv(sion->CamaSock[rPos].socket,szBuf,sizeof(szBuf));
		if(nRecvLen>0)
		{
			_ZH_RecvCameraProc(sion,szBuf,nRecvLen,&sion->CamaSock[rPos]);
		}
	}

	//处理摄像头数据
	if(false==sion->CamaSock[rPos].bBeginH264)
	{
		if(0==sion->CamaSock[rPos].nPackPos)return false;
		//获取包大小
		if(sion->CamaSock[rPos].nPackPos>=32)
		{
			memcpy(&sion->CamaSock[rPos].nPackSize,&sion->CamaSock[rPos].btPack[4],sizeof(int));
			sion->CamaSock[rPos].nPackPos-=32;
			if(sion->CamaSock[rPos].nPackPos>0 && (sion->CamaSock[rPos].nPackPos+32) < ZH_DVR_DEFAULT_CACHE)
			{
				memmove(&sion->CamaSock[rPos].btPack[0],&sion->CamaSock[rPos].btPack[32],sion->CamaSock[rPos].nPackPos);
				//Sys_print16(32,sion->CamaSock[rPos].btPack);
			}
			sion->CamaSock[rPos].bBeginH264=true;
		}
		else
			sion->CamaSock[rPos].nPackSize=0;
	}
	//判断数据
	if(sion->CamaSock[rPos].nPackPos>ZH_DVR_DEFAULT_CACHE || sion->CamaSock[rPos].nPackPos<0 ||
	   sion->CamaSock[rPos].nPackSize<0 || sion->CamaSock[rPos].nPackSize>ZH_DVR_DEFAULT_CACHE)
		{
			printf("Error CamaSock[%d].nPackPos=%d , CamaSock[%d].nPackSize=%d\n",
					rPos, sion->CamaSock[rPos].nPackPos,
					rPos, sion->CamaSock[rPos].nPackSize);
			sion->CamaSock[rPos].nPackPos=0;
			sion->CamaSock[rPos].nPackSize=0;
			_ZH_ResetConnect(sion,&sion->CamaSock[rPos]);
			return false;
		}
	if(sion->CamaSock[rPos].nPackSize>0 && sion->CamaSock[rPos].nPackPos>=sion->CamaSock[rPos].nPackSize)
       {
                //做视频关键帧处理
                 if(!sion->CamaSock[rPos].bDhav)
                 {
                     //44 48 41 56 FD
                     if(0x44==sion->CamaSock[rPos].btPack[0] &&
                     0x48==sion->CamaSock[rPos].btPack[1] &&
                     0x41==sion->CamaSock[rPos].btPack[2] &&
                     0x56==sion->CamaSock[rPos].btPack[3] && 
                     0xFD==sion->CamaSock[rPos].btPack[4])
                     {
                     sion->CamaSock[rPos].bDhav=true;
                     memcpy(&sion->CamaSock[rPos].cFrame,&sion->CamaSock[rPos].btPack[27],1);
                     //计算时间
                     if(sion->CamaSock[rPos].bSetCtrl)
                         {
                             //实时显示
                             sion->CamaSock[rPos].dwFrameTime=4;
                         }
                         else
                         {
                             sion->CamaSock[rPos].dwFrameTime=1000/sion->CamaSock[rPos].cFrame;
                         }
						sion->CamaSock[rPos].dwLastFrameTime=Sys_GetTime();
						//Sys_print16(30,sion->CamaSock[rSockPos].btPack);
                     }
                 }

				if(sion->CamaSock[rPos].bDhav)
				{
                    if(0x44==sion->CamaSock[rPos].btPack[0] &&
                        0x48==sion->CamaSock[rPos].btPack[1] &&
                        0x41==sion->CamaSock[rPos].btPack[2] &&
                        0x56==sion->CamaSock[rPos].btPack[3])
                    {
                        //printf(">>*nLen=%d\n",*nLen);
                        if(0xFD==sion->CamaSock[rPos].btPack[4])
                        {
                            if(sion->CamaSock[rPos].nPackSize>37)
                            {
                                if(szData)
                                {
                                    //进行H264对应分解 37 位置00001
									//P帧
									(*nLen)=sion->CamaSock[rPos].nPackSize;
                                    (*nLen)-=37;//未知的开始包头
									(*nLen)-=8;//"dhav"+4个校检字节
                                    memcpy(szData,&sion->CamaSock[rPos].btPack[37],(*nLen));
									*type=ZH_DVR_DATA_TYPE_H264;
                                }
                            }
                        }
                        else if(0xFC==sion->CamaSock[rPos].btPack[4] )
                        {
                            if(sion->CamaSock[rPos].nPackSize>29)
                            {
                                if(szData)
                                {
                                    //进行H264对应分解
									//I,B帧
									(*nLen)=sion->CamaSock[rPos].nPackSize;
                                    (*nLen)-=29;
									(*nLen)-=8;//"dhav"+4个校检字节
                                    memcpy(szData,&sion->CamaSock[rPos].btPack[29],(*nLen));
									*type=ZH_DVR_DATA_TYPE_H264;
                                }
                            }
                        }
						else if(0xF0==sion->CamaSock[rPos].btPack[4] )
						{
							//音频数据
							(*nLen)=sion->CamaSock[rPos].nPackSize;
							memcpy(szData,&sion->CamaSock[rPos].btPack[29],(*nLen));
							*type=ZH_DVR_DATA_TYPE_G711A;
						}
                        //Sys_print16(60,sion->CamaSock[rPos].btPack);
                        //printf(">*nLen=%d\n",*nLen);
                    }
				}
				
				sion->CamaSock[rPos].dwLTime=Sys_GetTime();
				bRet=true;
				sion->CamaSock[rPos].bBeginH264=false;
				sion->CamaSock[rPos].nPackPos-=sion->CamaSock[rPos].nPackSize;

				//将数据移前
				if(sion->CamaSock[rPos].nPackPos>0)
					memmove(&sion->CamaSock[rPos].btPack[0],&sion->CamaSock[rPos].btPack[sion->CamaSock[rPos].nPackSize],sion->CamaSock[rPos].nPackPos);
				else
					sion->CamaSock[rPos].nPackPos=0;
		}
	else
	{
	
	}
	return bRet;
}

void ZH_DvrQuit(TagDvrSession*sion)
{

    if(sion->bLogin)
    {
        ZH_DisconnectAll(sion);
    }
    else
    {
        //正常退出
        //dhsSend(sion->MainSock,DH_QUIT_DRIVE,sizeof(DH_QUIT_DRIVE));
    }
}

void ZH_DvrCtrl(TagDvrSession*sion,short rCameraPos,TDvrCtrl ctrl,short speed/*1-8*/)
{
	if(!sion->bLogin)return;

	if(speed>0)
	{
		DH_CTRL_CAMERA[8]=1;//停止位		
		DH_CTRL_CAMERA[9]=(char)rCameraPos;//通道		
		DH_CTRL_CAMERA[10]=(char)ctrl;//操作
		switch(ctrl)
		{
			ZH_DVR_CTRL_UP:
			ZH_DVR_CTRL_DOWN:
			ZH_DVR_CTRL_LEFT:
			ZH_DVR_CTRL_RIGHT:
							DH_CTRL_CAMERA[11]=0;//速度
							DH_CTRL_CAMERA[12]=(char)speed;//速度
						break;
			ZH_DVR_CTRL_LEFT_UP:
			ZH_DVR_CTRL_RIGHT_UP:
			ZH_DVR_CTRL_LEFT_DOWN:
			ZH_DVR_CTRL_RIGHT_DOWN:
							DH_CTRL_CAMERA[11]=(char)speed;//速度
							DH_CTRL_CAMERA[12]=(char)speed;//速度
						break;
		}
		memset(&DH_CTRL_CAMERA[13],0,19);//复值
	}
	else
	{
		DH_CTRL_CAMERA[8]=1;//停止位		
		DH_CTRL_CAMERA[9]=(char)rCameraPos;//通道		
		DH_CTRL_CAMERA[10]=(char)ctrl;//操作
		DH_CTRL_CAMERA[11]=0;//速度
		DH_CTRL_CAMERA[12]=0;//速度
		memset(&DH_CTRL_CAMERA[13],8,19);//复值
	}
	dhsSend(sion->MainSock,DH_CTRL_CAMERA,sizeof(DH_CTRL_CAMERA));
}
