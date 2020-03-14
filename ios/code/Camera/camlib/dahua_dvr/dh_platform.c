#include "dh_platform.h"

#ifndef WIN32
pthread_t _pthreadid;
#endif

DWORD Sys_GetTime()
{
#ifndef WIN32
    /* linux */
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return (tv.tv_sec*1000+tv.tv_usec/1000);
#else
    return GetTickCount();
#endif
}

DWORD Sys_GetSec()
{
    return (unsigned long)time(NULL);
}

void Sys_Sleep(int ms)
{
#ifdef WIN32
    Sleep(ms);
#else
    /* linux */
    usleep(ms*1000);
#endif
}

//////////////////////////////////////////////////////////
//debug function
void Sys_CreateConsole(char*title)
{
#ifdef WIN32
    HANDLE hStdOut;
    COORD co;
    AllocConsole();
    SetConsoleTitleA(title);
    hStdOut = GetStdHandle(STD_OUTPUT_HANDLE);
    co.X=0;
    co.Y=0;
    SetConsoleScreenBufferSize(hStdOut, co);
    freopen("CONOUT$","w+t",stdout);
    freopen("CONIN$","r+t",stdin);
#endif
}

void Sys_FreeConsole()
{
#ifdef WIN32
    FreeConsole();
#endif
}
// ‰≥ˆ–≈œ¢
void Sys_print(char*format,...)
{
    char buf[256];
    va_list args;
    va_start(args, format);
    
    VSNPRINTF(buf,256,format,args);
   	printf("%s\r\n",buf);
    
    // write to file
    va_end(args);
}

void Sys_print16(int len,char*buf)
{
    int i;
    for(i =0;i<len;i++)
        printf("%02X ",(BYTE)buf[i]);
    printf("\r\n");
}
