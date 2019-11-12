//
//  AudioUnitRecorder.m
//  CoreAudioDemos
//
//  Created by 姚晓丙 on 2019/11/4.
//  Copyright © 2019 姚晓丙. All rights reserved.
//

#import "AudioUnitRecorder.h"
#import <AudioToolbox/AudioToolbox.h>
#import "AudioUnitConfig.h"

@interface AudioUnitRecorder()
{
    @public
    AudioUnit _ioUnit;
    AudioComponent _ioComponet;
}

@property (nonatomic, assign) BOOL running;
@end

@implementation AudioUnitRecorder

- (void)dealloc
{
    if (_running) {
        AudioOutputUnitStop(_ioUnit);
    }
    AudioUnitUninitialize(_ioUnit);
    AudioComponentInstanceDispose(_ioUnit);
}

- (instancetype)initWithDelegate:(id<AudioUnitRecorderDelegate>)delegate
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
    
    //3. config the properties
    UInt32 recordEnable = 1;
    OSStatus status = AudioUnitSetProperty(ioUnitInstance,
                                           kAudioOutputUnitProperty_EnableIO,
                                           kAudioUnitScope_Input,
                                           kInputBus,
                                           &recordEnable,
                                           sizeof(recordEnable));
    if (status != noErr) {
        return;
    }
    
    //禁用播放的开关,不然就一支打印EXCEPTION (-1): ""
    UInt32 playEnable = 0;
    status = AudioUnitSetProperty(ioUnitInstance,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Output,
                                  kOutputBus,
                                  &playEnable,
                                  sizeof(playEnable));
    if (status != noErr) {
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
        return;
    }
    
    //设置录音数据格式
    AudioStreamBasicDescription format = {0};
    format.mSampleRate = kAudioSampleRate;
    format.mFormatID = kAudioFormatLinearPCM;
    format.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    format.mFramesPerPacket = 1;
    format.mChannelsPerFrame = 1;
    format.mBitsPerChannel = 16;
    format.mBytesPerPacket = 2;
    format.mBytesPerFrame = 2;
    
    status = AudioUnitSetProperty(ioUnitInstance,
                         kAudioUnitProperty_StreamFormat,
                         kAudioUnitScope_Output,
                         kInputBus,
                         &format,
                         sizeof(format));
    if (status != noErr) {
        return;
    }
    //设置录音数据回调
    AURenderCallbackStruct recordCallback;
    recordCallback.inputProc = recordRenderCallback;
    recordCallback.inputProcRefCon = (__bridge void * _Nullable)(self);
    status = AudioUnitSetProperty(ioUnitInstance, kAudioOutputUnitProperty_SetInputCallback, kAudioUnitScope_Global, kInputBus, &recordCallback, sizeof(recordCallback));
    if (status != noErr) {
        return;
    }
    
    status = AudioUnitInitialize(ioUnitInstance);
    if (status != noErr) {
        return;
    }
}



#pragma mark -
- (void)startRecording
{
    if (self.running) {
        return;
    }
    
    OSStatus status =  AudioOutputUnitStart(_ioUnit);
    if (status != noErr) {
        return;
    }
    _running = YES;
}

- (void)stopRecording
{
    if (!_running) {
        return;
    }
    OSStatus status = AudioOutputUnitStop(_ioUnit);
    if (status != noErr) {
        return;
    }
    _running = NO;
}

- (BOOL)running
{
    return _running;
}

#pragma mark -
OSStatus recordRenderCallback(void *inRefCon,
                             AudioUnitRenderActionFlags *ioActionFlags,
                             const AudioTimeStamp *inTimeStamp,
                             UInt32 inBusNumber,
                             UInt32 inNumberFrames,
                             AudioBufferList *ioData)
{
    AudioUnitRecorder *recorder = (__bridge AudioUnitRecorder *)inRefCon;
    // a variable where we check the status
    OSStatus status;
    AudioBufferList bufferList;
    bufferList.mNumberBuffers = 1;
    bufferList.mBuffers[0].mData = NULL;
    bufferList.mBuffers[0].mDataByteSize = 0;
    // render input and check for error
    status = AudioUnitRender(recorder->_ioUnit, ioActionFlags, inTimeStamp, inBusNumber, inNumberFrames, &bufferList);
    if (status == noErr) {
        if ([recorder.delegate respondsToSelector:@selector(audioRecorder:didReceiveAudioData:length:)]) {
            [recorder.delegate audioRecorder:recorder didReceiveAudioData:bufferList.mBuffers[0].mData length:bufferList.mBuffers[0].mDataByteSize];
        }
    } else {
        //render error

    }
    return noErr;
}



@end
