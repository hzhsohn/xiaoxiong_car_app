//
//  SaveImageMage.h
//  PooeaMonitor
//
//  Created by sohn on 11-9-8.
//  Copyright 2011年 Pooea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Objc_AudioPlay.h"

@interface Objc_SaveImageMage : NSObject {
    UIView* m_vi;
    SystemSoundID m_sid;
}


-(id)init;
-(void)dealloc;

-(void)SaveImageEnd;
-(void)SaveImage:(UIView*)perentView :(UIImage*)img;

@end
