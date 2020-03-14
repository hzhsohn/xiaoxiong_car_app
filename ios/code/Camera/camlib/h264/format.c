#include "format.h"

//Convert between
//B-G-R,top-bottom mirrored,packed mode
//Y-Cb-Cr,4:1:1

// Y'= 0.114*B+0.587*G+0.299*R;
// Y = 219/255*Y'+16;
// Cb= 224/255*0.564*(B-Y')+128;
// Cr= 224/255*0.713*(R-Y')+128;

// B = 1.164*(Y-16)+2.018*(Cb-128);
// G = 1.164*(Y-16)-0.391*(Cb-128)-0.813*(Cr-128); 
// R = 1.164*(Y-16)+1.596*(Cr-128);


#define FACTOR 64
#define FACTOR_BITS 6
#define MY_INT short

MY_INT Cb2B_tab[256];
MY_INT Cb2G_tab[256];
MY_INT Cr2G_tab[256];
MY_INT Cr2R_tab[256];
MY_INT Y2BGR_tab[256];

void init_YCbCr2BGR_Tab()
{
	int i,ii;   
  
	//lookup table
	for (i = 0; i < 256; i++) {
		ii = (i<16)?16:((i>235)?235:i);
		Y2BGR_tab[i] = (MY_INT)(1.164*FACTOR*(ii-16));
	}
	for (i = 0; i < 256; i++) {
		ii = (i<16)?16:((i>240)?240:i);
		Cb2B_tab[i] = (MY_INT)((i-128) * 2.018*FACTOR);
		Cb2G_tab[i] = (MY_INT)((i-128) * 0.391*FACTOR);
		Cr2G_tab[i] = (MY_INT)((i-128) * 0.813*FACTOR);
		Cr2R_tab[i] = (MY_INT)((i-128) * 1.596*FACTOR);
	}

}


unsigned char *clip_0_255;
unsigned char ClipTab_0_255[1024];

void init_Clip_Tab()
{
	int i;

	//clip between 0-255 
	clip_0_255=ClipTab_0_255+384;
	for (i=-384; i<640; i++)
		clip_0_255[i] = (i<0) ? 0 : ((i>255) ? 255 : i);

}

//	Name:	         ConvertYCbCrToRGB24	
//	Description:     Converts YCbCr image to BGR (packed mode),top-bottom mirrored
//	Input:	         pointer to source Y, Cb, Cr, destination BGR,
//                   image width (should be multiple of 4) and height (should be multiple of 2)
//	Returns:       
//	Side effects:

