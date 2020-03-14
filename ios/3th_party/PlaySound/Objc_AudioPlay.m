//
//  AudioPlay.m
//  monitor
//
//  Created by Han Sohn on 12-6-8.
//  Copyright (c) 2012年 Han.zhihong. All rights reserved.
//

#import "Objc_AudioPlay.h"

@implementation Objc_AudioPlay

+(void)loadFile:(NSString*)file :(SystemSoundID*)soundId
{
    //加载声音文件
    NSString *path = [[NSBundle mainBundle] pathForResource:file ofType:nil];
    if (path) {//播放声音
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path],soundId);
    }
}

+(void)play:(SystemSoundID) soundId
{
    AudioServicesPlaySystemSound(soundId);
}
@end
