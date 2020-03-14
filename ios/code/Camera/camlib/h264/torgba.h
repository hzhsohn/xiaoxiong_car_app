#include "dsputil.h"
#include "h264.h"
#include "format.h"

#ifndef ZH_FFMPEG_TORGBA_H
#define ZH_FFMPEG_TORGBA_H

typedef struct _Tag_H264_MutDef
{
	int/* nFrame, nSize,*/ nPicture/*, nLen*/;
	AVCodec *Codec;
	AVCodecContext *AvCtex;
	AVFrame *Picture;
	
	/*DSPContext Dsp;*/
	H264Context *H264Ctex;
	MpegEncContext *MpegCtex;
}Tag_H264_MutDef;

typedef struct _Tag_H264_NorBuf
{
	int nSize;
	unsigned char *btBuf;
}Tag_H264_NorBuf;

typedef Tag_H264_NorBuf Tag_H264_MutBuf;

#ifdef __cplusplus
	extern "C"
	{
#endif

void _zh_Pgm_Save(unsigned char *buf,int wrap, int xsize,int ysize,unsigned char *out, int *out_size);
void _zh_InitH264Once(Tag_H264_MutDef*tH264);

/*
    返回处理后要删除的字节大小,即 in_size-=返回值
*/
int zhH264ToRGBStream(short rChinnel,unsigned char *in,int in_size,unsigned char*rgb_out,int *width,int *height);
int zhInitH264ToRgb(short rChinnelNum);
void zhH264ToRgbFree();
int zhResetH264ToRgb(short rChinnel);


#ifdef __cplusplus
	}
#endif

#endif