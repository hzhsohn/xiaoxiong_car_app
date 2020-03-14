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
 * @file cabac.c
 * Context Adaptive Binary Arithmetic Coder.
 */

#include <string.h>

#include "common.h"
#include "bitstream.h"
#include "cabac.h"

static const uint8_t lps_range[64][4]= {
{128,176,208,240}, {128,167,197,227}, {128,158,187,216}, {123,150,178,205},
{116,142,169,195}, {111,135,160,185}, {105,128,152,175}, {100,122,144,166},
{ 95,116,137,158}, { 90,110,130,150}, { 85,104,123,142}, { 81, 99,117,135},
{ 77, 94,111,128}, { 73, 89,105,122}, { 69, 85,100,116}, { 66, 80, 95,110},
{ 62, 76, 90,104}, { 59, 72, 86, 99}, { 56, 69, 81, 94}, { 53, 65, 77, 89},
{ 51, 62, 73, 85}, { 48, 59, 69, 80}, { 46, 56, 66, 76}, { 43, 53, 63, 72},
{ 41, 50, 59, 69}, { 39, 48, 56, 65}, { 37, 45, 54, 62}, { 35, 43, 51, 59},
{ 33, 41, 48, 56}, { 32, 39, 46, 53}, { 30, 37, 43, 50}, { 29, 35, 41, 48},
{ 27, 33, 39, 45}, { 26, 31, 37, 43}, { 24, 30, 35, 41}, { 23, 28, 33, 39},
{ 22, 27, 32, 37}, { 21, 26, 30, 35}, { 20, 24, 29, 33}, { 19, 23, 27, 31},
{ 18, 22, 26, 30}, { 17, 21, 25, 28}, { 16, 20, 23, 27}, { 15, 19, 22, 25},
{ 14, 18, 21, 24}, { 14, 17, 20, 23}, { 13, 16, 19, 22}, { 12, 15, 18, 21},
{ 12, 14, 17, 20}, { 11, 14, 16, 19}, { 11, 13, 15, 18}, { 10, 12, 15, 17},
{ 10, 12, 14, 16}, {  9, 11, 13, 15}, {  9, 11, 12, 14}, {  8, 10, 12, 14},
{  8,  9, 11, 13}, {  7,  9, 11, 12}, {  7,  9, 10, 12}, {  7,  8, 10, 11},
{  6,  8,  9, 11}, {  6,  7,  9, 10}, {  6,  7,  8,  9}, {  2,  2,  2,  2},
};

uint8_t ff_h264_mlps_state[4*64];
uint8_t ff_h264_lps_range[4*2*64];
uint8_t ff_h264_lps_state[2*64];
uint8_t ff_h264_mps_state[2*64];

static const uint8_t mps_state[64]= {
  1, 2, 3, 4, 5, 6, 7, 8,
  9,10,11,12,13,14,15,16,
 17,18,19,20,21,22,23,24,
 25,26,27,28,29,30,31,32,
 33,34,35,36,37,38,39,40,
 41,42,43,44,45,46,47,48,
 49,50,51,52,53,54,55,56,
 57,58,59,60,61,62,62,63,
};

static const uint8_t lps_state[64]= {
  0, 0, 1, 2, 2, 4, 4, 5,
  6, 7, 8, 9, 9,11,11,12,
 13,13,15,15,16,16,18,18,
 19,19,21,21,22,22,23,24,
 24,25,26,26,27,27,28,29,
 29,30,30,30,31,32,32,33,
 33,33,34,34,35,35,35,36,
 36,36,37,37,37,38,38,63,
};

const uint8_t ff_h264_norm_shift[512]= {
 9,8,7,7,6,6,6,6,5,5,5,5,5,5,5,5,
 4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,
 3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,
 3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,
 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,
 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,
 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,
 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,
 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
};


int get_cabac(CABACContext *c, uint8_t * const state){
    return get_cabac_inline(c,state);
}

int get_cabac_bypass(CABACContext *c){
    int range;
    c->low += c->low;

    if(!(c->low & CABAC_MASK))
        refill(c);

    range= c->range<<(CABAC_BITS+1);
    if(c->low < range){
        return 0;
    }else{
        c->low -= range;
        return 1;
    }
}


