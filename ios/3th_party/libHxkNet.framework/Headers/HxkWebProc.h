///////////////////////////  .h  //////////////////////////////////////
//
//  WebProc.h
//
//  Created by Han Sohn on 12-9-5.
//  Copyright (c) 2012年 Han.zhihong. All rights reserved.
//


#import <Foundation/Foundation.h>


@protocol HxkWebPocDelegate <NSObject>

-(void) HxkWebProcBegin_cb:(NSURL*)url;
-(void) HxkWebProcCookies_cb:(NSURL*)url :(NSString*)cookie;
-(void) HxkWebProcData_cb:(NSURL*)url :(NSData*)data;
-(void) HxkWebProcFail_cb:(NSURL*)url;

@end

@interface HxkWebProc : NSObject
{
    NSMutableData *m_btImgData;
    int m_nRecvTotal;
    int m_nByteTotal;
    bool m_bResponse;
}

@property (nonatomic,assign) id<HxkWebPocDelegate> delegate;

-(void) requestData:(NSString*)url parameter:(NSString*)pram;
-(void) requestData:(NSString*)url parameter:(NSString*)pram cookies:(NSString*)cookie;
//获取纯UTF8内容的JSON结构DATA
-(NSData*)getSafeJsonData:(NSData*)data;
-(BOOL) isNotFoundPage:(NSString*)str;

@end
