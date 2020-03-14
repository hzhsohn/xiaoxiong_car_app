//
//  mobotixInterface.h
//  PooeaMonitor
//
//  Created by sohn on 11-10-9.
//  Copyright 2011年 Pooea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceController.h"
#import "mobotix.h"
#import "Objc_HostInfoMage.h"
#import "Objc_SaveImageMage.h"

@interface Mobotix_iPhone : DeviceController {
    IBOutlet UILabel* lbStatus;
    IBOutlet UILabel* lbStatusText;
    IBOutlet UILabel* lbStatusText2;
    IBOutlet UIView* viLoading;
    IBOutlet UIActivityIndicatorView* indLoading;
    IBOutlet UIImageView* viImg;
    NSTimer *timer;
    
    Objc_SaveImageMage      *m_saveImg;
    
    TagMjpg_Mobotix *m_Mjpg;
    //connect status
    bool m_bConnecting;
    bool m_bDisconnected;
    int m_getBegin;
    
    int m_showStatus;
    
    TYPE_CS m_cs;
    
    //计算每秒数据
    unsigned long m_dwDataCul;
    unsigned long m_dwDataCulTime;
}

-(void) connectFail;
-(void) connectOK;

//connect thread
-(void) mobotixConnectThread;

- (void) viewDidAppear:(BOOL)animated;
- (void) viewDidDisappear:(BOOL)animated;
- (void) handleTimer: (NSTimer *) timer;

-(void) ConnectMjpeg;
-(void) mobotix_stream_filter:(TagMjpg_Mobotix*)mjpg:(char *)btBuf:(int) nSize;
-(void) mobotix_thread:(TagMjpg_Mobotix *)mjpg;
-(void) draw:(unsigned char*)data:(int)len;

//save picture
-(IBAction)btnScreenshot_click:(id)sender;
@end