void ConvertYCbCrToRGB24(unsigned char *pY,unsigned char *pCb,unsigned char *pCr,
						  unsigned char *pBGR,int iWidth,int iHeight)
{
	int i,j;
	MY_INT y11,y21;
	MY_INT y12,y22;
	MY_INT y13,y23;
	MY_INT y14,y24;
	int u,v; 
	MY_INT c11, c21, c31, c41;
	MY_INT c12, c22, c32, c42;
	unsigned int DW;
	unsigned int *id1, *id2;
	unsigned char *py1,*py2,*pu,*pv;
	unsigned char *d1, *d2;
  
	d1 = pBGR;
	d1 += iWidth*iHeight*3 - iWidth*3;
	d2 = d1 - iWidth*3;
  
	py1 = pY; pu = pCb; pv = pCr;
	py2 = py1 + iWidth;
 
	id1 = (unsigned int *)d1;
	id2 = (unsigned int *)d2;

	for (j = 0; j < iHeight; j += 2) 
	{ 
		for (i = 0; i < iWidth; i += 4) 
		{
			u = *pu++;
			v = *pv++;
			c11 = Cr2R_tab[v];
			c21 = Cb2G_tab[u];
			c31 = Cr2G_tab[v];
			c41 = Cb2B_tab[u];
			u = *pu++;
			v = *pv++;
			c12 = Cr2R_tab[v];
			c22 = Cb2G_tab[u];
			c32 = Cr2G_tab[v];
			c42 = Cb2B_tab[u];

			y11 = Y2BGR_tab[*py1++]; 
			y12 = Y2BGR_tab[*py1++];
			y13 = Y2BGR_tab[*py1++]; 
			y14 = Y2BGR_tab[*py1++];

			y21 = Y2BGR_tab[*py2++];
			y22 = Y2BGR_tab[*py2++];
			y23 = Y2BGR_tab[*py2++];
			y24 = Y2BGR_tab[*py2++];

      // BGRB
      DW = ((clip_0_255[(y11 + c41)>>FACTOR_BITS])) |
           ((clip_0_255[(y11 - c21 - c31)>>FACTOR_BITS])<<8) |
           ((clip_0_255[(y11 + c11)>>FACTOR_BITS])<<16) |  
           ((clip_0_255[(y12 + c41)>>FACTOR_BITS])<<24);
      *id1++ = DW;

      // GRBG
      DW = ((clip_0_255[(y12 - c21 - c31)>>FACTOR_BITS])) |
           ((clip_0_255[(y12 + c11)>>FACTOR_BITS])<<8) |  
           ((clip_0_255[(y13 + c42)>>FACTOR_BITS])<<16) |
           ((clip_0_255[(y13 - c22 - c32)>>FACTOR_BITS])<<24);
      *id1++ = DW;

      // RBGR
      DW = ((clip_0_255[(y13 + c12)>>FACTOR_BITS])) |  
           ((clip_0_255[(y14 + c42)>>FACTOR_BITS])<<8) |
           ((clip_0_255[(y14 - c22 - c32)>>FACTOR_BITS])<<16) |
           ((clip_0_255[(y14 + c12)>>FACTOR_BITS])<<24);  
      *id1++ = DW;

      // BGRB
      DW = ((clip_0_255[(y21 + c41)>>FACTOR_BITS])) |
           ((clip_0_255[(y21 - c21 - c31)>>FACTOR_BITS])<<8) |
           ((clip_0_255[(y21 + c11)>>FACTOR_BITS])<<16) |  
           ((clip_0_255[(y22 + c41)>>FACTOR_BITS])<<24);
      *id2++ = DW;

      // GRBG
      DW = ((clip_0_255[(y22 - c21 - c31)>>FACTOR_BITS])) |
           ((clip_0_255[(y22 + c11)>>FACTOR_BITS])<<8) |  
           ((clip_0_255[(y23 + c42)>>FACTOR_BITS])<<16) |
           ((clip_0_255[(y23 - c22 - c32)>>FACTOR_BITS])<<24);
      *id2++ = DW;

      // RBGR
      DW = ((clip_0_255[(y23 + c12)>>FACTOR_BITS])) |  
           ((clip_0_255[(y24 + c42)>>FACTOR_BITS])<<8) |
           ((clip_0_255[(y24 - c22 - c32)>>FACTOR_BITS])<<16) |
           ((clip_0_255[(y24 + c12)>>FACTOR_BITS])<<24);  
      *id2++ = DW;
    }
    id1 -= (9 * iWidth)>>2;
    id2 -= (9 * iWidth)>>2;
    py1 += iWidth;
    py2 += iWidth;
  } 
}

//	Name:	         ConvertYCbCrToRGB24_Alter	
//	Description:     Converts YCbCr image to BGR (packed mode),top-bottom mirrored
//	Input:	         pointer to source Y, Cb, Cr, destination BGR,
//                   image width (should be multiple of 4) and height (should be multiple of 2)
//	Returns:       
//	Side effects:

