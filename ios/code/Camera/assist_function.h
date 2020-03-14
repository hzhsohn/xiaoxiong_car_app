//
//  assist_function.h
//  monitor
//
//  Created by Han Sohn on 12-7-4.
//  Copyright (c) 2012年 Han.zhihong. All rights reserved.
//

#ifndef monitor_assist_function_h
#define monitor_assist_function_h

//time_t 转 "年-月-日 时:分:秒"
static char* trLongTimeToStr(time_t tme,char*dstString)
{
    struct tm *ptm = NULL;
    ptm = localtime(&tme);
    if(ptm) 
        sprintf(dstString, "%4d-%02d-%02d %02d:%02d:%02d", 
                (ptm->tm_year + 1900),
                ptm->tm_mon+1, 
                ptm->tm_mday,
                ptm->tm_hour, 
                ptm->tm_min,
                ptm->tm_sec);
    return dstString;
}

//"年-月-日 时:分:秒" 转 time_t
static time_t trStrToLongTime(char*szTime)
{
    struct tm tm1;
    time_t time1;
    memset(&tm1,0,sizeof(tm1));
    sscanf(szTime, "%4d-%02d-%02d %02d:%02d:%02d",
           &tm1.tm_year,&tm1.tm_mon,  &tm1.tm_mday, 
           &tm1.tm_hour, &tm1.tm_min, &tm1.tm_sec);         
    tm1.tm_year -= 1900;
    tm1.tm_mon --;
    tm1.tm_isdst=-1;
    time1 = mktime(&tm1);
    return time1;
}

static char* trBytes(unsigned long len,char*dst_buf)
{
    float f;
    if (len>=1024*1024*1024){
        f=len/(float)(1024*1024*1024);
        sprintf(dst_buf,"%0.1fGB",f);
    }
    else if (len>=1024*1024){
        f=len/(float)(1024*1024);
        sprintf(dst_buf,"%0.1fMB",f);
    }
    else  if (len>=100) {
        f=len/1024.0f;
        sprintf(dst_buf,"%0.1fKB",f);
    }
    else {
        sprintf(dst_buf,"%d B",(int)len);
    }
    
    return dst_buf;
}

/*
 char *sd="qq=123,bb=66,cc";
 char dd[100];
 getParameterByString(sd,"bb",dd);
 printf("%s",dd);
 */

//字符串获取参数的函数
static bool getParameterByString(const char*str,const char*parameter,char*value)
{
    //format is "a=123,b=456"
#define SPLIT_1         ","
#define SPLIT_2         ":"
    bool bRet;
    char *pSplit,*pSplit2;
    char *pPara;
    char *p1,*p2;
    char *pszStr;
    int nStrLen;
    
    bRet=false;
    nStrLen=strlen(str);
    if (0==nStrLen) {
        return bRet;
    }
    
    pszStr=(char*)malloc(nStrLen+1);
    memset(pszStr, 0, nStrLen+1);
    strcpy(pszStr,str);
    
    pPara=strtok_r(pszStr,SPLIT_1, &pSplit);
    
    do{
        p1=strtok_r(pPara, SPLIT_2, &pSplit2);
        p2=strtok_r(NULL, SPLIT_2, &pSplit2);
        printf("p1->p2   %s->%s\n",p1,p2);
        if (strstr(parameter, p1)) {
            if (p2) {
                strcpy(value, p2);
                bRet=true;
            }
            break;
        }
    }while ((pPara=strtok_r(NULL,SPLIT_1, &pSplit)));
    
    free(pszStr);
    pszStr=NULL;
    
    return bRet;
}


#endif