int get_cabac_bypass_sign(CABACContext *c, int val){
#if defined(ARCH_X86) && !(defined(PIC) && defined(__GNUC__))
    asm volatile(
        "movl "RANGE    "(%1), %%ebx            \n\t"
        "movl "LOW      "(%1), %%eax            \n\t"
        "shl $17, %%ebx                         \n\t"
        "add %%eax, %%eax                       \n\t"
        "sub %%ebx, %%eax                       \n\t"
        "cltd                                   \n\t"
        "and %%edx, %%ebx                       \n\t"
        "add %%ebx, %%eax                       \n\t"
        "xor %%edx, %%ecx                       \n\t"
        "sub %%edx, %%ecx                       \n\t"
        "test %%ax, %%ax                        \n\t"
        " jnz 1f                                \n\t"
        "mov  "BYTE     "(%1), %%"REG_b"        \n\t"
        "subl $0xFFFF, %%eax                    \n\t"
        "movzwl (%%"REG_b"), %%edx              \n\t"
        "bswap %%edx                            \n\t"
        "shrl $15, %%edx                        \n\t"
        "add  $2, %%"REG_b"                     \n\t"
        "addl %%edx, %%eax                      \n\t"
        "mov  %%"REG_b", "BYTE     "(%1)        \n\t"
        "1:                                     \n\t"
        "movl %%eax, "LOW      "(%1)            \n\t"

        :"+c"(val)
        :"r"(c)
        : "%eax", "%"REG_b, "%edx", "memory"
    );
    return val;
#else
    int range, mask;
    c->low += c->low;

    if(!(c->low & CABAC_MASK))
        refill(c);

    range= c->range<<(CABAC_BITS+1);
    c->low -= range;
    mask= c->low >> 31;
    range &= mask;
    c->low += range;
    return (val^mask)-mask;
#endif
}

int get_cabac_terminate(CABACContext *c){
    c->range -= 2;
    if(c->low < c->range<<(CABAC_BITS+1)){
        renorm_cabac_decoder_once(c);
        return 0;
    }else{
        return c->bytestream - c->bytestream_start;
    }
}

int av_noinline get_cabac_noinline(CABACContext *c, uint8_t * const state){
    return get_cabac_inline(c,state);
}
/**
 *
 * @param buf_size size of buf in bits
 */
void ff_init_cabac_decoder(CABACContext *c, const uint8_t *buf, int buf_size){
    c->bytestream_start=
    c->bytestream= buf;
    c->bytestream_end= buf + buf_size;

#if CABAC_BITS == 16
    c->low =  (*c->bytestream++)<<18;
    c->low+=  (*c->bytestream++)<<10;
#else
    c->low =  (*c->bytestream++)<<10;
#endif
    c->low+= ((*c->bytestream++)<<2) + 2;
    c->range= 0x1FE;
}

void ff_init_cabac_states(CABACContext *c){
    int i, j;

    for(i=0; i<64; i++){
        for(j=0; j<4; j++){ //FIXME check if this is worth the 1 shift we save
            ff_h264_lps_range[j*2*64+2*i+0]=
            ff_h264_lps_range[j*2*64+2*i+1]= lps_range[i][j];
        }

        ff_h264_mlps_state[128+2*i+0]=
        ff_h264_mps_state[2*i+0]= 2*mps_state[i]+0;
        ff_h264_mlps_state[128+2*i+1]=
        ff_h264_mps_state[2*i+1]= 2*mps_state[i]+1;

        if( i ){
#ifdef BRANCHLESS_CABAC_DECODER
            ff_h264_mlps_state[128-2*i-1]= 2*lps_state[i]+0;
            ff_h264_mlps_state[128-2*i-2]= 2*lps_state[i]+1;
        }else{
            ff_h264_mlps_state[128-2*i-1]= 1;
            ff_h264_mlps_state[128-2*i-2]= 0;
#else
            ff_h264_lps_state[2*i+0]= 2*lps_state[i]+0;
            ff_h264_lps_state[2*i+1]= 2*lps_state[i]+1;
        }else{
            ff_h264_lps_state[2*i+0]= 1;
            ff_h264_lps_state[2*i+1]= 0;
#endif
        }
    }
}

