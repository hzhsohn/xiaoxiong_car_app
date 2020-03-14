/*
 * AVOptions
 * Copyright (c) 2005 Michael Niedermayer <michaelni@gmx.at>
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
 * @file opt.c
 * AVOptions
 * @author Michael Niedermayer <michaelni@gmx.at>
 */

#include "avcodec.h"
#include "opt.h"
#include "eval.h"
#include <stdio.h>
#include "define.h"
#include <limits.h>

//FIXME order them and do a bin search
const AVOption *av_find_opt(void *v, const char *name, const char *unit, int mask, int flags){
    AVClass *c= *(AVClass**)v; //FIXME silly way of storing AVClass
    const AVOption *o= c->option;

    for(;o && o->name; o++){
        if(!strcmp(o->name, name) && (!unit || (o->unit && !strcmp(o->unit, unit))) && (o->flags & mask) == flags )
            return o;
    }
    return NULL;
}

const AVOption *av_next_option(void *obj, const AVOption *last){
    if(last && last[1].name) return ++last;
    else if(last)            return NULL;
    else                     return (*(AVClass**)obj)->option;
}

//static const AVOption *av_set_number(void *obj, const char *name, double num, int den, int64_t intnum){
//    const AVOption *o= av_find_opt(obj, name, NULL, 0, 0);
//    void *dst;
//    if(!o || o->offset<=0)
//        return NULL;
//
//    if(o->max*den < num*intnum || o->min*den > num*intnum) {
//        av_log(NULL, AV_LOG_ERROR, "Value %lf for parameter '%s' out of range.\n", num, name);
//        return NULL;
//    }
//
//    dst= ((uint8_t*)obj) + o->offset;
//
//    switch(o->type){
//    case FF_OPT_TYPE_FLAGS:
//    case FF_OPT_TYPE_INT:   *(int       *)dst= llrint(num/den)*intnum; break;
//    case FF_OPT_TYPE_INT64: *(int64_t   *)dst= llrint(num/den)*intnum; break;
//    case FF_OPT_TYPE_FLOAT: *(float     *)dst= num*intnum/den;         break;
//    case FF_OPT_TYPE_DOUBLE:*(double    *)dst= num*intnum/den;         break;
//    case FF_OPT_TYPE_RATIONAL:
//        if((int)num == num) *(AVRational*)dst= (AVRational){num*intnum, den};
//        else                *(AVRational*)dst= av_d2q(num*intnum/den, 1<<24);
//        break;
//    default:
//        return NULL;
//    }
//    return o;
//}
//
//static const AVOption *set_all_opt(void *v, const char *unit, double d){
//    AVClass *c= *(AVClass**)v; //FIXME silly way of storing AVClass
//    const AVOption *o= c->option;
//    const AVOption *ret=NULL;
//
//    for(;o && o->name; o++){
//        if(o->type != FF_OPT_TYPE_CONST && o->unit && !strcmp(o->unit, unit)){
//            double tmp= d;
//            if(o->type == FF_OPT_TYPE_FLAGS)
//                tmp= av_get_int(v, o->name, NULL) | (int64_t)d;
//
//            av_set_number(v, o->name, tmp, 1, 1);
//            ret= o;
//        }
//    }
//    return ret;
//}
//
//static double const_values[]={
//    M_PI,
//    M_E,
//    FF_QP2LAMBDA,
//    0
//};
//
//static const char *const_names[]={
//    "PI",
//    "E",
//    "QP2LAMBDA",
//    0
//};
//
//static int hexchar2int(char c) {
//    if (c >= '0' && c <= '9') return c - '0';
//    if (c >= 'a' && c <= 'f') return c - 'a' + 10;
//    if (c >= 'A' && c <= 'F') return c - 'A' + 10;
//    return -1;
//}
//
//const AVOption *av_set_string(void *obj, const char *name, const char *val){
//    const AVOption *o= av_find_opt(obj, name, NULL, 0, 0);
//    if(o && o->offset==0 && o->type == FF_OPT_TYPE_CONST && o->unit){
//        return set_all_opt(obj, o->unit, o->default_val);
//    }
//    if(!o || !val || o->offset<=0)
//        return NULL;
//    if(o->type == FF_OPT_TYPE_BINARY){
//        uint8_t **dst = (uint8_t **)(((uint8_t*)obj) + o->offset);
//        int *lendst = (int *)(dst + 1);
//        uint8_t *bin, *ptr;
//        int len = strlen(val);
//        av_freep(dst);
//        *lendst = 0;
//        if (len & 1) return NULL;
//        len /= 2;
//        ptr = bin = av_malloc(len);
//        while (*val) {
//            int a = hexchar2int(*val++);
//            int b = hexchar2int(*val++);
//            if (a < 0 || b < 0) {
//                av_free(bin);
//                return NULL;
//            }
//            *ptr++ = (a << 4) | b;
//        }
//        *dst = bin;
//        *lendst = len;
//        return o;
//    }
//    if(o->type != FF_OPT_TYPE_STRING){
//        int notfirst=0;
//        for(;;){
//            int i;
//            char buf[256];
//            int cmd=0;
//            double d;
//            const char *error = NULL;
//
//            if(*val == '+' || *val == '-')
//                cmd= *(val++);
//
//            for(i=0; i<sizeof(buf)-1 && val[i] && val[i]!='+' && val[i]!='-'; i++)
//                buf[i]= val[i];
//            buf[i]=0;
//
//            d = ff_eval2(buf, const_values, const_names, NULL, NULL, NULL, NULL, NULL, &error);
//            if(isnan(d)) {
//                const AVOption *o_named= av_find_opt(obj, buf, o->unit, 0, 0);
//                if(o_named && o_named->type == FF_OPT_TYPE_CONST)
//                    d= o_named->default_val;
//                else if(!strcmp(buf, "default")) d= o->default_val;
//                else if(!strcmp(buf, "max"    )) d= o->max;
//                else if(!strcmp(buf, "min"    )) d= o->min;
//                else if(!strcmp(buf, "none"   )) d= 0;
//                else if(!strcmp(buf, "all"    )) d= ~0;
//                else {
//                    if (error)
//                        av_log(NULL, AV_LOG_ERROR, "Unable to parse option value \"%s\": %s\n", val, error);
//                    return NULL;
//                }
//            }
//            if(o->type == FF_OPT_TYPE_FLAGS){
//                if     (cmd=='+') d= av_get_int(obj, name, NULL) | (int64_t)d;
//                else if(cmd=='-') d= av_get_int(obj, name, NULL) &~(int64_t)d;
//            }else{
//                if     (cmd=='+') d= notfirst*av_get_double(obj, name, NULL) + d;
//                else if(cmd=='-') d= notfirst*av_get_double(obj, name, NULL) - d;
//            }
//
//            if (!av_set_number(obj, name, d, 1, 1))
//                return NULL;
//            val+= i;
//            if(!*val)
//                return o;
//            notfirst=1;
//        }
//        return NULL;
//    }
//
//    memcpy(((uint8_t*)obj) + o->offset, &val, sizeof(val));
//    return o;
//}
//
const AVOption *av_set_double(void *obj, const char *name, double n){
//    return av_set_number(obj, name, n, 1, 1);
	return 0;
}
//
//static AVOption *AVNULL = 0;
const AVOption *av_set_q(void *obj, const char *name, AVRational n){
//    return av_set_number(obj, name, n.num, n.den, 1);
	return 0;
}
//
const AVOption *av_set_int(void *obj, const char *name, int64_t n){
//    return av_set_number(obj, name, 1, 1, n);
	return 0;
}
//

