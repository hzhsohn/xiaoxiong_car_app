/*
 * Common bit i/o utils
 * Copyright (c) 2000, 2001 Fabrice Bellard.
 * Copyright (c) 2002-2004 Michael Niedermayer <michaelni@gmx.at>
 *
 * alternative bitstream reader & writer by Michael Niedermayer <michaelni@gmx.at>
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
 * @file bitstream.c
 * bitstream api.
 */

#include "avcodec.h"
#include "bitstream.h"
#include "define.h"

/**
 * Same as av_mallocz_static(), but does a realloc.
 *
 * @param[in] ptr The block of memory to reallocate.
 * @param[in] size The requested size.
 * @return Block of memory of requested size.
 * @deprecated. Code which uses ff_realloc_static is broken/misdesigned
 * and should correctly use static arrays
 */
attribute_deprecated av_alloc_size(2)
void *ff_realloc_static(void *ptr, unsigned int size);

void *ff_realloc_static(void *ptr, unsigned int size)
{
    return av_realloc(ptr, size);
}


/* VLC decoding */

//#define DEBUG_VLC

#define GET_DATA(v, table, i, wrap, size) \
{\
    const uint8_t *ptr = (const uint8_t *)table + i * wrap;\
    switch(size) {\
    case 1:\
        v = *(const uint8_t *)ptr;\
        break;\
    case 2:\
        v = *(const uint16_t *)ptr;\
        break;\
    default:\
        v = *(const uint32_t *)ptr;\
        break;\
    }\
}


int alloc_table(VLC *vlc, int size, int use_static)
{
    int index;
    index = vlc->table_size;
    vlc->table_size += size;
    if (vlc->table_size > vlc->table_allocated) {
        if(use_static>1)
            abort(); //cant do anything, init_vlc() is used with too little memory
        vlc->table_allocated += (1 << vlc->bits);
        if(use_static)
            vlc->table = ff_realloc_static(vlc->table,
                                           sizeof(VLC_TYPE) * 2 * vlc->table_allocated);
        else
            vlc->table = av_realloc(vlc->table,
                                    sizeof(VLC_TYPE) * 2 * vlc->table_allocated);
        if (!vlc->table)
            return -1;
    }
    return index;
}

int build_table(VLC *vlc, int table_nb_bits,
                       int nb_codes,
                       const void *bits, int bits_wrap, int bits_size,
                       const void *codes, int codes_wrap, int codes_size,
                       const void *symbols, int symbols_wrap, int symbols_size,
                       uint32_t code_prefix, int n_prefix, int flags)
{
    int i, j, k, n, table_size, table_index, nb, n1, index, code_prefix2, symbol;
    uint32_t code;
    VLC_TYPE (*table)[2];

    table_size = 1 << table_nb_bits;
    table_index = alloc_table(vlc, table_size, flags & (INIT_VLC_USE_STATIC|INIT_VLC_USE_NEW_STATIC));
#ifdef DEBUG_VLC
    av_log(NULL,AV_LOG_DEBUG,"new table index=%d size=%d code_prefix=%x n=%d\n",
           table_index, table_size, code_prefix, n_prefix);
#endif
    if (table_index < 0)
        return -1;
    table = &vlc->table[table_index];

    for(i=0;i<table_size;i++) {
        table[i][1] = 0; //bits
        table[i][0] = -1; //codes
    }

    /* first pass: map codes and compute auxillary table sizes */
    for(i=0;i<nb_codes;i++) {
        GET_DATA(n, bits, i, bits_wrap, bits_size);
        GET_DATA(code, codes, i, codes_wrap, codes_size);
        /* we accept tables with holes */
        if (n <= 0)
            continue;
        if (!symbols)
            symbol = i;
        else
            GET_DATA(symbol, symbols, i, symbols_wrap, symbols_size);
#if defined(DEBUG_VLC) && 0
        av_log(NULL,AV_LOG_DEBUG,"i=%d n=%d code=0x%x\n", i, n, code);
#endif
        /* if code matches the prefix, it is in the table */
        n -= n_prefix;
        if(flags & INIT_VLC_LE)
            code_prefix2= code & (n_prefix>=32 ? 0xffffffff : (1 << n_prefix)-1);
        else
            code_prefix2= code >> n;
        if (n > 0 && code_prefix2 == code_prefix) {
            if (n <= table_nb_bits) {
                /* no need to add another table */
                j = (code << (table_nb_bits - n)) & (table_size - 1);
                nb = 1 << (table_nb_bits - n);
                for(k=0;k<nb;k++) {
                    if(flags & INIT_VLC_LE)
                        j = (code >> n_prefix) + (k<<n);
#ifdef DEBUG_VLC
                    av_log(NULL, AV_LOG_DEBUG, "%4x: code=%d n=%d\n",
                           j, i, n);
#endif
                    if (table[j][1] /*bits*/ != 0) {
                        av_log(NULL, AV_LOG_ERROR, "incorrect codes\n");
                        return -1;
                    }
                    table[j][1] = n; //bits
                    table[j][0] = symbol;
                    j++;
                }
            } else {
                n -= table_nb_bits;
                j = (code >> ((flags & INIT_VLC_LE) ? n_prefix : n)) & ((1 << table_nb_bits) - 1);
#ifdef DEBUG_VLC
                av_log(NULL,AV_LOG_DEBUG,"%4x: n=%d (subtable)\n",
                       j, n);
#endif
                /* compute table size */
                n1 = -table[j][1]; //bits
                if (n > n1)
                    n1 = n;
                table[j][1] = -n1; //bits
            }
        }
    }

    /* second pass : fill auxillary tables recursively */
    for(i=0;i<table_size;i++) {
        n = table[i][1]; //bits
        if (n < 0) {
            n = -n;
            if (n > table_nb_bits) {
                n = table_nb_bits;
                table[i][1] = -n; //bits
            }
            index = build_table(vlc, n, nb_codes,
                                bits, bits_wrap, bits_size,
                                codes, codes_wrap, codes_size,
                                symbols, symbols_wrap, symbols_size,
                                (flags & INIT_VLC_LE) ? (code_prefix | (i << n_prefix)) : ((code_prefix << table_nb_bits) | i),
                                n_prefix + table_nb_bits, flags);
            if (index < 0)
                return -1;
            /* note: realloc has been done, so reload tables */
            table = &vlc->table[table_index];
            table[i][0] = index; //code
        }
    }
    return table_index;
}


