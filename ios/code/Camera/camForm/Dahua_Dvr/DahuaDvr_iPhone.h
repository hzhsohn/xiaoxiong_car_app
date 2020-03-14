//
//  DvrController.h
//  iPadClient
//
//  Created by sohn on 11-7-7.
//  Copyright 2011年 Pooea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceController.h"
#include "torgba.h"
#include "dahua_dvr.h"
#import "Objc_SaveImageMage.h"
#import "Objc_HostInfoMage.h"
#import "DahuaDvrImage_iPhone.h"

#define H264_STREAM_BUF					1048576
#define RECV_DATA_BUF					131072
#define RGB_BUF							720*576*3+3 //D1的帧大小
#define MAX_CAMERA_SHOW_AT_SAME_TME     1

@interface DahuaDvr_iPhone : DeviceController {
    __weak IBOutlet UILabel *lbStaus;
    __weak IBOutlet UILabel *lbData;
    __weak IBOutlet UITableView *tabCameraList;
    __weak IBOutlet DahuaDvrImage_iPhone *imgCameraShow;
    __weak IBOutlet UIButton *btnCutPhoto;
    __weak IBOutlet UIButton *btnPTZCtrl;
    
    //加载提示
    __weak IBOutlet UIView* viBgCamera;
    __weak IBOutlet UIActivityIndicatorView*indCamera;
    
    __weak IBOutlet UIButton *btnPTZ1;
    __weak IBOutlet UIButton *btnPTZ2;
    __weak IBOutlet UIButton *btnPTZ3;
    __weak IBOutlet UIButton *btnPTZ4;

    Objc_SaveImageMage      *m_saveImg;
    
    boolean_t m_bLoading;
    
    //是否重新连接
    bool isReconnect;
    bool isDisconnect;
    
    //逻辑变量
    NSTimer *timer;
    
    //大华DVR_Crack用到的逻辑变量
    bool bIsInit;
    TagDvrSession tds;
	Tag_H264_MutBuf *dvrData;
	Tag_H264_MutBuf *rgbData;
    
    Tag_H264_NorBuf recvData;
    
    //当前频道
    short m_rCurChannel;
    
    //数据计时
    DWORD dwDataForSec;
    int sumDataForSec;
}

-(void)dataLoading:(boolean_t)b;

//启用禁用云台
-(IBAction)btnPTZCtrl_click:(id)sender;
-(IBAction)btnSavePhoto_click:(id)sender;
- (IBAction)btnMovePTZ_click:(id)sender;

//上下频道按钮
-(IBAction)btnMoveChannel_click:(id)sender;
-(void)changeChannel:(short)channel;

//设置DVR信息
-(void) dvrConnect;



@end
