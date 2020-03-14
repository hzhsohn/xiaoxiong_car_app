/*
 * copyright (c) 2004 Michael Niedermayer <michaelni@gmx.at>
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
 * @file bitstream.h
 * bitstream api header.
 */

#ifndef FFMPEG_BITSTREAM_H
#define FFMPEG_BITSTREAM_H

#include <stdlib.h>
#include <assert.h>
#include "bswap.h"
#include "common.h"
#include "intreadwrite.h"
#include "log.h"

#if defined(ALT_BITSTREAM_READER_LE) && !defined(ALT_BITSTREAM_READER)
#   define ALT_BITSTREAM_READER
#endif

//#define ALT_BITSTREAM_WRITER
//#define ALIGNED_BITSTREAM_WRITER
#if !defined(LIBMPEG2_BITSTREAM_READER) && !defined(A32_BITSTREAM_READER) && !defined(ALT_BITSTREAM_READER)
#   ifdef ARCH_ARMV4L
#       define A32_BITSTREAM_READER
#   else
#       define ALT_BITSTREAM_READER
//#define LIBMPEG2_BITSTREAM_READER
//#define A32_BITSTREAM_READER
#   endif
#endif
#define LIBMPEG2_BITSTREAM_READER_HACK //add BERO

extern const uint8_t ff_reverse[256];

#if defined(ARCH_X86)
// avoid +32 for shift optimization (gcc should do that ...)
int32_t NEG_SSR32( int32_t a, int8_t s);
uint32_t NEG_USR32(uint32_t a, int8_t s);
#else
#    define NEG_SSR32(a,s) ((( int32_t)(a))>>(32-(s)))
#    define NEG_USR32(a,s) (((uint32_t)(a))>>(32-(s)))
#endif

/* bit output */

/* buf and buf_end must be present and used by every alternative writer. */
typedef struct PutBitContext {
#ifdef ALT_BITSTREAM_WRITER
    uint8_t *buf, *buf_end;
    int index;
#else
    uint32_t bit_buf;
    int bit_left;
    uint8_t *buf, *buf_ptr, *buf_end;
#endif
} PutBitContext;

void init_put_bits(PutBitContext *s, uint8_t *buffer, int buffer_size);
/* return the number of bits output */
int put_bits_count(PutBitContext *s);

/* pad the end of the output stream with zeros */
void flush_put_bits(PutBitContext *s);

/* bit input */
/* buffer, buffer_end and size_in_bits must be present and used by every reader */
typedef struct GetBitContext {
    const uint8_t *buffer, *buffer_end;
#ifdef ALT_BITSTREAM_READER
    int index;
#elif defined LIBMPEG2_BITSTREAM_READER
    uint8_t *buffer_ptr;
    uint32_t cache;
    int bit_count;
#elif defined A32_BITSTREAM_READER
    uint32_t *buffer_ptr;
    uint32_t cache0;
    uint32_t cache1;
    int bit_count;
#endif
    int size_in_bits;
} GetBitContext;

#define VLC_TYPE int16_t

typedef struct VLC {
    int bits;
    VLC_TYPE (*table)[2]; ///< code, bits
    int table_size, table_allocated;
} VLC;

typedef struct RL_VLC_ELEM {
    int16_t level;
    int8_t len;
    uint8_t run;
} RL_VLC_ELEM;

#if defined(ARCH_SPARC) || defined(ARCH_ARMV4L) || defined(ARCH_MIPS) || defined(ARCH_BFIN)
#define UNALIGNED_STORES_ARE_BAD
#endif

