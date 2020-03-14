/*
 * Copyright (c) 2003 The FFmpeg Project.
 *
 * This file is part of FFmpeg.
 *
 * FFmpeg is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * FFmpeg is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with FFmpeg; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

/*
 * How to use this decoder:
 * SVQ3 data is transported within Apple Quicktime files. Quicktime files
 * have stsd atoms to describe media trak properties. A stsd atom for a
 * video trak contains 1 or more ImageDescription atoms. These atoms begin
 * with the 4-byte length of the atom followed by the codec fourcc. Some
 * decoders need information in this atom to operate correctly. Such
 * is the case with SVQ3. In order to get the best use out of this decoder,
 * the calling app must make the SVQ3 ImageDescription atom available
 * via the AVCodecContext's extradata[_size] field:
 *
 * AVCodecContext.extradata = pointer to ImageDescription, first characters
 * are expected to be 'S', 'V', 'Q', and '3', NOT the 4-byte atom length
 * AVCodecContext.extradata_size = size of ImageDescription atom memory
 * buffer (which will be the same as the ImageDescription atom size field
 * from the QT file, minus 4 bytes since the length is missing)
 *
 * You will know you have these parameters passed correctly when the decoder
 * correctly decodes this file:
 *  ftp://ftp.mplayerhq.hu/MPlayer/samples/V-codecs/SVQ3/Vertical400kbit.sorenson3.mov
 */

/**
 * @file svq3.c
 * svq3 decoder.
 */
#ifndef __SVQ3_HH_
#define __SVQ3_HH_

#define FULLPEL_MODE  1
#define HALFPEL_MODE  2
#define THIRDPEL_MODE 3
#define PREDICT_MODE  4
#include "common.h"
#include "dsputil.h"
#include "bitstream.h"
#include "h264data.h"
#include "golomb.h"
#include "h264.h"
#include "rectangle.h"

/* dual scan (from some older h264 draft)
 o-->o-->o   o
         |  /|
 o   o   o / o
 | / |   |/  |
 o   o   o   o
   /
 o-->o-->o-->o
*/
static const uint8_t svq3_scan[16]={
 0+0*4, 1+0*4, 2+0*4, 2+1*4,
 2+2*4, 3+0*4, 3+1*4, 3+2*4,
 0+1*4, 0+2*4, 1+1*4, 1+2*4,
 0+3*4, 1+3*4, 2+3*4, 3+3*4,
};

static const uint8_t svq3_pred_0[25][2] = {
  { 0, 0 },
  { 1, 0 }, { 0, 1 },
  { 0, 2 }, { 1, 1 }, { 2, 0 },
  { 3, 0 }, { 2, 1 }, { 1, 2 }, { 0, 3 },
  { 0, 4 }, { 1, 3 }, { 2, 2 }, { 3, 1 }, { 4, 0 },
  { 4, 1 }, { 3, 2 }, { 2, 3 }, { 1, 4 },
  { 2, 4 }, { 3, 3 }, { 4, 2 },
  { 4, 3 }, { 3, 4 },
  { 4, 4 }
};

static const int8_t svq3_pred_1[6][6][5] = {
  { { 2,-1,-1,-1,-1 }, { 2, 1,-1,-1,-1 }, { 1, 2,-1,-1,-1 },
    { 2, 1,-1,-1,-1 }, { 1, 2,-1,-1,-1 }, { 1, 2,-1,-1,-1 } },
  { { 0, 2,-1,-1,-1 }, { 0, 2, 1, 4, 3 }, { 0, 1, 2, 4, 3 },
    { 0, 2, 1, 4, 3 }, { 2, 0, 1, 3, 4 }, { 0, 4, 2, 1, 3 } },
  { { 2, 0,-1,-1,-1 }, { 2, 1, 0, 4, 3 }, { 1, 2, 4, 0, 3 },
    { 2, 1, 0, 4, 3 }, { 2, 1, 4, 3, 0 }, { 1, 2, 4, 0, 3 } },
  { { 2, 0,-1,-1,-1 }, { 2, 0, 1, 4, 3 }, { 1, 2, 0, 4, 3 },
    { 2, 1, 0, 4, 3 }, { 2, 1, 3, 4, 0 }, { 2, 4, 1, 0, 3 } },
  { { 0, 2,-1,-1,-1 }, { 0, 2, 1, 3, 4 }, { 1, 2, 3, 0, 4 },
    { 2, 0, 1, 3, 4 }, { 2, 1, 3, 0, 4 }, { 2, 0, 4, 3, 1 } },
  { { 0, 2,-1,-1,-1 }, { 0, 2, 4, 1, 3 }, { 1, 4, 2, 0, 3 },
    { 4, 2, 0, 1, 3 }, { 2, 0, 1, 4, 3 }, { 4, 2, 1, 0, 3 } },
};

static const struct { uint8_t run; uint8_t level; } svq3_dct_tables[2][16] = {
  { { 0, 0 }, { 0, 1 }, { 1, 1 }, { 2, 1 }, { 0, 2 }, { 3, 1 }, { 4, 1 }, { 5, 1 },
    { 0, 3 }, { 1, 2 }, { 2, 2 }, { 6, 1 }, { 7, 1 }, { 8, 1 }, { 9, 1 }, { 0, 4 } },
  { { 0, 0 }, { 0, 1 }, { 1, 1 }, { 0, 2 }, { 2, 1 }, { 0, 3 }, { 0, 4 }, { 0, 5 },
    { 3, 1 }, { 4, 1 }, { 1, 2 }, { 1, 3 }, { 0, 6 }, { 0, 7 }, { 0, 8 }, { 0, 9 } }
};

static const uint32_t svq3_dequant_coeff[32] = {
   3881,  4351,  4890,  5481,  6154,  6914,  7761,  8718,
   9781, 10987, 12339, 13828, 15523, 17435, 19561, 21873,
  24552, 27656, 30847, 34870, 38807, 43747, 49103, 54683,
  61694, 68745, 77615, 89113,100253,109366,126635,141533
};


void svq3_luma_dc_dequant_idct_c(DCTELEM *block, int qp);
void svq3_add_idct_c (uint8_t *dst, DCTELEM *block, int stride, int qp, int dc);

int svq3_decode_block (GetBitContext *gb,
                     DCTELEM *block,
                     int index, const int type);

void svq3_mc_dir_part (MpegEncContext *s,
                     int x, int y, int width, int height,
                     int mx, int my, int dxy,
                     int thirdpel, int dir, int avg);

int svq3_mc_dir (H264Context *h, int size, int mode, int dir, int avg);

int svq3_decode_mb (H264Context *h, unsigned int mb_type);
int svq3_decode_slice_header (H264Context *h);

int svq3_decode_frame (AVCodecContext *avctx,
                              void *data, int *data_size,
                              const uint8_t *buf, int buf_size);
#endif