///** Set the values of the AVCodecContext or AVFormatContext structure.
// * They are set to the defaults specified in the according AVOption options
// * array default_val field.
// *
// * @param s AVCodecContext or AVFormatContext for which the defaults will be set
// */
void av_opt_set_defaults2(void *s, int mask, int flags)
{
    const AVOption *opt = NULL;
    while ((opt = av_next_option(s, opt)) != NULL) {
        if((opt->flags & mask) != flags)
            continue;
        switch(opt->type) {
            case FF_OPT_TYPE_CONST:
                /* Nothing to be done here */
            break;
            case FF_OPT_TYPE_FLAGS:
            case FF_OPT_TYPE_INT: {
                int val;
                val = (int)opt->default_val;
                av_set_int(s, opt->name, val);
            }
            break;
            case FF_OPT_TYPE_FLOAT: {
                double val;
                val = opt->default_val;
                av_set_double(s, opt->name, val);
            }
            break;
            case FF_OPT_TYPE_RATIONAL: {
                AVRational val;
                val = av_d2q(opt->default_val, INT_MAX);
                av_set_q(s, opt->name, val);
            }
            break;
            case FF_OPT_TYPE_STRING:
            case FF_OPT_TYPE_BINARY:
                /* Cannot set default for string as default_val is of type * double */
            break;
            default:
                av_log(s, AV_LOG_DEBUG, "AVOption type %d of option %s not implemented yet\n", opt->type, opt->name);
        }
    }
}
//
//void av_opt_set_defaults(void *s){
//    av_opt_set_defaults2(s, 0, 0);
//}
//
