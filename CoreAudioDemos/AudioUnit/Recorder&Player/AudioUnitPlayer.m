//
//  AudioUnitPlayer.m
//  CoreAudioDemos
//
//  Created by yxibng on 2019/11/14.
//  Copyright © 2019 姚晓丙. All rights reserved.
//

#import "AudioUnitPlayer.h"
#import "AudioConfig.h"

@import AudioToolbox;
@import CoreAudio;

@interface AudioUnitPlayer ()
{
    @public
    AudioUnit _ioUnit;
    AudioComponent _ioComponet;
}

@property (nonatomic, assign) BOOL running;
@end



@implementation AudioUnitPlayer


- (instancetype)initWithDelegate:(id<AudioUnitPlayerDelegate>)delegate
{
    if (self = [super init]) {
        _delegate = delegate;
        [self configAudioUnit];
    }
    return self;
}

- (void)configAudioUnit
{
    //1. Creating an audio component description to identify an audio unit
    AudioComponentDescription ioUnitDescription;
    ioUnitDescription.componentType          = kAudioUnitType_Output;
    ioUnitDescription.componentSubType       = kAudioUnitSubType_VoiceProcessingIO;
    ioUnitDescription.componentManufacturer  = kAudioUnitManufacturer_Apple;
    ioUnitDescription.componentFlags         = 0;
    ioUnitDescription.componentFlagsMask     = 0;
    
    //2. Obtaining an audio unit instance using the audio unit API
    AudioComponent foundIoUnitReference = AudioComponentFindNext (
                                              NULL,
                                              &ioUnitDescription
                                          );
    _ioComponet = foundIoUnitReference;
    
    AudioUnit ioUnitInstance;
    AudioComponentInstanceNew (
        foundIoUnitReference,
        &ioUnitInstance
    );
    _ioUnit = ioUnitInstance;
    
    
    //禁用录音
    UInt32 recordEnable = 0;
    OSStatus status = AudioUnitSetProperty(ioUnitInstance,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Input,
                                  kInputBus,
                                  &recordEnable,
                                  sizeof(recordEnable));
    if (status != noErr) {
        NSLog(@"%s, line = %d, status = %d", __FUNCTION__, __LINE__, status);
        return;
    }
    
    //打开播放开关
    UInt32 playEnable = 1;
    status = AudioUnitSetProperty(ioUnitInstance,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Output,
                                  kOutputBus,
                                  &playEnable,
                                  sizeof(playEnable));
    if (status != noErr) {
        NSLog(@"%s, line = %d, status = %d", __FUNCTION__, __LINE__, status);
        return;
    }
    
    //打开回声消除 0 开， 1 关
    UInt32 echoCancellationEnable = 0;
    status = AudioUnitSetProperty(ioUnitInstance,
                                  kAUVoiceIOProperty_BypassVoiceProcessing,
                                  kAudioUnitScope_Global,
                                  kOutputBus,
                                  &echoCancellationEnable,
                                  sizeof(echoCancellationEnable));
    
    if (status != noErr) {
        NSLog(@"%s, line = %d, status = %d", __FUNCTION__, __LINE__, status);
        return;
    }
    
    //设置播放数据的格式
    AudioStreamBasicDescription format = [AudioConfig audioStreamFormat];
    
    status = AudioUnitSetProperty(ioUnitInstance,
                         kAudioUnitProperty_StreamFormat,
                         kAudioUnitScope_Input,
                         kOutputBus,
                         &format,
                         sizeof(format));
    if (status != noErr) {
        NSLog(@"%s, line = %d, status = %d", __FUNCTION__, __LINE__, status);
        return;
    }
    //设置播放的回调
    AURenderCallbackStruct playCallback;
    playCallback.inputProc = playRenderCallback;
    playCallback.inputProcRefCon = (__bridge void * _Nullable)(self);
    status = AudioUnitSetProperty(ioUnitInstance,
                                  kAudioUnitProperty_SetRenderCallback,
                                  kAudioUnitScope_Input,
                                  kOutputBus,
                                  &playCallback,
                                  sizeof(playCallback));
    if (status != noErr) {
        NSLog(@"%s, line = %d, status = %d", __FUNCTION__, __LINE__, status);
        return;
    }
    
    status = AudioUnitInitialize(ioUnitInstance);
    if (status != noErr) {
        NSLog(@"%s, line = %d, status = %d", __FUNCTION__, __LINE__, status);
        return;
    }
}



#pragma mark -
- (void)startPlaying
{
    if (self.running) {
        return;
    }
    
    OSStatus status =  AudioOutputUnitStart(_ioUnit);
    if (status != noErr) {
        NSLog(@"%s, line = %d, status = %d", __FUNCTION__, __LINE__, status);
        if ([self.delegate respondsToSelector:@selector(audioPlayer:didStartWithError:)]) {
            NSError *error = [[NSError alloc] initWithDomain:@"Audio unit domain" code:status userInfo:nil];
            [self.delegate audioPlayer:self didStartWithError:error];
        }
        return;
    }
    _running = YES;
    
    if ([self.delegate respondsToSelector:@selector(audioPlayer:didStartWithError:)]) {
        [self.delegate audioPlayer:self didStartWithError:nil];
    }
}

- (void)stopPlaying
{
    if (!_running) {
        return;
    }
    OSStatus status = AudioOutputUnitStop(_ioUnit);
    if (status != noErr) {
        NSLog(@"%s, line = %d, status = %d", __FUNCTION__, __LINE__, status);
        return;
    }
    _running = NO;
    
    if ([self.delegate respondsToSelector:@selector(audioPlayer:didStopWithError:)]) {
        [self.delegate audioPlayer:self didStopWithError:nil];
    }
}

- (BOOL)running
{
    return _running;
}

#pragma mark -
OSStatus playRenderCallback(void *inRefCon,
                             AudioUnitRenderActionFlags *ioActionFlags,
                             const AudioTimeStamp *inTimeStamp,
                             UInt32 inBusNumber,
                             UInt32 inNumberFrames,
                             AudioBufferList *ioData)
{
    AudioUnitPlayer *player = (__bridge AudioUnitPlayer *)inRefCon;
    if ([player.delegate respondsToSelector:@selector(audioPlayer:fillBuffer:size:)]) {
        [player.delegate audioPlayer:player fillBuffer:ioData->mBuffers[0].mData size:ioData->mBuffers[0].mDataByteSize];
    }
    return noErr;
}




@end
