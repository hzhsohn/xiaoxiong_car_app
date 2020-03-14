#include "torgba.h"
#include <memory.h>

Tag_H264_MutDef *g_pDvrDecH264;
short g_rChinnelNum=0;

#define __GChinnel_ g_pDvrDecH264[rChinnel]

void _zh_InitH264Once(Tag_H264_MutDef*tH264)
{
	//h264
	extern AVCodec h264_decoder;

	tH264->Codec = &h264_decoder;
    tH264->AvCtex= NULL;   

    tH264->AvCtex= avcodec_alloc_context();
    tH264->Picture= avcodec_alloc_frame();

	/* we do not send complete frames */
	if(tH264->Codec->capabilities&CODEC_CAP_TRUNCATED)
        tH264->AvCtex->flags|= CODEC_FLAG_TRUNCATED;

	if (avcodec_open(tH264->AvCtex,tH264->Codec) < 0) {
        //printf("could not open codec\n");
        return;
    }

	tH264->H264Ctex = tH264->AvCtex->priv_data;
	tH264->MpegCtex = &tH264->H264Ctex->s;
	tH264->MpegCtex->dsp.idct_permutation_type =1;
	dsputil_init(&tH264->MpegCtex->dsp, tH264->AvCtex);
}

int zhInitH264ToRgb(short rChinnelNum)
{
	int i;

	g_rChinnelNum=rChinnelNum;
	/* find the mpeg1 video decoder */
	avcodec_init();

	g_pDvrDecH264=(Tag_H264_MutDef*)calloc(rChinnelNum,sizeof(Tag_H264_MutDef));
	for(i=0;i<rChinnelNum;i++)
	{
		_zh_InitH264Once(&g_pDvrDecH264[i]);
	}
	//yuv
	init_YCbCr2BGR_Tab();
	init_Clip_Tab();
	return 0;
}

void zhH264ToRgbFree()
{
	short rChinnel;
	for(rChinnel=0;rChinnel<g_rChinnelNum;rChinnel++)
	{
		if(__GChinnel_.Picture)
		{
			free(__GChinnel_.Picture); 
		}
		__GChinnel_.Picture=NULL;
		// Close the codec   
		if(__GChinnel_.AvCtex)
			avcodec_close(__GChinnel_.AvCtex);
		if(__GChinnel_.AvCtex)
			av_free(__GChinnel_.AvCtex);
			__GChinnel_.AvCtex=NULL;
		
	}
}

int zhResetH264ToRgb(short rChinnel)
{
	av_free(__GChinnel_.Picture);  
	avcodec_close(__GChinnel_.AvCtex);  
	av_free(__GChinnel_.AvCtex);
	_zh_InitH264Once(&__GChinnel_);
    return 0;
}

//decode stream
int zhH264ToRGBStream(short rChinnel,unsigned char *in,int in_size,unsigned char*rgb_out,int *width,int *height)
{
	uint8_t *btYuvBuf;
	int len=0;
	int nXY,nV,out_size;

	out_size=0;

	if ((in_size) > 0){
	
		len = avcodec_decode_video(__GChinnel_.AvCtex, __GChinnel_.Picture, &__GChinnel_.nPicture,
								   in, in_size);
		if (len < 0) {
			 len=0;
		}
		if (__GChinnel_.nPicture) {
			*width=__GChinnel_.AvCtex->width;
			*height=__GChinnel_.AvCtex->height;
			nXY=__GChinnel_.AvCtex->width*__GChinnel_.AvCtex->height;	
			
			btYuvBuf=malloc(nXY*1.5);

			_zh_Pgm_Save(__GChinnel_.Picture->data[0], __GChinnel_.Picture->linesize[0],
							__GChinnel_.AvCtex->width, __GChinnel_.AvCtex->height,btYuvBuf,&out_size);
			_zh_Pgm_Save(__GChinnel_.Picture->data[1], __GChinnel_.Picture->linesize[1],
							__GChinnel_.AvCtex->width>>1, __GChinnel_.AvCtex->height>>1,btYuvBuf,&out_size);
			_zh_Pgm_Save(__GChinnel_.Picture->data[2], __GChinnel_.Picture->linesize[2],
							__GChinnel_.AvCtex->width>>1, __GChinnel_.AvCtex->height>>1,btYuvBuf,&out_size);

			nV=(int)(nXY*1.25);
			ConvertYCbCrToRGB24(btYuvBuf/*Y*/,btYuvBuf+nV/*V*/,btYuvBuf+nXY/*U*/,rgb_out/*BGR*/,*width,*height);
			free(btYuvBuf);
		}
	}

	if(!rgb_out)
	{
		rgb_out=NULL;
		len=0;
	}

	return len;
}

void _zh_Pgm_Save(unsigned char *buf,int wrap, int xsize,int ysize,unsigned char *out, int *out_size)
{
	int i=0;

	if(buf)
	if(xsize>0)
	for(i=0;i<ysize;i++)
	{
		memmove(out+(*out_size),buf + i * wrap,xsize);
		(*out_size)+=xsize;
	}
}
