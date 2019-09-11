//
//  AudioUnitRecorder.m
//  CoreAudioDemos
//
//  Created by yxibng on 2019/9/11.
//  Copyright © 2019 姚晓丙. All rights reserved.
//

#import "AudioUnitRecorder.h"
@import AudioToolbox;

// A VP I/O unit's bus 1 connects to input hardware (microphone).
static const AudioUnitElement kInputBus = 1;
// A VP I/O unit's bus 0 connects to output hardware (speaker).
static const AudioUnitElement kOutputBus = 0;

static const double kAduioSampleRate = 44100.0;


@implementation AudioUnitRecorder

{
    AudioUnit _VoiceProcessingIOUnit;
}


- (void)dealloc
{
    OSStatus status =  AudioComponentInstanceDispose(_VoiceProcessingIOUnit);
    _VoiceProcessingIOUnit = NULL;
    NSAssert(status == noErr, @"AudioComponentInstanceDispose error");
}


- (instancetype)init
{
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    AudioComponentDescription ioUnitDescription;
    ioUnitDescription.componentType          = kAudioUnitType_Output;
    ioUnitDescription.componentSubType       = kAudioUnitSubType_VoiceProcessingIO;
    ioUnitDescription.componentManufacturer  = kAudioUnitManufacturer_Apple;
    ioUnitDescription.componentFlags         = 0;
    ioUnitDescription.componentFlagsMask     = 0;
    
    
    AudioComponent foundIoUnitReference = AudioComponentFindNext (
                                              NULL,
                                              &ioUnitDescription
                                          );
    OSStatus status =  AudioComponentInstanceNew (
        foundIoUnitReference,
        &_VoiceProcessingIOUnit
    );
    
    NSAssert(status == noErr, @"AudioComponentInstanceNew error");
    
    //打开录音的开关
    UInt32 inputEnableFlag = 1;
    status = AudioUnitSetProperty(_VoiceProcessingIOUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Input,
                                  kInputBus,
                                  &inputEnableFlag,
                                  sizeof(inputEnableFlag));

    NSAssert(status == noErr, @"EnableIO error");

    //禁用播放的开关,不然就一支打印EXCEPTION (-1): ""
    UInt32 playEnableFlag = 0;
    status = AudioUnitSetProperty(_VoiceProcessingIOUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Output,
                                  kOutputBus,
                                  &playEnableFlag,
                                  sizeof(playEnableFlag));
    NSAssert(status == noErr, @"disable output error");

    //打开回声消除的开关
    UInt32 echoCancellation;
    UInt32 size = sizeof(echoCancellation);
    //0 代表开， 1 代表关
    echoCancellation = 0;
    status = AudioUnitSetProperty(_VoiceProcessingIOUnit,
                                  kAUVoiceIOProperty_BypassVoiceProcessing,
                                  kAudioUnitScope_Global,
                                  0,
                                  &echoCancellation,
                                  size);
    NSAssert(status == noErr, @"enable echo cancellation error");

    //设置录音数据回调
    AURenderCallbackStruct input;
    input.inputProc = inputRenderCallback;
    input.inputProcRefCon = (__bridge void *)(self);
    status = AudioUnitSetProperty(_VoiceProcessingIOUnit,
                                  kAudioOutputUnitProperty_SetInputCallback,
                                  kAudioUnitScope_Global,
                                  kInputBus,
                                  &input,
                                  sizeof(input));

    NSAssert(status == noErr, @"set input callback error");

    //设置录音数据的格式
    AudioStreamBasicDescription format = {0};
    format.mSampleRate = kAduioSampleRate;
    format.mFormatID = kAudioFormatLinearPCM;
    format.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    format.mFramesPerPacket = 1;
    format.mChannelsPerFrame = 1;
    format.mBitsPerChannel = 16;
    format.mBytesPerPacket = 2;
    format.mBytesPerFrame = 2;

    status = AudioUnitSetProperty(_VoiceProcessingIOUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Output,
                                  kInputBus,
                                  &format,
                                  sizeof(AudioStreamBasicDescription));
    
    NSAssert(status == noErr, @"set stream format error");
    status = AudioUnitInitialize(_VoiceProcessingIOUnit);
    NSAssert(status == noErr, @"AudioUnitInitialize error");
}


- (void)startRecording
{
    OSStatus status = AudioOutputUnitStart(_VoiceProcessingIOUnit);
    NSAssert(status == noErr, @"AudioOutputUnitStart error");
}


- (void)stopRecording
{
    OSStatus status = AudioOutputUnitStop(_VoiceProcessingIOUnit);
    NSAssert(status == noErr, @"AudioOutputUnitStop error");
}


#pragma mark - 录音数据的回调
OSStatus inputRenderCallback(void *inRefCon,
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
    status = AudioUnitRender(recorder->_VoiceProcessingIOUnit, ioActionFlags, inTimeStamp, inBusNumber, inNumberFrames, &bufferList);
    
    if (0 == status) {
        //process buffer
    }

    return noErr;
}


@end