int get_cabac_inline(CABACContext *c, uint8_t * const state){
    //FIXME gcc generates duplicate load/stores for c->low and c->range
#define LOW          "0"
#define RANGE        "4"
#ifdef ARCH_X86_64
#define BYTESTART   "16"
#define BYTE        "24"
#define BYTEEND     "32"
#else
#define BYTESTART   "12"
#define BYTE        "16"
#define BYTEEND     "20"
#endif
#if defined(ARCH_X86) && defined(HAVE_7REGS) && defined(HAVE_EBX_AVAILABLE) && !defined(BROKEN_RELOCATIONS)
    int bit;

#ifndef BRANCHLESS_CABAC_DECODER
    asm volatile(
        "movzbl (%1), %0                        \n\t"
        "movl "RANGE    "(%2), %%ebx            \n\t"
        "movl "RANGE    "(%2), %%edx            \n\t"
        "andl $0xC0, %%ebx                      \n\t"
        "movzbl "MANGLE(ff_h264_lps_range)"(%0, %%ebx, 2), %%esi\n\t"
        "movl "LOW      "(%2), %%ebx            \n\t"
//eax:state ebx:low, edx:range, esi:RangeLPS
        "subl %%esi, %%edx                      \n\t"
        "movl %%edx, %%ecx                      \n\t"
        "shll $17, %%ecx                        \n\t"
        "cmpl %%ecx, %%ebx                      \n\t"
        " ja 1f                                 \n\t"

#if 1
        //athlon:4067 P3:4110
        "lea -0x100(%%edx), %%ecx               \n\t"
        "shr $31, %%ecx                         \n\t"
        "shl %%cl, %%edx                        \n\t"
        "shl %%cl, %%ebx                        \n\t"
#else
        //athlon:4057 P3:4130
        "cmp $0x100, %%edx                      \n\t" //FIXME avoidable
        "setb %%cl                              \n\t"
        "shl %%cl, %%edx                        \n\t"
        "shl %%cl, %%ebx                        \n\t"
#endif
        "movzbl "MANGLE(ff_h264_mps_state)"(%0), %%ecx   \n\t"
        "movb %%cl, (%1)                        \n\t"
//eax:state ebx:low, edx:range, esi:RangeLPS
        "test %%bx, %%bx                        \n\t"
        " jnz 2f                                \n\t"
        "mov  "BYTE     "(%2), %%"REG_S"        \n\t"
        "subl $0xFFFF, %%ebx                    \n\t"
        "movzwl (%%"REG_S"), %%ecx              \n\t"
        "bswap %%ecx                            \n\t"
        "shrl $15, %%ecx                        \n\t"
        "add  $2, %%"REG_S"                     \n\t"
        "addl %%ecx, %%ebx                      \n\t"
        "mov  %%"REG_S", "BYTE    "(%2)         \n\t"
        "jmp 2f                                 \n\t"
        "1:                                     \n\t"
//eax:state ebx:low, edx:range, esi:RangeLPS
        "subl %%ecx, %%ebx                      \n\t"
        "movl %%esi, %%edx                      \n\t"
        "movzbl " MANGLE(ff_h264_norm_shift) "(%%esi), %%ecx   \n\t"
        "shll %%cl, %%ebx                       \n\t"
        "shll %%cl, %%edx                       \n\t"
        "movzbl "MANGLE(ff_h264_lps_state)"(%0), %%ecx   \n\t"
        "movb %%cl, (%1)                        \n\t"
        "add  $1, %0                            \n\t"
        "test %%bx, %%bx                        \n\t"
        " jnz 2f                                \n\t"

        "mov  "BYTE     "(%2), %%"REG_c"        \n\t"
        "movzwl (%%"REG_c"), %%esi              \n\t"
        "bswap %%esi                            \n\t"
        "shrl $15, %%esi                        \n\t"
        "subl $0xFFFF, %%esi                    \n\t"
        "add  $2, %%"REG_c"                     \n\t"
        "mov  %%"REG_c", "BYTE    "(%2)         \n\t"

        "leal -1(%%ebx), %%ecx                  \n\t"
        "xorl %%ebx, %%ecx                      \n\t"
        "shrl $15, %%ecx                        \n\t"
        "movzbl " MANGLE(ff_h264_norm_shift) "(%%ecx), %%ecx   \n\t"
        "neg %%ecx                              \n\t"
        "add $7, %%ecx                          \n\t"

        "shll %%cl , %%esi                      \n\t"
        "addl %%esi, %%ebx                      \n\t"
        "2:                                     \n\t"
        "movl %%edx, "RANGE    "(%2)            \n\t"
        "movl %%ebx, "LOW      "(%2)            \n\t"
        :"=&a"(bit) //FIXME this is fragile gcc either runs out of registers or miscompiles it (for example if "+a"(bit) or "+m"(*state) is used
        :"r"(state), "r"(c)
        : "%"REG_c, "%ebx", "%edx", "%"REG_S, "memory"
    );
    bit&=1;
#else /* BRANCHLESS_CABAC_DECODER */


#if defined HAVE_FAST_CMOV
#define BRANCHLESS_GET_CABAC_UPDATE(ret, cabac, statep, low, lowword, range, tmp, tmpbyte)\
        "mov    "tmp"       , %%ecx                                     \n\t"\
        "shl    $17         , "tmp"                                     \n\t"\
        "cmp    "low"       , "tmp"                                     \n\t"\
        "cmova  %%ecx       , "range"                                   \n\t"\
        "sbb    %%ecx       , %%ecx                                     \n\t"\
        "and    %%ecx       , "tmp"                                     \n\t"\
        "sub    "tmp"       , "low"                                     \n\t"\
        "xor    %%ecx       , "ret"                                     \n\t"
#else /* HAVE_FAST_CMOV */
#define BRANCHLESS_GET_CABAC_UPDATE(ret, cabac, statep, low, lowword, range, tmp, tmpbyte)\
        "mov    "tmp"       , %%ecx                                     \n\t"\
        "shl    $17         , "tmp"                                     \n\t"\
        "sub    "low"       , "tmp"                                     \n\t"\
        "sar    $31         , "tmp"                                     \n\t" /*lps_mask*/\
        "sub    %%ecx       , "range"                                   \n\t" /*RangeLPS - range*/\
        "and    "tmp"       , "range"                                   \n\t" /*(RangeLPS - range)&lps_mask*/\
        "add    %%ecx       , "range"                                   \n\t" /*new range*/\
        "shl    $17         , %%ecx                                     \n\t"\
        "and    "tmp"       , %%ecx                                     \n\t"\
        "sub    %%ecx       , "low"                                     \n\t"\
        "xor    "tmp"       , "ret"                                     \n\t"
#endif /* HAVE_FAST_CMOV */


#define BRANCHLESS_GET_CABAC(ret, cabac, statep, low, lowword, range, tmp, tmpbyte)\
        "movzbl "statep"    , "ret"                                     \n\t"\
        "mov    "range"     , "tmp"                                     \n\t"\
        "and    $0xC0       , "range"                                   \n\t"\
        "movzbl "MANGLE(ff_h264_lps_range)"("ret", "range", 2), "range" \n\t"\
        "sub    "range"     , "tmp"                                     \n\t"\
        BRANCHLESS_GET_CABAC_UPDATE(ret, cabac, statep, low, lowword, range, tmp, tmpbyte)\
        "movzbl " MANGLE(ff_h264_norm_shift) "("range"), %%ecx          \n\t"\
        "shl    %%cl        , "range"                                   \n\t"\
        "movzbl "MANGLE(ff_h264_mlps_state)"+128("ret"), "tmp"          \n\t"\
        "mov    "tmpbyte"   , "statep"                                  \n\t"\
        "shl    %%cl        , "low"                                     \n\t"\
        "test   "lowword"   , "lowword"                                 \n\t"\
        " jnz   1f                                                      \n\t"\
        "mov "BYTE"("cabac"), %%"REG_c"                                 \n\t"\
        "movzwl (%%"REG_c")     , "tmp"                                 \n\t"\
        "bswap  "tmp"                                                   \n\t"\
        "shr    $15         , "tmp"                                     \n\t"\
        "sub    $0xFFFF     , "tmp"                                     \n\t"\
        "add    $2          , %%"REG_c"                                 \n\t"\
        "mov    %%"REG_c"   , "BYTE    "("cabac")                       \n\t"\
        "lea    -1("low")   , %%ecx                                     \n\t"\
        "xor    "low"       , %%ecx                                     \n\t"\
        "shr    $15         , %%ecx                                     \n\t"\
        "movzbl " MANGLE(ff_h264_norm_shift) "(%%ecx), %%ecx            \n\t"\
        "neg    %%ecx                                                   \n\t"\
        "add    $7          , %%ecx                                     \n\t"\
        "shl    %%cl        , "tmp"                                     \n\t"\
        "add    "tmp"       , "low"                                     \n\t"\
        "1:                                                             \n\t"

    asm volatile(
        "movl "RANGE    "(%2), %%esi            \n\t"
        "movl "LOW      "(%2), %%ebx            \n\t"
        BRANCHLESS_GET_CABAC("%0", "%2", "(%1)", "%%ebx", "%%bx", "%%esi", "%%edx", "%%dl")
        "movl %%esi, "RANGE    "(%2)            \n\t"
        "movl %%ebx, "LOW      "(%2)            \n\t"

        :"=&a"(bit)
        :"r"(state), "r"(c)
        : "%"REG_c, "%ebx", "%edx", "%esi", "memory"
    );
    bit&=1;
#endif /* BRANCHLESS_CABAC_DECODER */
#else /* defined(ARCH_X86) && defined(HAVE_7REGS) && defined(HAVE_EBX_AVAILABLE) && !defined(BROKEN_RELOCATIONS) */
    int s = *state;
    int RangeLPS= ff_h264_lps_range[2*(c->range&0xC0) + s];
    int bit, lps_mask av_unused;

    c->range -= RangeLPS;
#ifndef BRANCHLESS_CABAC_DECODER
    if(c->low < (c->range<<(CABAC_BITS+1))){
        bit= s&1;
        *state= ff_h264_mps_state[s];
        renorm_cabac_decoder_once(c);
    }else{
        bit= ff_h264_norm_shift[RangeLPS];
        c->low -= (c->range<<(CABAC_BITS+1));
        *state= ff_h264_lps_state[s];
        c->range = RangeLPS<<bit;
        c->low <<= bit;
        bit= (s&1)^1;

        if(!(c->low & CABAC_MASK)){
            refill2(c);
        }
    }
#else /* BRANCHLESS_CABAC_DECODER */
    lps_mask= ((c->range<<(CABAC_BITS+1)) - c->low)>>31;

    c->low -= (c->range<<(CABAC_BITS+1)) & lps_mask;
    c->range += (RangeLPS - c->range) & lps_mask;

    s^=lps_mask;
    *state= (ff_h264_mlps_state+128)[s];
    bit= s&1;

    lps_mask= ff_h264_norm_shift[c->range];
    c->range<<= lps_mask;
    c->low  <<= lps_mask;
    if(!(c->low & CABAC_MASK))
        refill2(c);
#endif /* BRANCHLESS_CABAC_DECODER */
#endif /* defined(ARCH_X86) && defined(HAVE_7REGS) && defined(HAVE_EBX_AVAILABLE) && !defined(BROKEN_RELOCATIONS) */
    return bit;
}