/* Build VLC decoding tables suitable for use with get_vlc().

   'nb_bits' set thee decoding table size (2^nb_bits) entries. The
   bigger it is, the faster is the decoding. But it should not be too
   big to save memory and L1 cache. '9' is a good compromise.

   'nb_codes' : number of vlcs codes

   'bits' : table which gives the size (in bits) of each vlc code.

   'codes' : table which gives the bit pattern of of each vlc code.

   'symbols' : table which gives the values to be returned from get_vlc().

   'xxx_wrap' : give the number of bytes between each entry of the
   'bits' or 'codes' tables.

   'xxx_size' : gives the number of bytes of each entry of the 'bits'
   or 'codes' tables.

   'wrap' and 'size' allows to use any memory configuration and types
   (byte/word/long) to store the 'bits', 'codes', and 'symbols' tables.

   'use_static' should be set to 1 for tables, which should be freed
   with av_free_static(), 0 if free_vlc() will be used.
*/
int init_vlc_sparse(VLC *vlc, int nb_bits, int nb_codes,
             const void *bits, int bits_wrap, int bits_size,
             const void *codes, int codes_wrap, int codes_size,
             const void *symbols, int symbols_wrap, int symbols_size,
             int flags)
{
    vlc->bits = nb_bits;
    if(flags & INIT_VLC_USE_NEW_STATIC){
        if(vlc->table_size && vlc->table_size == vlc->table_allocated){
            return 0;
        }else if(vlc->table_size){
            abort(); // fatal error, we are called on a partially initialized table
        }
    }else if(!(flags & INIT_VLC_USE_STATIC)) {
        vlc->table = NULL;
        vlc->table_allocated = 0;
        vlc->table_size = 0;
    } else {
        /* Static tables are initially always NULL, return
           if vlc->table != NULL to avoid double allocation */
        if(vlc->table)
            return 0;
    }

#ifdef DEBUG_VLC
    av_log(NULL,AV_LOG_DEBUG,"build table nb_codes=%d\n", nb_codes);
#endif

    if (build_table(vlc, nb_bits, nb_codes,
                    bits, bits_wrap, bits_size,
                    codes, codes_wrap, codes_size,
                    symbols, symbols_wrap, symbols_size,
                    0, 0, flags) < 0) {
        av_freep(&vlc->table);
        return -1;
    }
    if((flags & INIT_VLC_USE_NEW_STATIC) && vlc->table_size != vlc->table_allocated)
        av_log(NULL, AV_LOG_ERROR, "needed %d had %d\n", vlc->table_size, vlc->table_allocated);
    return 0;
}


