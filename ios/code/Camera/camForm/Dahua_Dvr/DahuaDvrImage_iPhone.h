//
//  DahuaDvrImage_iPhone.h
//  home
//
//  Created by Han.zh on 2017/7/3.
//  Copyright © 2017年 Han.zhihong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceController.h"
#include "torgba.h"
#include "dahua_dvr.h"
#import "Objc_SaveImageMage.h"
#import "Objc_HostInfoMage.h"

@interface DahuaDvrImage_iPhone :UIImageView<UIGestureRecognizerDelegate>
{
    TagHostInfo* m_pHostInfo;
    TagDvrSession *tds;
    int nVideoPos;
    
    DWORD dwSacleTime;
    DWORD dwRotationTime;
    
    //ctrl PTZ switch
    boolean_t m_useCtrl;
    
}
- (void) setDahuaInfo:(TagDvrSession*)s :(TagHostInfo*)hostInfo :(int)VideoPos;
- (bool) setCtrlSwith:(boolean_t)b;
- (void)handleSwipe:(UISwipeGestureRecognizer *)sender;
- (void)rotatePiece:(UIRotationGestureRecognizer *)gestureRecognizer;
- (void)scalePiece:(UIPinchGestureRecognizer *)gestureRecognizer;
@end
