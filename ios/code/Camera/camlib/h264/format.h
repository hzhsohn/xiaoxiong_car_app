//////////////////////////////////////////////////////////////////////
//sample:
//
////initizal function
//init_YCbCr2BGR_Tab();
//init_Clip_Tab();
//ConvertYCbCrToRGB24(szBuf,szBuf+(size),szBuf+size+size/4,buf,w,h);
//
/////////////////////////////////////////////////////////////////////



//BGR2YCbCr.h
#ifndef _BGR2YCBCR_H
#define _BGR2YCBCR_H

#ifdef __cplusplus
	extern "C"
	{
#endif


#ifdef _WIN32
#undef _W64
#define _W64 _w64
#else
#define _W64
#define __int64 int
#endif
		
#if defined(_WIN64)
    typedef __int64 LONG_PTR, *PLONG_PTR;
    typedef unsigned __int64 ULONG_PTR, *PULONG_PTR;

#else
    typedef _W64 long LONG_PTR, *PLONG_PTR;
    typedef _W64 unsigned long ULONG_PTR, *PULONG_PTR;
#endif

#define DWORD unsigned long
#define WORD unsigned short
#define BYTE unsigned char
typedef ULONG_PTR DWORD_PTR, *PDWORD_PTR;
#define LOBYTE(w)	((BYTE)((DWORD_PTR)(w) & 0xff))
#define MAKEWORD(a, b)      ((WORD)(((BYTE)((DWORD_PTR)(a) & 0xff)) | ((WORD)((BYTE)((DWORD_PTR)(b) & 0xff))) << 8))

//////////////////////////////////
//								//
//	YUV--RGB16--RGB24--RGB32	//
// 	(BRG--->RGB)				//
//////////////////////////////////
//C version
void init_YCbCr2BGR_Tab();
void init_Clip_Tab();

void ConvertYCbCrToRGB24(unsigned char *pY,unsigned char *pCb,unsigned char *pCr,unsigned char *pBGR,int width,int height);
void ConvertYCbCrToRGB24_Alter(unsigned char *pY,unsigned char *pCb,unsigned char *pCr,unsigned char *pBGR,int iWidth,int iHeight);
void ConvertYCbCrToRGB24_Mirror(unsigned char *pY,unsigned char *pCb,unsigned char *pCr,unsigned char *pBGR,int width,int height);

#ifdef __cplusplus
	}
#endif

#endif