/* used to avoid misaligned exceptions on some archs (alpha, ...) */
#if defined(ARCH_X86)
#    define unaligned16(a) (*(const uint16_t*)(a))
#    define unaligned32(a) (*(const uint32_t*)(a))
#    define unaligned64(a) (*(const uint64_t*)(a))
#else
#    ifdef __GNUC__
#    define unaligned(x)                                \
static inline uint##x##_t unaligned##x(const void *v) { \
    struct Unaligned {                                  \
        uint##x##_t i;                                  \
    } __attribute__((packed));                          \
                                                        \
    return ((const struct Unaligned *) v)->i;           \
}
#    elif defined(__DECC)
#    define unaligned(x)                                        \
static inline uint##x##_t unaligned##x(const void *v) {         \
    return *(const __unaligned uint##x##_t *) v;                \
}
#    else
#    define unaligned(x)                                        \
static inline uint##x##_t unaligned##x(const void *v) {         \
    return *(const uint##x##_t *) v;                            \
}
#    endif
unaligned(16)
unaligned(32)
unaligned(64)
#undef unaligned
#endif /* defined(ARCH_X86) */

#ifndef ALT_BITSTREAM_WRITER
void put_bits(PutBitContext *s, int n, unsigned int value);
#else
void put_bits(PutBitContext *s, int n, unsigned int value);
#endif


/* Bitstream reader API docs:
name
    abritary name which is used as prefix for the internal variables

gb
    getbitcontext

OPEN_READER(name, gb)
    loads gb into local variables

CLOSE_READER(name, gb)
    stores local vars in gb

UPDATE_CACHE(name, gb)
    refills the internal cache from the bitstream
    after this call at least MIN_CACHE_BITS will be available,

GET_CACHE(name, gb)
    will output the contents of the internal cache, next bit is MSB of 32 or 64 bit (FIXME 64bit)

SHOW_UBITS(name, gb, num)
    will return the next num bits

SHOW_SBITS(name, gb, num)
    will return the next num bits and do sign extension

SKIP_BITS(name, gb, num)
    will skip over the next num bits
    note, this is equivalent to SKIP_CACHE; SKIP_COUNTER

SKIP_CACHE(name, gb, num)
    will remove the next num bits from the cache (note SKIP_COUNTER MUST be called before UPDATE_CACHE / CLOSE_READER)

SKIP_COUNTER(name, gb, num)
    will increment the internal bit counter (see SKIP_CACHE & SKIP_BITS)

LAST_SKIP_CACHE(name, gb, num)
    will remove the next num bits from the cache if it is needed for UPDATE_CACHE otherwise it will do nothing

LAST_SKIP_BITS(name, gb, num)
    is equivalent to SKIP_LAST_CACHE; SKIP_COUNTER

for examples see get_bits, show_bits, skip_bits, get_vlc
*/

#ifdef ALT_BITSTREAM_READER
#   define MIN_CACHE_BITS 25

#   define OPEN_READER(name, gb)\
        int name##_index= (gb)->index;\
        int name##_cache= 0;\

#   define CLOSE_READER(name, gb)\
        (gb)->index= name##_index;\

# ifdef ALT_BITSTREAM_READER_LE
#   define UPDATE_CACHE(name, gb)\
        name##_cache= AV_RL32( ((const uint8_t *)(gb)->buffer)+(name##_index>>3) ) >> (name##_index&0x07);\

#   define SKIP_CACHE(name, gb, num)\
        name##_cache >>= (num);
