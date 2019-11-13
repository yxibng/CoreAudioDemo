//
//  AudioFileHelper.m
//  CoreAudioDemos
//
//  Created by yxibng on 2019/11/13.
//  Copyright © 2019 姚晓丙. All rights reserved.
//

#import "AudioFileHelper.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation AudioFileReader

- (instancetype)initWithFilePath:(NSString *)filePath
{
    if (self = [super init]) {
        _filePath = filePath;
    }
    return self;
}


@end


@interface AudioFileWriter ()
@property (nonatomic, assign) BOOL running;
@property (nonatomic) AudioFileID fileID;
@property (nonatomic) SInt64 startByte;
@property (nonatomic) AudioStreamBasicDescription streamFormat;
@end

@implementation AudioFileWriter

- (instancetype)initWithFilePath:(NSString *)filePath streamFormat:(AudioStreamBasicDescription)streamFormat
{
    if (self = [super init]) {
        _filePath = filePath;
        _streamFormat = streamFormat;
    }
    return self;
}


- (void)setupForWritting {
    
    NSURL *url = [NSURL fileURLWithPath:self.filePath];
    OSStatus status = AudioFileCreateWithURL((__bridge CFURLRef _Nonnull)(url),
                                             kAudioFileCAFType,
                                             &_streamFormat,
                                             kAudioFileFlags_EraseFile, &(_fileID));
    if (status != noErr) {
        NSLog(@"%s status = %d", __FUNCTION__, status);
        return;
    }
    _startByte = 0;
    _running = YES;
}

- (void)start
{
    [self setupForWritting];
}

- (void)writeData:(void *)data size:(int)length
{
    if (!_running) {
        return;
    }
    UInt32 size = length;
    OSStatus status = AudioFileWriteBytes(_fileID, FALSE, _startByte, &size, data);
    if (status != noErr) {
        NSLog(@"%s status = %d", __FUNCTION__, status);
        return;
    }
    _startByte += size;
}

- (void)stop
{
    OSStatus status = AudioFileClose(_fileID);
    if (status != noErr) {
        NSLog(@"%s status = %d", __FUNCTION__, status);
        return;
    }
    _running = NO;
}

@end



@implementation AudioFileHelper

@end