void ConvertYCbCrToRGB24_Alter(unsigned char *pY,unsigned char *pCb,unsigned char *pCr,
						  unsigned char *pBGR,int iWidth,int iHeight)
{
	int i,j;
	MY_INT y11,y21;
	MY_INT y12,y22;
	MY_INT y13,y23;
	MY_INT y14,y24;
	int u,v; 
	MY_INT c11, c21, c31, c41;
	MY_INT c12, c22, c32, c42;
	unsigned int DW;
	unsigned int *id1, *id2;
	unsigned char *py1,*py2,*pu,*pv;
	unsigned char *d1, *d2;
  
	d1 = pBGR;
//	d1 += iWidth*iHeight*3 - iWidth*3;
	d2 = d1 + iWidth*3;
  
	py1 = pY; pu = pCb; pv = pCr;
	py2 = py1 + iWidth;
 
	id1 = (unsigned int *)d1;
	id2 = (unsigned int *)d2;

	for (j = 0; j < iHeight; j += 2) 
	{ 
		for (i = 0; i < iWidth; i += 4) 
		{
			u = *pu++;
			v = *pv++;
			c11 = Cr2R_tab[v];
			c21 = Cb2G_tab[u];
			c31 = Cr2G_tab[v];
			c41 = Cb2B_tab[u];
			u = *pu++;
			v = *pv++;
			c12 = Cr2R_tab[v];
			c22 = Cb2G_tab[u];
			c32 = Cr2G_tab[v];
			c42 = Cb2B_tab[u];

			y11 = Y2BGR_tab[*py1++]; 
			y12 = Y2BGR_tab[*py1++];
			y13 = Y2BGR_tab[*py1++]; 
			y14 = Y2BGR_tab[*py1++];

			y21 = Y2BGR_tab[*py2++];
			y22 = Y2BGR_tab[*py2++];
			y23 = Y2BGR_tab[*py2++];
			y24 = Y2BGR_tab[*py2++];

      // BGRB
      DW = ((clip_0_255[(y11 + c41)>>FACTOR_BITS])) |
           ((clip_0_255[(y11 - c21 - c31)>>FACTOR_BITS])<<8) |
           ((clip_0_255[(y11 + c11)>>FACTOR_BITS])<<16) |  
           ((clip_0_255[(y12 + c41)>>FACTOR_BITS])<<24);
      *id1++ = DW;

      // GRBG
      DW = ((clip_0_255[(y12 - c21 - c31)>>FACTOR_BITS])) |
           ((clip_0_255[(y12 + c11)>>FACTOR_BITS])<<8) |  
           ((clip_0_255[(y13 + c42)>>FACTOR_BITS])<<16) |
           ((clip_0_255[(y13 - c22 - c32)>>FACTOR_BITS])<<24);
      *id1++ = DW;

      // RBGR
      DW = ((clip_0_255[(y13 + c12)>>FACTOR_BITS])) |  
           ((clip_0_255[(y14 + c42)>>FACTOR_BITS])<<8) |
           ((clip_0_255[(y14 - c22 - c32)>>FACTOR_BITS])<<16) |
           ((clip_0_255[(y14 + c12)>>FACTOR_BITS])<<24);  
      *id1++ = DW;

      // BGRB
      DW = ((clip_0_255[(y21 + c41)>>FACTOR_BITS])) |
           ((clip_0_255[(y21 - c21 - c31)>>FACTOR_BITS])<<8) |
           ((clip_0_255[(y21 + c11)>>FACTOR_BITS])<<16) |  
           ((clip_0_255[(y22 + c41)>>FACTOR_BITS])<<24);
      *id2++ = DW;

      // GRBG
      DW = ((clip_0_255[(y22 - c21 - c31)>>FACTOR_BITS])) |
           ((clip_0_255[(y22 + c11)>>FACTOR_BITS])<<8) |  
           ((clip_0_255[(y23 + c42)>>FACTOR_BITS])<<16) |
           ((clip_0_255[(y23 - c22 - c32)>>FACTOR_BITS])<<24);
      *id2++ = DW;

      // RBGR
      DW = ((clip_0_255[(y23 + c12)>>FACTOR_BITS])) |  
           ((clip_0_255[(y24 + c42)>>FACTOR_BITS])<<8) |
           ((clip_0_255[(y24 - c22 - c32)>>FACTOR_BITS])<<16) |
           ((clip_0_255[(y24 + c12)>>FACTOR_BITS])<<24);  
      *id2++ = DW;
    }
    id1 += (3 * iWidth)>>2;
    id2 += (3 * iWidth)>>2;
    py1 += iWidth;
    py2 += iWidth;
  } 
}



//	Name:	         ConvertYCbCrToRGB24_Mirror
//	Description:     Converts YCbCr image to BGR (packed mode),top-bottom mirrored and left-right mirrored
//	Input:	         pointer to source Y, Cb, Cr, destination BGR,
//                   image width (should be multiple of 4) and height (should be multiple of 2)
//	Returns:       
//	Side effects:

void ConvertYCbCrToRGB24_Mirror(unsigned char *pY,unsigned char *pCb,unsigned char *pCr,
						  unsigned char *pBGR,int iWidth,int iHeight)
{
	int i,j;
	int y11,y21;
	int y12,y22;
	int y13,y23;
	int y14,y24;
	int u,v; 
	int c11, c21, c31, c41;
	int c12, c22, c32, c42;
	unsigned int DW;
	unsigned int *id1, *id2;
	unsigned char *py1,*py2,*pu,*pv;
	unsigned char *d1, *d2;
  
	d1 = pBGR;
	d1 += iWidth*iHeight*3 - 4; //a dword back
	d2 = d1 - iWidth*3;
  
	py1 = pY; pu = pCb; pv = pCr;
	py2 = py1 + iWidth;
 
	id1 = (unsigned int *)d1;
	id2 = (unsigned int *)d2;

	for (j = 0; j < iHeight; j += 2) 
	{ 
		for (i = 0; i < iWidth; i += 4) 
		{
			u = *pu++;
			v = *pv++;
			c11 = Cr2R_tab[v];
			c21 = Cb2G_tab[u];
			c31 = Cr2G_tab[v];
			c41 = Cb2B_tab[u];
			u = *pu++;
			v = *pv++;
			c12 = Cr2R_tab[v];
			c22 = Cb2G_tab[u];
			c32 = Cr2G_tab[v];
			c42 = Cb2B_tab[u];

			y11 = Y2BGR_tab[*py1++]; 
			y12 = Y2BGR_tab[*py1++];
			y13 = Y2BGR_tab[*py1++]; 
			y14 = Y2BGR_tab[*py1++];

			y21 = Y2BGR_tab[*py2++];
			y22 = Y2BGR_tab[*py2++];
			y23 = Y2BGR_tab[*py2++];
			y24 = Y2BGR_tab[*py2++];

      //R2B1G1R1
      DW = ((clip_0_255[(y12 + c11)>>FACTOR_BITS])) |
           ((clip_0_255[(y11 + c41)>>FACTOR_BITS])<<8) |
           ((clip_0_255[(y11 - c21 - c31)>>FACTOR_BITS])<<16) |  
           ((clip_0_255[(y11 + c11)>>FACTOR_BITS])<<24);
      *id1-- = DW;

      //G3R3B2G2
      DW = ((clip_0_255[(y13 - c22 - c32)>>FACTOR_BITS])) |
           ((clip_0_255[(y13 + c12)>>FACTOR_BITS])<<8) |  
           ((clip_0_255[(y12 + c41)>>FACTOR_BITS])<<16) |
           ((clip_0_255[(y12 - c21 - c31)>>FACTOR_BITS])<<24);
      *id1-- = DW;

      //B4G4R4B3
      DW = ((clip_0_255[(y14 + c42)>>FACTOR_BITS])) |  
           ((clip_0_255[(y14 - c22 - c32)>>FACTOR_BITS])<<8) |
           ((clip_0_255[(y14 + c12)>>FACTOR_BITS])<<16) |
           ((clip_0_255[(y13 + c42)>>FACTOR_BITS])<<24);  
      *id1-- = DW;

      //R2B1G1R1
      DW = ((clip_0_255[(y22 + c11)>>FACTOR_BITS])) |
           ((clip_0_255[(y21 + c41)>>FACTOR_BITS])<<8) |
           ((clip_0_255[(y21 - c21 - c31)>>FACTOR_BITS])<<16) |  
           ((clip_0_255[(y21 + c11)>>FACTOR_BITS])<<24);
      *id2-- = DW;

      //G3R3B2G2
      DW = ((clip_0_255[(y23 - c22 - c32)>>FACTOR_BITS])) |
           ((clip_0_255[(y23 + c12)>>FACTOR_BITS])<<8) |  
           ((clip_0_255[(y22 + c41)>>FACTOR_BITS])<<16) |
           ((clip_0_255[(y22 - c21 - c31)>>FACTOR_BITS])<<24);
      *id2-- = DW;

      //B4G4R4B3
      DW = ((clip_0_255[(y24 + c42)>>FACTOR_BITS])) |  
           ((clip_0_255[(y24 - c22 - c32)>>FACTOR_BITS])<<8) |
           ((clip_0_255[(y24 + c12)>>FACTOR_BITS])<<16) |
           ((clip_0_255[(y23 + c42)>>FACTOR_BITS])<<24);  
      *id2-- = DW;
    }
    id1 -= (3 * iWidth)>>2;
    id2 -= (3 * iWidth)>>2;
    py1 += iWidth;
    py2 += iWidth;
  } 
}