# else
#   define UPDATE_CACHE(name, gb)\
		if((gb)->buffer){\
		name##_cache= AV_RB32( ((const uint8_t *)(gb)->buffer)+(name##_index>>3) ) << (name##_index&0x07);}\

#   define SKIP_CACHE(name, gb, num)\
        name##_cache <<= (num);
# endif

// FIXME name?
#   define SKIP_COUNTER(name, gb, num)\
        name##_index += (num);\

#   define SKIP_BITS(name, gb, num)\
        {\
            SKIP_CACHE(name, gb, num)\
            SKIP_COUNTER(name, gb, num)\
        }\

#   define LAST_SKIP_BITS(name, gb, num) SKIP_COUNTER(name, gb, num)
#   define LAST_SKIP_CACHE(name, gb, num) ;

# ifdef ALT_BITSTREAM_READER_LE
#   define SHOW_UBITS(name, gb, num)\
        ((name##_cache) & (NEG_USR32(0xffffffff,num)))

#   define SHOW_SBITS(name, gb, num)\
        NEG_SSR32((name##_cache)<<(32-(num)), num)
# else
#   define SHOW_UBITS(name, gb, num)\
        NEG_USR32(name##_cache, num)

#   define SHOW_SBITS(name, gb, num)\
        NEG_SSR32(name##_cache, num)
# endif

#   define GET_CACHE(name, gb)\
        ((uint32_t)name##_cache)

static inline int get_bits_count(GetBitContext *s){
    return s->index;
}

static inline void skip_bits_long(GetBitContext *s, int n){
    s->index += n;
}

#elif defined LIBMPEG2_BITSTREAM_READER
//libmpeg2 like reader

#   define MIN_CACHE_BITS 17

#   define OPEN_READER(name, gb)\
        int name##_bit_count=(gb)->bit_count;\
        int name##_cache= (gb)->cache;\
        uint8_t * name##_buffer_ptr=(gb)->buffer_ptr;\

#   define CLOSE_READER(name, gb)\
        (gb)->bit_count= name##_bit_count;\
        (gb)->cache= name##_cache;\
        (gb)->buffer_ptr= name##_buffer_ptr;\

#ifdef LIBMPEG2_BITSTREAM_READER_HACK

#   define UPDATE_CACHE(name, gb)\
    if(name##_bit_count >= 0){\
        name##_cache+= (int)be2me_16(*(uint16_t*)name##_buffer_ptr) << name##_bit_count;\
        name##_buffer_ptr += 2;\
        name##_bit_count-= 16;\
    }\

#else

#   define UPDATE_CACHE(name, gb)\
    if(name##_bit_count >= 0){\
        name##_cache+= ((name##_buffer_ptr[0]<<8) + name##_buffer_ptr[1]) << name##_bit_count;\
        name##_buffer_ptr+=2;\
        name##_bit_count-= 16;\
    }\

#endif

#   define SKIP_CACHE(name, gb, num)\
        name##_cache <<= (num);\

#   define SKIP_COUNTER(name, gb, num)\
        name##_bit_count += (num);\

#   define SKIP_BITS(name, gb, num)\
        {\
            SKIP_CACHE(name, gb, num)\
            SKIP_COUNTER(name, gb, num)\
        }\

#   define LAST_SKIP_BITS(name, gb, num) SKIP_BITS(name, gb, num)
#   define LAST_SKIP_CACHE(name, gb, num) SKIP_CACHE(name, gb, num)

#   define SHOW_UBITS(name, gb, num)\
        NEG_USR32(name##_cache, num)

#   define SHOW_SBITS(name, gb, num)\
        NEG_SSR32(name##_cache, num)

#   define GET_CACHE(name, gb)\
        ((uint32_t)name##_cache)

static inline int get_bits_count(GetBitContext *s){
    return (s->buffer_ptr - s->buffer)*8 - 16 + s->bit_count;
}

static inline void skip_bits_long(GetBitContext *s, int n){
    OPEN_READER(re, s)
    re_bit_count += n;
    re_buffer_ptr += 2*(re_bit_count>>4);
    re_bit_count &= 15;
    re_cache = ((re_buffer_ptr[-2]<<8) + re_buffer_ptr[-1]) << (16+re_bit_count);
    UPDATE_CACHE(re, s)
    CLOSE_READER(re, s)
}

#elif defined A32_BITSTREAM_READER

#   define MIN_CACHE_BITS 32

#   define OPEN_READER(name, gb)\
        int name##_bit_count=(gb)->bit_count;\
        uint32_t name##_cache0= (gb)->cache0;\
        uint32_t name##_cache1= (gb)->cache1;\
        uint32_t * name##_buffer_ptr=(gb)->buffer_ptr;\

#   define CLOSE_READER(name, gb)\
        (gb)->bit_count= name##_bit_count;\
        (gb)->cache0= name##_cache0;\
        (gb)->cache1= name##_cache1;\
        (gb)->buffer_ptr= name##_buffer_ptr;\

#   define UPDATE_CACHE(name, gb)\
    if(name##_bit_count > 0){\
        const uint32_t next= be2me_32( *name##_buffer_ptr );\
        name##_cache0 |= NEG_USR32(next,name##_bit_count);\
        name##_cache1 |= next<<name##_bit_count;\
        name##_buffer_ptr++;\
        name##_bit_count-= 32;\
    }\

#if defined(ARCH_X86)
#   define SKIP_CACHE(name, gb, num)\
        asm(\
            "shldl %2, %1, %0          \n\t"\
            "shll %2, %1               \n\t"\
            : "+r" (name##_cache0), "+r" (name##_cache1)\
            : "Ic" ((uint8_t)(num))\
           );
#else
#   define SKIP_CACHE(name, gb, num)\
        name##_cache0 <<= (num);\
        name##_cache0 |= NEG_USR32(name##_cache1,num);\
        name##_cache1 <<= (num);
#endif

#   define SKIP_COUNTER(name, gb, num)\
        name##_bit_count += (num);\

#   define SKIP_BITS(name, gb, num)\
        {\
            SKIP_CACHE(name, gb, num)\
            SKIP_COUNTER(name, gb, num)\
        }\

#   define LAST_SKIP_BITS(name, gb, num) SKIP_BITS(name, gb, num)
#   define LAST_SKIP_CACHE(name, gb, num) SKIP_CACHE(name, gb, num)

#   define SHOW_UBITS(name, gb, num)\
        NEG_USR32(name##_cache0, num)

#   define SHOW_SBITS(name, gb, num)\
        NEG_SSR32(name##_cache0, num)

#   define GET_CACHE(name, gb)\
        (name##_cache0)

static inline int get_bits_count(GetBitContext *s){
    return ((uint8_t*)s->buffer_ptr - s->buffer)*8 - 32 + s->bit_count;
}

static inline void skip_bits_long(GetBitContext *s, int n){
    OPEN_READER(re, s)
    re_bit_count += n;
    re_buffer_ptr += re_bit_count>>5;
    re_bit_count &= 31;
    re_cache0 = be2me_32( re_buffer_ptr[-1] ) << re_bit_count;
    re_cache1 = 0;
    UPDATE_CACHE(re, s)
    CLOSE_READER(re, s)
}

#endif


/**
 * reads 1-17 bits.
 * Note, the alt bitstream reader can read up to 25 bits, but the libmpeg2 reader can't
 */
unsigned int get_bits(GetBitContext *s, int n);

/**
 * shows 1-17 bits.
 * Note, the alt bitstream reader can read up to 25 bits, but the libmpeg2 reader can't
 */
unsigned int show_bits(GetBitContext *s, int n);

void skip_bits(GetBitContext *s, int n);

unsigned int get_bits1(GetBitContext *s);

void skip_bits1(GetBitContext *s);

/**
 * reads 0-32 bits.
 */
unsigned int get_bits_long(GetBitContext *s, int n);

/**
 * shows 0-32 bits.
 */
static inline unsigned int show_bits_long(GetBitContext *s, int n){
    if(n<=17) return show_bits(s, n);
    else{
        GetBitContext gb= *s;
        int ret= get_bits_long(s, n);
        *s= gb;
        return ret;
    }
}

int check_marker(GetBitContext *s, const char *msg);

/**
 * init GetBitContext.
 * @param buffer bitstream buffer, must be FF_INPUT_BUFFER_PADDING_SIZE bytes larger then the actual read bits
 * because some optimized bitstream readers read 32 or 64 bit at once and could read over the end
 * @param bit_size the size of the buffer in bits
 */
void init_get_bits(GetBitContext *s,
                   const uint8_t *buffer, int bit_size);

void align_get_bits(GetBitContext *s);

#define init_vlc(vlc, nb_bits, nb_codes,\
                 bits, bits_wrap, bits_size,\
                 codes, codes_wrap, codes_size,\
                 flags)\
        init_vlc_sparse(vlc, nb_bits, nb_codes,\
                 bits, bits_wrap, bits_size,\
                 codes, codes_wrap, codes_size,\
                 NULL, 0, 0, flags)

int init_vlc_sparse(VLC *vlc, int nb_bits, int nb_codes,
             const void *bits, int bits_wrap, int bits_size,
             const void *codes, int codes_wrap, int codes_size,
             const void *symbols, int symbols_wrap, int symbols_size,
             int flags);
#define INIT_VLC_USE_STATIC 1 ///< VERY strongly deprecated and forbidden
#define INIT_VLC_LE         2
#define INIT_VLC_USE_NEW_STATIC 4
void free_vlc(VLC *vlc);

#define INIT_VLC_STATIC(vlc, bits, a,b,c,d,e,f,g, static_size)\
{\
    static VLC_TYPE table[static_size][2];\
    (vlc)->table= table;\
    (vlc)->table_allocated= static_size;\
    init_vlc(vlc, bits, a,b,c,d,e,f,g, INIT_VLC_USE_NEW_STATIC);\
}


/**
 *
 * if the vlc code is invalid and max_depth=1 than no bits will be removed
 * if the vlc code is invalid and max_depth>1 than the number of bits removed
 * is undefined
 */
#define GET_VLC(code, name, gb, table, bits, max_depth)\
{\
    int n, index, nb_bits;\
\
    index= SHOW_UBITS(name, gb, bits);\
    code = table[index][0];\
    n    = table[index][1];\
\
    if(max_depth > 1 && n < 0){\
        LAST_SKIP_BITS(name, gb, bits)\
        UPDATE_CACHE(name, gb)\
\
        nb_bits = -n;\
\
        index= SHOW_UBITS(name, gb, nb_bits) + code;\
        code = table[index][0];\
        n    = table[index][1];\
        if(max_depth > 2 && n < 0){\
            LAST_SKIP_BITS(name, gb, nb_bits)\
            UPDATE_CACHE(name, gb)\
\
            nb_bits = -n;\
\
            index= SHOW_UBITS(name, gb, nb_bits) + code;\
            code = table[index][0];\
            n    = table[index][1];\
        }\
    }\
    SKIP_BITS(name, gb, n)\
}

#define GET_RL_VLC(level, run, name, gb, table, bits, max_depth, need_update)\
{\
    int n, index, nb_bits;\
\
    index= SHOW_UBITS(name, gb, bits);\
    level = table[index].level;\
    n     = table[index].len;\
\
    if(max_depth > 1 && n < 0){\
        SKIP_BITS(name, gb, bits)\
        if(need_update){\
            UPDATE_CACHE(name, gb)\
        }\
\
        nb_bits = -n;\
\
        index= SHOW_UBITS(name, gb, nb_bits) + level;\
        level = table[index].level;\
        n     = table[index].len;\
    }\
    run= table[index].run;\
    SKIP_BITS(name, gb, n)\
}


/**
 * parses a vlc code, faster then get_vlc()
 * @param bits is the number of bits which will be read at once, must be
 *             identical to nb_bits in init_vlc()
 * @param max_depth is the number of times bits bits must be read to completely
 *                  read the longest vlc code
 *                  = (max_vlc_length + bits - 1) / bits
 */
int get_vlc2(GetBitContext *s, VLC_TYPE (*table)[2],
                                  int bits, int max_depth);




#endif /* FFMPEG_BITSTREAM_H */
