//
//  AudioConfig.m
//  CoreAudioDemos
//
//  Created by yxibng on 2019/11/13.
//  Copyright © 2019 姚晓丙. All rights reserved.
//

#import "AudioConfig.h"


@implementation AudioConfig

//设置录音数据格式
AudioStreamBasicDescription kAudioStreamFormat() {
    static AudioStreamBasicDescription format = {0};
    format.mSampleRate = kAudioSampleRate;
    format.mFormatID = kAudioFormatLinearPCM;
    format.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    format.mFramesPerPacket = 1;
    format.mChannelsPerFrame = 1;
    format.mBitsPerChannel = 16;
    format.mBytesPerPacket = 2;
    format.mBytesPerFrame = 2;
    return format;
}

NSString *kAudioFileWritePath() {
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *fileName = @"audio.caf";
    NSString *path = [documentPath stringByAppendingPathComponent:fileName];
    return path;
}




+ (AudioStreamBasicDescription)audioStreamFormat
{
    return kAudioStreamFormat();
}

+ (NSString *)writeFilePath
{
    return kAudioFileWritePath();
}

@end