void free_vlc(VLC *vlc)
{
    av_freep(&vlc->table);
}


void init_put_bits(PutBitContext *s, uint8_t *buffer, int buffer_size)
{
    if(buffer_size < 0) {
        buffer_size = 0;
        buffer = NULL;
    }

    s->buf = buffer;
    s->buf_end = s->buf + buffer_size;
#ifdef ALT_BITSTREAM_WRITER
    s->index=0;
    ((uint32_t*)(s->buf))[0]=0;
//    memset(buffer, 0, buffer_size);
#else
    s->buf_ptr = s->buf;
    s->bit_left=32;
    s->bit_buf=0;
#endif
}

int put_bits_count(PutBitContext *s)
{
#ifdef ALT_BITSTREAM_WRITER
    return s->index;
#else
    return (s->buf_ptr - s->buf) * 8 + 32 - s->bit_left;
#endif
}

void flush_put_bits(PutBitContext *s)
{
#ifdef ALT_BITSTREAM_WRITER
    align_put_bits(s);
#else
    s->bit_buf<<= s->bit_left;
    while (s->bit_left < 32) {
        /* XXX: should test end of buffer */
        *s->buf_ptr++=s->bit_buf >> 24;
        s->bit_buf<<=8;
        s->bit_left+=8;
    }
    s->bit_left=32;
    s->bit_buf=0;
#endif
}

#ifndef ALT_BITSTREAM_WRITER
void put_bits(PutBitContext *s, int n, unsigned int value)
{
    unsigned int bit_buf;
    int bit_left;

    //    printf("put_bits=%d %x\n", n, value);
    assert(n == 32 || value < (1U << n));

    bit_buf = s->bit_buf;
    bit_left = s->bit_left;

    //    printf("n=%d value=%x cnt=%d buf=%x\n", n, value, bit_cnt, bit_buf);
    /* XXX: optimize */
    if (n < bit_left) {
        bit_buf = (bit_buf<<n) | value;
        bit_left-=n;
    } else {
        bit_buf<<=bit_left;
        bit_buf |= value >> (n - bit_left);
#ifdef UNALIGNED_STORES_ARE_BAD
        if (3 & (intptr_t) s->buf_ptr) {
            s->buf_ptr[0] = bit_buf >> 24;
            s->buf_ptr[1] = bit_buf >> 16;
            s->buf_ptr[2] = bit_buf >>  8;
            s->buf_ptr[3] = bit_buf      ;
        } else
#endif
        *(uint32_t *)s->buf_ptr = be2me_32(bit_buf);
        //printf("bitbuf = %08x\n", bit_buf);
        s->buf_ptr+=4;
        bit_left+=32 - n;
        bit_buf = value;
    }

    s->bit_buf = bit_buf;
    s->bit_left = bit_left;
}
#endif


#ifdef ALT_BITSTREAM_WRITER
void put_bits(PutBitContext *s, int n, unsigned int value)
{
#    ifdef ALIGNED_BITSTREAM_WRITER
#        if defined(ARCH_X86)
    asm volatile(
        "movl %0, %%ecx                 \n\t"
        "xorl %%eax, %%eax              \n\t"
        "shrdl %%cl, %1, %%eax          \n\t"
        "shrl %%cl, %1                  \n\t"
        "movl %0, %%ecx                 \n\t"
        "shrl $3, %%ecx                 \n\t"
        "andl $0xFFFFFFFC, %%ecx        \n\t"
        "bswapl %1                      \n\t"
        "orl %1, (%2, %%ecx)            \n\t"
        "bswapl %%eax                   \n\t"
        "addl %3, %0                    \n\t"
        "movl %%eax, 4(%2, %%ecx)       \n\t"
        : "=&r" (s->index), "=&r" (value)
        : "r" (s->buf), "r" (n), "0" (s->index), "1" (value<<(-n))
        : "%eax", "%ecx"
    );
#        else
    int index= s->index;
    uint32_t *ptr= ((uint32_t *)s->buf)+(index>>5);

    value<<= 32-n;

    ptr[0] |= be2me_32(value>>(index&31));
    ptr[1]  = be2me_32(value<<(32-(index&31)));
//if(n>24) printf("%d %d\n", n, value);
    index+= n;
    s->index= index;
#        endif
#    else //ALIGNED_BITSTREAM_WRITER
#        if defined(ARCH_X86)
    asm volatile(
        "movl $7, %%ecx                 \n\t"
        "andl %0, %%ecx                 \n\t"
        "addl %3, %%ecx                 \n\t"
        "negl %%ecx                     \n\t"
        "shll %%cl, %1                  \n\t"
        "bswapl %1                      \n\t"
        "movl %0, %%ecx                 \n\t"
        "shrl $3, %%ecx                 \n\t"
        "orl %1, (%%ecx, %2)            \n\t"
        "addl %3, %0                    \n\t"
        "movl $0, 4(%%ecx, %2)          \n\t"
        : "=&r" (s->index), "=&r" (value)
        : "r" (s->buf), "r" (n), "0" (s->index), "1" (value)
        : "%ecx"
    );
#        else
    int index= s->index;
    uint32_t *ptr= (uint32_t*)(((uint8_t *)s->buf)+(index>>3));

    ptr[0] |= be2me_32(value<<(32-n-(index&7) ));
    ptr[1] = 0;
//if(n>24) printf("%d %d\n", n, value);
    index+= n;
    s->index= index;
#        endif
#    endif //!ALIGNED_BITSTREAM_WRITER
}
#endif


