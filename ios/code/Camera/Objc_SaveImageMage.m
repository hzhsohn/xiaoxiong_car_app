//
//  SaveImageMage.m
//  PooeaMonitor
//
//  Created by sohn on 11-9-8.
//  Copyright 2011年 Han.zhihong. All rights reserved.
//

#import "Objc_SaveImageMage.h"
#import "Objc_AudioPlay.h"

@implementation Objc_SaveImageMage

-(id)init
{
    if((self=[super init]))
    {
        CGRect rx = [ UIScreen mainScreen ].bounds;
        m_vi=[[UIView alloc] initWithFrame:rx];
        m_vi.backgroundColor=[UIColor whiteColor];
        m_vi.alpha=0.62;
        
        [Objc_AudioPlay loadFile:@"btn_shortscreen.wav" :&m_sid];
    }
    return self;
}
-(void)dealloc
{
    m_vi=nil;
}

-(void)SaveImageEnd
{
    [m_vi removeFromSuperview];
}

-(void)SaveImage:(UIView*)perentView :(UIImage*)img
{
    UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil);
    CGRect rx = [ UIScreen mainScreen ].bounds;
    [m_vi setFrame:rx];
    m_vi.alpha=0.62;
    [UIView beginAnimations:@"SetAnimation" context:@"SetAnimation"];
	[UIView setAnimationDuration:0.5f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationRepeatAutoreverses:NO];
    [UIView setAnimationDelegate:self];
	[UIView setAnimationTransition:UIViewAnimationTransitionNone forView:m_vi cache:NO];

    m_vi.alpha=0;
    [perentView addSubview:m_vi];
    
    [UIView setAnimationDidStopSelector:@selector(SaveImageEnd)];
	[UIView commitAnimations];
    
    //声音特效
    [Objc_AudioPlay play:m_sid];
}

@end
