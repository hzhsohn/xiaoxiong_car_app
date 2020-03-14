/*
 
 2009ƒÍ7‘¬20
 
 Sohn-∫´÷«∫Ë
 
 E-Mail:sohn@163.com
 
 ¿‡÷˜“™π¶ƒ‹£∫µ˜ ‘
 
 */

#ifndef __G_DAHUA_PLATFORM_H__
#define __G_DAHUA_PLATFORM_H__

#ifndef __cplusplus
#ifndef bool
typedef unsigned char bool;
#define true	1
#define false	0
#endif
#endif

#ifdef __cplusplus
extern "C"{
#endif
    
#include <stdio.h>
#include <stdarg.h>
#include <memory.h>
#include <string.h>
#include <time.h>
    
#ifdef _WIN32
#pragma warning(disable: 4996)
#pragma warning(disable: 4172)
#endif
    
#ifdef WIN32
#include <windows.h>
#undef _countof
#define _countof(array) (sizeof(array)/sizeof(array[0]))
#define VSNPRINTF(a,b,c,d) _vsnprintf(a,b,c,d)
    
    /* thread operate*/
#define CREATE_THREAD(func,arg)		CreateThread(NULL,0,(LPTHREAD_START_ROUTINE)func,(LPVOID)arg,0,NULL)
#define CREATE_THREAD_RET(ret)		((ret)==0)
#define LOCK_CS(p)					EnterCriticalSection(p)
#define UNLOCK_CS(p)				LeaveCriticalSection(p)
#define INIT_CS(p)					InitializeCriticalSection(p)
#define DELETE_CS(p)				DeleteCriticalSection(p)
#define TYPE_CS						CRITICAL_SECTION
    
#define	ZH_INLINE					__inline
#else
#define LINUX
#include <sys/time.h>
#include <stddef.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/wait.h>
    //#define BOOL int
#define BYTE unsigned char
#define WORD unsigned short
#ifndef DWORD
#define DWORD unsigned long
#endif
#define TRUE  1
#define FALSE 0
    
#define VSNPRINTF(a,b,c,d) vsnprintf(a,b,c,d)
    /* thread operate */
#include <pthread.h>
#include <semaphore.h>
    extern pthread_t _pthreadid;
#define CREATE_THREAD(func,arg)		pthread_create(&_pthreadid,NULL,(void *(*)(void *))func,(void*)arg)
#define CREATE_THREAD_RET(ret)		((ret)!=0)
#define LOCK_CS(p)					sem_wait(p)
#define UNLOCK_CS(p)				sem_post(p)
#define INIT_CS(p)					sem_init(p,0,1)
#define DELETE_CS(p)				sem_destroy(p)
#define TYPE_CS						sem_t
    
#define	ZH_INLINE					inline
#endif
    
    void Sys_Sleep(int ms);
    DWORD Sys_GetTime();
    DWORD Sys_GetSec();
    void Sys_CreateConsole();
    void Sys_FreeConsole();
    void Sys_print(char*format,...);
    void Sys_print16(int len,char*buf);
    
#ifdef __cplusplus
}
#endif
#endif
