//
//  AudioSessionTool.m
//  CoreAudioDemos
//
//  Created by 姚晓丙 on 2019/9/4.
//  Copyright © 2019 姚晓丙. All rights reserved.
//

#import "AudioSessionTool.h"
#import <AVFoundation/AVFoundation.h>

@interface AudioSessionTool ()
@property (nonatomic, assign) double recordSampleRate;
@property (nonatomic, assign) float ioBufferDuration;
@end

@implementation AudioSessionTool

+ (instancetype)sharedSessionTool
{
    static AudioSessionTool * tool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool = [AudioSessionTool new];
    });
    return tool;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.recordSampleRate = kRecordSampleRate;
    }
    return self;
}

- (void)setSessionPlaybackAndRecord
{
    NSError *audioSessionError = nil;
    AVAudioSession *mySession = [AVAudioSession sharedInstance];     // 1
    [mySession setPreferredSampleRate: self.recordSampleRate       // 2
                                error: &audioSessionError];
    NSAssert(audioSessionError == nil, @"AVAudioSession setPreferredSampleRate error");
    [mySession setCategory: AVAudioSessionCategoryPlayAndRecord      // 3
                     error: &audioSessionError];
    NSAssert(audioSessionError == nil, @"AVAudioSession setCategory error");

    [mySession setActive: YES                                        // 4
                   error: &audioSessionError];
    NSAssert(audioSessionError == nil, @"AVAudioSession setCategory error");
    self.recordSampleRate = [mySession sampleRate];    // 5

    /*
     i/o buffer duration, 如果对延迟的要求越高， ioBufferDuration 设置的越短
     采样率 44.1 kHz，默认ioBufferDuration = 23ms, a slice size =  1024sample
     采样率 44.1 kHz，ioBufferDuration = 0.005， a slice size = 256sample
     */
    self.ioBufferDuration = 0.005;
    [mySession setPreferredIOBufferDuration: self.ioBufferDuration
                                      error: &audioSessionError];
    NSAssert(audioSessionError == nil, @"AVAudioSession setPreferredIOBufferDuration error");
}


- (double)recordSampleRate
{
    return _recordSampleRate;
}

@end
