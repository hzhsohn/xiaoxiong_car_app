//
//  DahuaDvrImage_iPhone.m
//  home
//
//  Created by Han.zh on 2017/7/3.
//  Copyright © 2017年 Han.zhihong. All rights reserved.
//

#import "DahuaDvrImage_iPhone.h"


@implementation DahuaDvrImage_iPhone

- (void)awakeFromNib {
    [super awakeFromNib];
    self.userInteractionEnabled=YES;
    m_useCtrl = false;
}

-(void) setDahuaInfo:(TagDvrSession*)s :(TagHostInfo*)hostInfo :(int)VideoPos
{
    tds=s;
    nVideoPos=VideoPos;
    m_pHostInfo=hostInfo;
    
    UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotatePiece:)];
    [self addGestureRecognizer:rotationGesture];
    rotationGesture=nil;
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scalePiece:)];
    [pinchGesture setDelegate:self];
    [self addGestureRecognizer:pinchGesture];
    pinchGesture=nil;
    
    //下面四个是判断上下左右的.
    UISwipeGestureRecognizer*r4 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    [r4 setDelegate:self];
    r4.direction=UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:r4];
    r4=nil;
    
    r4 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    [r4 setDelegate:self];
    r4.direction=UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:r4];
    r4=nil;
    
    r4 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    [r4 setDelegate:self];
    r4.direction=UISwipeGestureRecognizerDirectionUp;
    [self addGestureRecognizer:r4];
    r4=nil;
    
    r4 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    [r4 setDelegate:self];
    r4.direction=UISwipeGestureRecognizerDirectionDown;
    [self addGestureRecognizer:r4];
    r4=nil;
    
}
-(bool) setCtrlSwith:(boolean_t)b
{
    if(ZH_SetCtrl(tds,nVideoPos,b))
    {
        m_useCtrl=b;
        return true;
    }
    return false;
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)sender
{
    if (!m_useCtrl) {
        return;
    }
    
    NSLog(@"handleSwipe %ld",sender.direction);
    
    switch (sender.direction) {
        case UISwipeGestureRecognizerDirectionUp:
            ZH_DvrCtrl(tds,nVideoPos,ZH_DVR_CTRL_DOWN,1);
            break;
            
        case UISwipeGestureRecognizerDirectionDown:
            ZH_DvrCtrl(tds,nVideoPos,ZH_DVR_CTRL_UP,1);
            break;
            
        case UISwipeGestureRecognizerDirectionLeft:
            ZH_DvrCtrl(tds,nVideoPos,ZH_DVR_CTRL_RIGHT,1);
            break;
            
        case UISwipeGestureRecognizerDirectionRight:
            ZH_DvrCtrl(tds,nVideoPos,ZH_DVR_CTRL_LEFT,1);
            break;
    }
}

// rotate the piece by the current rotation
// reset the gesture recognizer's rotation to 0 after applying so the next callback is a delta from the current rotation
- (void)rotatePiece:(UIRotationGestureRecognizer *)gestureRecognizer
{
    //ban control
    if (!m_useCtrl) {
        return;
    }
    
    DWORD dwTmp=Sys_GetTime();
    if(dwTmp-dwRotationTime>100)
    {
        dwRotationTime=Sys_GetTime();
        if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
            if ([gestureRecognizer rotation]>0) {
                ZH_DvrCtrl(tds,nVideoPos,ZH_DVR_CTRL_FOCAL_INCR,1);
            }
            else
            {
                ZH_DvrCtrl(tds,nVideoPos,ZH_DVR_CTRL_FOCAL_DUCT,1);
            }
            
            NSLog(@"[gestureRecognizer rotation]=%f",[gestureRecognizer rotation]);
            [gestureRecognizer setRotation:0];
        }
    }
}

// scale the piece by the current scale
// reset the gesture recognizer's rotation to 0 after applying so the next callback is a delta from the current scale
- (void)scalePiece:(UIPinchGestureRecognizer *)gestureRecognizer
{
    //ban control
    if (!m_useCtrl) {
        return;
    }
    
    DWORD dwTmp=Sys_GetTime();
    if(dwTmp-dwSacleTime>100)
    {
        dwSacleTime=Sys_GetTime();
        if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
            if ([gestureRecognizer scale]>1) {
                ZH_DvrCtrl(tds,nVideoPos,ZH_DVR_CTRL_ZOOM_INCR,1);
            }
            else
            {
                ZH_DvrCtrl(tds,nVideoPos,ZH_DVR_CTRL_ZOOM_DUCT,1);
            }
            
            NSLog(@"[gestureRecognizer scale]=%f",[gestureRecognizer scale]);
            [gestureRecognizer setScale:1];
        }
    }
}

@end
