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
    [mySession setCategory: AVAudioSessionCategoryPlayAndRecord      // 3
                     error: &audioSessionError];
    [mySession setActive: YES                                        // 4
                   error: &audioSessionError];
    self.recordSampleRate = [mySession sampleRate];    // 5
    
}


- (double)recordSampleRate
{
    return _recordSampleRate;
}

@end
