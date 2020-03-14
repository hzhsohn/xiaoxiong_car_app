//
//  AudioPlay.h
//  monitor
//
//  Created by Han Sohn on 12-6-8.
//  Copyright (c) 2012年 Han.zhihong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

@interface Objc_AudioPlay : NSObject

+(void)loadFile:(NSString*)file :(SystemSoundID*)soundId;
+(void)play:(SystemSoundID)soundId;

@end
