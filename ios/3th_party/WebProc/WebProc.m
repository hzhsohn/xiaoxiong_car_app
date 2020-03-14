//////////////////////////////  .m  ////////////////////////////////////
//  WebProc.m
//  lionsoa
//
//  Created by Han Sohn on 12-9-5.
//  Copyright (c) 2012年 Han.zhihong. All rights reserved.
//

#import "WebProc.h"

@implementation WebProc
@synthesize delegate;

-(id)init
{
    
    if((self=[super init]))
    {
        m_btImgData=[[NSMutableData alloc]init];
    }
    return self;
}

-(void)dealloc
{
    delegate=nil;
    [m_btImgData release];
    [super dealloc];
}

-(void) sendData:(NSString*)url parameter:(NSString*)pram
{
    [self sendData:url parameter:pram cookies:nil];
}

-(void) sendData:(NSString*)url parameter:(NSString*)pram cookies:(NSString*)cookie
{
    [m_btImgData resetBytesInRange:NSMakeRange(0, [m_btImgData length])];
    [m_btImgData setLength:0];
    m_nRecvTotal=0;
    m_nByteTotal=0;
    
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    //无视本地缓存
    request.cachePolicy=NSURLRequestReloadIgnoringLocalCacheData;
    //超时设置
    request.timeoutInterval = 10;
    
    if(cookie)
    {[request addValue:cookie forHTTPHeaderField:@"Cookie"];}
    
    //POST方式提交参数
    if (pram) {
        
        NSMutableData *postBody = [NSMutableData data];
        [request setHTTPMethod:@"POST"];
        [postBody appendData:[pram dataUsingEncoding: NSUTF8StringEncoding allowLossyConversion:YES]];
        [request setHTTPBody:postBody];
        
    }
    
    [delegate WebProcCallBackBegin: request.URL];
    
    NSURLConnection *conn=[[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    [conn start];
    [conn release];
    [request release];
    request=nil;
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    //NSLog(@"didReceiveResponse url=%@",[connection.originalRequest.URL relativeString]);
    
    [m_btImgData resetBytesInRange:NSMakeRange(0, [m_btImgData length])];
    [m_btImgData setLength:0];
    m_nRecvTotal=0;
    m_nByteTotal=0;
    
    //保存接收到的响应对象，以便响应完毕后的状态
    NSHTTPURLResponse *resp=(NSHTTPURLResponse *)response;
    m_bResponse=([resp statusCode]==200)?true:false;
    if (m_bResponse) {
        NSDictionary *respHeaderFields = [resp allHeaderFields];
        m_nByteTotal = [[respHeaderFields objectForKey:@"Content-Length"] intValue];
        
        NSString *cookie = [respHeaderFields valueForKey:@"Set-Cookie"]; // It is your cookie
        [delegate WebProcCallBackCookies:resp.URL :cookie];
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    //NSLog(@"didReceiveData url=%@",[connection.originalRequest.URL relativeString]);
    //_data为NSMutableData类型的私有属性，用于保存从网络上接收到的数据。
    //也可以从此委托中加载的进度
    m_nRecvTotal+=[data length];
    [m_btImgData appendData:data];
    
    //m_nRecvTotal接收了多少个字节 m_nByteTotal一共的字节数
    //可以在这回调打印下载进度
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
    //请求异常
    [delegate WebProcCallBackFail:connection.originalRequest.URL];
    
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection

{
    //加载成功，在此的加载成功并不代表图片加载成功，需要判断HTTP返回状态。
    //请求成功
    NSData *data=[NSData dataWithData:m_btImgData];
    [delegate WebProcCallBackData:connection.originalRequest.URL :data];
}

-(NSData*)getSafeJsonData:(NSData*)data
{
    NSData *safeJsonData=nil;
    //去除UTF8标记 EF BB BF
    NSData* da = nil;
    if([data length]>3)
    {
        char utf_h[]={0xEF,0xBB,0xBF};
        char* p=(char*)[data bytes];
        if (0==memcmp(p, utf_h, 3)) {
            da=[NSData dataWithBytes:p+3 length:[data length]-3];
        }
        else
        {da=data;}
    }
    else
    {da=data;}
    
    NSString *ss = [[NSString alloc] initWithData:da encoding:NSUTF8StringEncoding];
    if(ss)
    {
        char*uuu=(char*)[ss UTF8String];
        if(uuu)
        {
            size_t sslen=strlen(uuu);
            safeJsonData = [NSData dataWithBytes:uuu length:sslen];
            NSLog(@"json len=%ld,%@",sslen,ss);
        }
        ss=nil;
    }
    return safeJsonData;
}

-(BOOL)isNotFoundPage:(NSString*)str
{
    if(str==nil)
    {return FALSE;}
    //不存在页面
    NSRange range;
    range = [str rangeOfString:@"<html><head>\n<title>404 Not Found</title>"];
    if (range.location != NSNotFound) {
        NSLog(@"Not Found Page");
        return TRUE;
    }
    return FALSE;
}

@end