void renorm_cabac_decoder_once(CABACContext *c){
#ifdef ARCH_X86_DISABLED
    int temp;
#if 0
    //P3:683    athlon:475
    asm(
        "lea -0x100(%0), %2         \n\t"
        "shr $31, %2                \n\t"  //FIXME 31->63 for x86-64
        "shl %%cl, %0               \n\t"
        "shl %%cl, %1               \n\t"
        : "+r"(c->range), "+r"(c->low), "+c"(temp)
    );
#elif 0
    //P3:680    athlon:474
    asm(
        "cmp $0x100, %0             \n\t"
        "setb %%cl                  \n\t"  //FIXME 31->63 for x86-64
        "shl %%cl, %0               \n\t"
        "shl %%cl, %1               \n\t"
        : "+r"(c->range), "+r"(c->low), "+c"(temp)
    );
#elif 1
    int temp2;
    //P3:665    athlon:517
    asm(
        "lea -0x100(%0), %%eax      \n\t"
        "cltd                       \n\t"
        "mov %0, %%eax              \n\t"
        "and %%edx, %0              \n\t"
        "and %1, %%edx              \n\t"
        "add %%eax, %0              \n\t"
        "add %%edx, %1              \n\t"
        : "+r"(c->range), "+r"(c->low), "+a"(temp), "+d"(temp2)
    );
#elif 0
    int temp2;
    //P3:673    athlon:509
    asm(
        "cmp $0x100, %0             \n\t"
        "sbb %%edx, %%edx           \n\t"
        "mov %0, %%eax              \n\t"
        "and %%edx, %0              \n\t"
        "and %1, %%edx              \n\t"
        "add %%eax, %0              \n\t"
        "add %%edx, %1              \n\t"
        : "+r"(c->range), "+r"(c->low), "+a"(temp), "+d"(temp2)
    );
#else
    int temp2;
    //P3:677    athlon:511
    asm(
        "cmp $0x100, %0             \n\t"
        "lea (%0, %0), %%eax        \n\t"
        "lea (%1, %1), %%edx        \n\t"
        "cmovb %%eax, %0            \n\t"
        "cmovb %%edx, %1            \n\t"
        : "+r"(c->range), "+r"(c->low), "+a"(temp), "+d"(temp2)
    );
#endif
#else
    //P3:675    athlon:476
    int shift= (uint32_t)(c->range - 0x100)>>31;
    c->range<<= shift;
    c->low  <<= shift;
#endif
    if(!(c->low & CABAC_MASK))
        refill(c);
}