unsigned int get_bits(GetBitContext *s, int n){
    register int tmp;
	OPEN_READER(re, s)
    UPDATE_CACHE(re, s)
    tmp= SHOW_UBITS(re, s, n);
    LAST_SKIP_BITS(re, s, n)
    CLOSE_READER(re, s)
    return tmp;
}

unsigned int show_bits(GetBitContext *s, int n){
    register int tmp;
    OPEN_READER(re, s)
    UPDATE_CACHE(re, s)
    tmp= SHOW_UBITS(re, s, n);
    CLOSE_READER(re, s)
    return tmp;
}

void skip_bits(GetBitContext *s, int n){
 //Note gcc seems to optimize this to s->index+=n for the ALT_READER :))
    OPEN_READER(re, s)
    UPDATE_CACHE(re, s)
    LAST_SKIP_BITS(re, s, n)
    CLOSE_READER(re, s)
}

unsigned int get_bits1(GetBitContext *s){
#ifdef ALT_BITSTREAM_READER
    int index= s->index;
    uint8_t result= s->buffer[ index>>3 ];
#ifdef ALT_BITSTREAM_READER_LE
    result>>= (index&0x07);
    result&= 1;
#else
    result<<= (index&0x07);
    result>>= 8 - 1;
#endif
    index++;
    s->index= index;

    return result;
#else
    return get_bits(s, 1);
#endif
}


void skip_bits1(GetBitContext *s){
    skip_bits(s, 1);
}


unsigned int get_bits_long(GetBitContext *s, int n){
    if(n<=17) return get_bits(s, n);
    else{
#ifdef ALT_BITSTREAM_READER_LE
        int ret= get_bits(s, 16);
        return ret | (get_bits(s, n-16) << 16);
#else
        int ret= get_bits(s, 16) << (n-16);
        return ret | get_bits(s, n-16);
#endif
    }
}

int check_marker(GetBitContext *s, const char *msg)
{
    int bit= get_bits1(s);
    if(!bit)
        av_log(NULL, AV_LOG_INFO, "Marker bit missing %s\n", msg);

    return bit;
}

void init_get_bits(GetBitContext *s,
                   const uint8_t *buffer, int bit_size)
{
    int buffer_size= (bit_size+7)>>3;
    if(buffer_size < 0 || bit_size < 0) {
        buffer_size = bit_size = 0;
        buffer = NULL;
    }

    s->buffer= buffer;
    s->size_in_bits= bit_size;
    s->buffer_end= buffer + buffer_size;
#ifdef ALT_BITSTREAM_READER
    s->index=0;
#elif defined LIBMPEG2_BITSTREAM_READER
    s->buffer_ptr = (uint8_t*)((intptr_t)buffer&(~1));
    s->bit_count = 16 + 8*((intptr_t)buffer&1);
    skip_bits_long(s, 0);
#elif defined A32_BITSTREAM_READER
    s->buffer_ptr = (uint32_t*)((intptr_t)buffer&(~3));
    s->bit_count = 32 + 8*((intptr_t)buffer&3);
    skip_bits_long(s, 0);
#endif
}

void align_get_bits(GetBitContext *s)
{
    int n= (-get_bits_count(s)) & 7;
    if(n) skip_bits(s, n);
}

int get_vlc2(GetBitContext *s, VLC_TYPE (*table)[2],
                                  int bits, int max_depth)
{
    int code;

    OPEN_READER(re, s)
    UPDATE_CACHE(re, s)

    GET_VLC(code, re, s, table, bits, max_depth)

    CLOSE_READER(re, s)
    return code;
}

