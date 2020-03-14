#pragma once

#ifndef _ZH_DAHUA_DVR_H__
#include "dh_socket.h"

#define ZH_DVR_CAMERA_SOCK				24
#define ZH_DVR_DEFAULT_CACHE			65535
#define ZH_DVR_TIMEOUT					10250
#define ZH_DVR_MAINBUF_SIZE				1024
#define ZH_DVR_SECONDBUF_SIZE			128
//+++++++++++++++++++++++++++++++++++++++++++++++++++
//+设备信息
typedef struct _TagDvrInfo{
	BYTE				szSerialNumber[48];					// 序列号
	//BYTE				btAlarmInPortNum;					// DVR报警输入个数
	//BYTE				btAlarmOutPortNum;					// DVR报警输出个数
	//BYTE				btDiskNum;							// DVR硬盘个数
	//BYTE				btDVRType;							// DVR类型, 见枚举DHDEV_DEVICE_TYPE
	BYTE				btChanNum;							// DVR通道个数
}TagDvrInfo;

//+++++++++++++++++++++++++++++++++++++++++++++++++++
typedef struct _TagCamaSock{
	SOCKET				socket;
	bool				bConnect;
	bool				bUsing;

    bool                bSetCtrl;

	//码流[0-3]
	char		cType;
	//每秒帧数
	char		cFrame;
	DWORD		dwFrameTime;
	DWORD		dwLastFrameTime;

	//网速慢处理
	DWORD		dwLTime;
	DWORD		dwReTime;

	//粘包数据处理
	bool		bBeginH264;
	int			nPackSize;
	int			nPackPos;
	BYTE		*btPack;
	bool		bDhav;

}TagCamaSock;

//+++++++++++++++++++++++++++++++++++++++++++++++++++
typedef struct _TagDvrSession{
	TagDvrInfo		dvrInfo;
	char			szIp[16];
	WORD			wPort;

	bool			bActive;
	DWORD			dwActiveTime;		//连接后发送消息用
	bool			bConnect;
	bool			bLogin;
	DWORD			dwBeginTime;		//大于ZH_DVR_TIMEOUT被默认超时

	//MainSock粘包数据处理
	SOCKET			MainSock;
	BYTE			*btMainBuf;
	char			cMainPos;
	bool			bThreadStaus;		//控制状态,true为可执行,false为无执行,

	//SecondSock粘包数据处理
	SOCKET			SecondSock;
	BYTE			*btSecondBuf;
	char			cSecondPos;

	TagCamaSock		CamaSock[ZH_DVR_CAMERA_SOCK];
	DWORD			dwKeepTime;
    DWORD           dwRecvKeepTime;
	char			cKeepValue; //区分是否第一次保活包
	int				nKey;		//通道匹配钥匙
	bool			bAutoGetDrive;

}TagDvrSession;

//云台控制命令
typedef enum _TDvrCtrl{
	ZH_DVR_CTRL_UP=0x0,
	ZH_DVR_CTRL_DOWN=0x1,
	ZH_DVR_CTRL_LEFT=0x2,
	ZH_DVR_CTRL_RIGHT=0x3,
	ZH_DVR_CTRL_LEFT_UP=0x20,
	ZH_DVR_CTRL_RIGHT_UP=0x21,
	ZH_DVR_CTRL_LEFT_DOWN=0x22,
	ZH_DVR_CTRL_RIGHT_DOWN=0x23,
	ZH_DVR_CTRL_ZOOM_INCR=0x04,//变倍+
	ZH_DVR_CTRL_ZOOM_DUCT=0x05,//变倍-
	ZH_DVR_CTRL_FOCAL_INCR=0x07,//变焦+
	ZH_DVR_CTRL_FOCAL_DUCT=0x08,//变焦-
	ZH_DVR_CTRL_APERTURE_INCR=0x09,//光圈或菜单+
	ZH_DVR_CTRL_APERTURE_DUCT=0x0A,//光圈或菜单-
    ZH_DVR_CTRL_PRESET_POINT=0x10,//预置点
    ZH_DVR_CTRL_PRESET_POINT_ADD=0x11,
    ZH_DVR_CTRL_PRESET_POINT_DELETE=0x12
}TDvrCtrl;

//数据类型
typedef enum _TDvrDataType{
	ZH_DVR_DATA_TYPE_H264,
	ZH_DVR_DATA_TYPE_G711A
}TDvrDataType;
//+++++++++++++++++++++++++++++++++++++++++++++++++++
#ifdef __cplusplus
extern "C"{
#endif

bool _ZH_DvrSockConnect(TagDvrSession*sion,SOCKET s);
int _ZH_RecvProc(TagDvrSession*sion,char*szRecv);
void _ZH_RecvCameraProc(TagDvrSession*sion,char*szRecv,int nRet,TagCamaSock*CamSock);
void _ZH_SecondThread(TagDvrSession*sion);
void _ZH_ResetConnect(TagDvrSession*sion,TagCamaSock*CamSock);

void ZH_DvrInit(TagDvrSession*sion);
//连接设备.最后一个参数为是否获取设备信息,例如多少路的DVR 
bool ZH_DvrConnect(char*szIp,WORD wPort,char*szUser,char*szPasswd,TagDvrSession*sion,bool bAutoGetDrive);
//正常退出设备
void ZH_DvrQuit(TagDvrSession*sion);
//断开所有连接并清空内存
void ZH_DisconnectAll(TagDvrSession*sion);

//控制模式的话显示是实时的
bool ZH_SetCtrl(TagDvrSession*sion,int pos,bool b);
    
//获取设备信息
void ZH_DvrGetDrive(TagDvrSession*sion);

//cType为码流设置[0-3]0为主码流.其它为辅助码流
bool ZH_DvrConnectCamera(TagDvrSession*sion,char cPos,char cType);
void ZH_DvrCloseCamera(TagDvrSession*sion,char cPos);
//ZH_DvrConnectOnceCamera不会同时打开其它通道的视频
bool ZH_DvrConnectOnceCamera(TagDvrSession*sion,char cPos,char cType);
void ZH_DvrCloseAllCamera(TagDvrSession*sion);

//非回调方式使用,提供在嵌入式里面使用,例如object C语言
/*返回值为处理后的结果
1 	没有账号
2	密码错误
3   账户锁定
4	登录成功
5	退出设备
6	断开连接
7	连接超时
8   获取视频数量
9   获取硬件序列号
*/
int ZH_MainThread(TagDvrSession*sion);

//调用Data前的循环 for(rSockPos=0;rSockPos<ZH_DVR_CAMERA_SOCK;rSockPos++)
bool ZH_DvrData(TagDvrSession*sion,short rPos,char*szData,int*nLen,TDvrDataType*type);


/*控制云台,(未停止控制前不断发送,停止后控制后要发一条speed为0的)
  操作是每隔0.3秒发送一条移动的消息,每调用此函数一次就会移动少少
	typedef struct _TagBtnState{
		bool bUp;
		bool bDown;
		bool bLeft;
		bool bRight;
		bool bLeftUp;
		bool bRightUp;
		bool bLeftDown;
		bool bRightDown;
	}TagBtnState;
*/
void ZH_DvrCtrl(TagDvrSession*sion,short rCameraPos,TDvrCtrl ctrl,short speed/*0-8 ,0为关闭*/);


#ifdef __cplusplus
}
#endif


#define _ZH_DAHUA_DVR_H__
#endif