void renorm_cabac_decoder(CABACContext *c){
    while(c->range < 0x100){
        c->range+= c->range;
        c->low+= c->low;
        if(!(c->low & CABAC_MASK))
            refill(c);
    }
}

#if ! ( defined(ARCH_X86) && defined(HAVE_7REGS) && defined(HAVE_EBX_AVAILABLE) && !defined(BROKEN_RELOCATIONS) )
void refill2(CABACContext *c){
    int i, x;

    x= c->low ^ (c->low-1);
    i= 7 - ff_h264_norm_shift[x>>(CABAC_BITS-1)];

    x= -CABAC_MASK;

#if CABAC_BITS == 16
        x+= (c->bytestream[0]<<9) + (c->bytestream[1]<<1);
#else
        x+= c->bytestream[0]<<1;
#endif

    c->low += x<<i;
    c->bytestream+= CABAC_BITS/8;
}
#endif

void refill(CABACContext *c){
#if CABAC_BITS == 16
        c->low+= (c->bytestream[0]<<9) + (c->bytestream[1]<<1);
#else
        c->low+= c->bytestream[0]<<1;
#endif
    c->low -= CABAC_MASK;
    c->bytestream+= CABAC_BITS/8;
}

void renorm_cabac_encoder(CABACContext *c){
    while(c->range < 0x100){
        //FIXME optimize
        if(c->low<0x100){
            put_cabac_bit(c, 0);
        }else if(c->low<0x200){
            c->outstanding_count++;
            c->low -= 0x100;
        }else{
            put_cabac_bit(c, 1);
            c->low -= 0x200;
        }

        c->range+= c->range;
        c->low += c->low;
    }
}

