/*
 * H.26L/H.264/AVC/JVT/14496-10/... encoder/decoder
 * Copyright (c) 2003 Michael Niedermayer <michaelni@gmx.at>
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

/**
 * @file cabac.h
 * Context Adaptive Binary Arithmetic Coder.
 */

#ifndef FFMPEG_CABAC_H
#define FFMPEG_CABAC_H

#include "bitstream.h"

#include <assert.h>
#ifdef ARCH_X86
#include "x86_cpu.h"
#endif

#define CABAC_BITS 16
#define CABAC_MASK ((1<<CABAC_BITS)-1)
#define BRANCHLESS_CABAC_DECODER 1
//#define ARCH_X86_DISABLED 1

typedef struct CABACContext{
    int low;
    int range;
    int outstanding_count;
#ifdef STRICT_LIMITS
    int symCount;
#endif
    const uint8_t *bytestream_start;
    const uint8_t *bytestream;
    const uint8_t *bytestream_end;
    PutBitContext pb;
}CABACContext;

extern uint8_t ff_h264_mlps_state[4*64];
extern uint8_t ff_h264_lps_range[4*2*64];  ///< rangeTabLPS
extern uint8_t ff_h264_mps_state[2*64];     ///< transIdxMPS
extern uint8_t ff_h264_lps_state[2*64];     ///< transIdxLPS
extern const uint8_t ff_h264_norm_shift[512];

void ff_init_cabac_decoder(CABACContext *c, const uint8_t *buf, int buf_size);
void ff_init_cabac_states(CABACContext *c);

void put_cabac_bit(CABACContext *c, int b);

void renorm_cabac_encoder(CABACContext *c);

void refill(CABACContext *c);

#if ! ( defined(ARCH_X86) && defined(HAVE_7REGS) && defined(HAVE_EBX_AVAILABLE) && !defined(BROKEN_RELOCATIONS) )
void refill2(CABACContext *c);
#endif

void renorm_cabac_decoder(CABACContext *c);

void renorm_cabac_decoder_once(CABACContext *c);

int get_cabac_inline(CABACContext *c, uint8_t * const state);

int av_noinline get_cabac_noinline(CABACContext *c, uint8_t * const state);

int get_cabac(CABACContext *c, uint8_t * const state);

int get_cabac_bypass(CABACContext *c);

int get_cabac_bypass_sign(CABACContext *c, int val);
/**
 *
 * @return the number of bytes read or 0 if no end
 */
int get_cabac_terminate(CABACContext *c);

#endif /* FFMPEG_CABAC_H */
