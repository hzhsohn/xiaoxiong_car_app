//
//  c_base64.h
//  PooeaMonitor
//
//  Created by sohn on 11-9-6.
//  Copyright 2011年 Pooea. All rights reserved.
//

#include "c_base64.h"

long int base64_encode( char *src,long int src_len, char *dst)
{
    long int i = 0, j = 0;
    //  printf("%ld\n",src[2]);
    char base64_map[65] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    for (; i < src_len - src_len % 3; i += 3) {
        
        //printf("%ld\n",(unsigned char)src[i]);
        //getchar();
        dst[j++] = base64_map[(src[i] >> 2) & 0x3F];
        dst[j++] = base64_map[((src[i] << 4) & 0x30) + ((src[i + 1] >> 4) & 0xF)];
        dst[j++] = base64_map[((src[i + 1] << 2) & 0x3C) + ((src[i + 2] >> 6) & 0x3)];
        dst[j++] = base64_map[src[i + 2] & 0x3F];
        //printf("%d",dst[j]);
    }
    if (src_len % 3 == 1) {
        dst[j++] = base64_map[(src[i] >> 2) & 0x3F];
        dst[j++] = base64_map[(src[i] << 4) & 0x30];
        dst[j++] = '=';
        dst[j++] = '=';
    }
    else if (src_len % 3 == 2) {
        dst[j++] = base64_map[(src[i] >> 2) & 0x3F];
        dst[j++] = base64_map[((src[i] << 4) & 0x30) + ((src[i + 1] >> 4) & 0xF)];
        dst[j++] = base64_map[(src[i + 1] << 2) & 0x3C];
        dst[j++] = '=';
    }
    
    dst[j] = '\0';
    printf("newlength:%ld\n",j);
    
    return j;
}

long int base64_decode(char *src, long int src_len, char *dst)
{
    
    long    int i = 0, j = 0;
    
    unsigned char base64_base64_decode_map[256] = {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 62, -1, -1, -1, 63,52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -1, -1, -1, -1, -1, -1,-1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14,15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -1, -1, -1, -1, -1,-1, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -1, -1, -1, -1, -1};
    for (; i < src_len; i+=4) {
        dst[j++] = base64_base64_decode_map[src[i]] << 2 |
        base64_base64_decode_map[src[i + 1]] >> 4;
        dst[j++] = base64_base64_decode_map[src[i + 1]] << 4 |
        base64_base64_decode_map[src[i + 2]] >> 2;
        dst[j++] = base64_base64_decode_map[src[i + 2]] << 6 |
        base64_base64_decode_map[src[i + 3]];
    }
    j-=2;
    dst[j] = '\0';
    printf("base64_decode length :%ld\n",j);
    return j;
}