void put_cabac_bit(CABACContext *c, int b){
    put_bits(&c->pb, 1, b);
    for(;c->outstanding_count; c->outstanding_count--){
        put_bits(&c->pb, 1, 1-b);
    }
}

uint16_t bswap_16(uint16_t x)
{
#if defined(ARCH_X86)
    asm("rorw $8, %0" : "+r"(x));
#elif defined(ARCH_SH4)
    asm("swap.b %0,%0" : "=r"(x) : "0"(x));
#else
    x= (x>>8) | (x<<8);
#endif
    return x;
}

uint32_t bswap_32(uint32_t x)
{
#if defined(ARCH_X86)
#ifdef HAVE_BSWAP
    asm("bswap   %0" : "+r" (x));
#else
    asm("rorw    $8,  %w0 \n\t"
        "rorl    $16, %0  \n\t"
        "rorw    $8,  %w0"
        : "+r"(x));
#endif
#elif defined(ARCH_SH4)
    asm("swap.b %0,%0\n"
        "swap.w %0,%0\n"
        "swap.b %0,%0\n"
        : "=r"(x) : "0"(x));
#elif defined(ARCH_ARM)
    uint32_t t;
    asm ("eor %1, %0, %0, ror #16 \n\t"
         "bic %1, %1, #0xFF0000   \n\t"
         "mov %0, %0, ror #8      \n\t"
         "eor %0, %0, %1, lsr #8  \n\t"
         : "+r"(x), "+r"(t));
#elif defined(ARCH_BFIN)
    unsigned tmp;
    asm("%1 = %0 >> 8 (V);      \n\t"
        "%0 = %0 << 8 (V);      \n\t"
        "%0 = %0 | %1;          \n\t"
        "%0 = PACK(%0.L, %0.H); \n\t"
        : "+d"(x), "=&d"(tmp));
#else
    x= ((x<<8)&0xFF00FF00) | ((x>>8)&0x00FF00FF);
    x= (x>>16) | (x<<16);
#endif
    return x;
}

uint64_t bswap_64(uint64_t x)
{
#if 0
    x= ((x<< 8)&0xFF00FF00FF00FF00ULL) | ((x>> 8)&0x00FF00FF00FF00FFULL);
    x= ((x<<16)&0xFFFF0000FFFF0000ULL) | ((x>>16)&0x0000FFFF0000FFFFULL);
    return (x>>32) | (x<<32);
#elif defined(ARCH_X86_64)
	asm("bswap  %0": "=r" (x) : "0" (x));
	return x;
#else
    union {
        uint64_t ll;
        uint32_t l[2];
    } w, r;
    w.ll = x;
    r.l[0] = bswap_32 (w.l[1]);
    r.l[1] = bswap_32 (w.l[0]);
    return r.ll;
#endif
}


