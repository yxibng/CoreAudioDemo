//
//  AudioUnitRecorder.m
//  CoreAudioDemos
//
//  Created by yxibng on 2019/9/11.
//  Copyright © 2019 姚晓丙. All rights reserved.
//

#import "AudioUnitHelper.h"
@import AudioToolbox;
@import AVFoundation;
// A VP I/O unit's bus 1 connects to input hardware (microphone).
static const AudioUnitElement kInputBus = 1;
// A VP I/O unit's bus 0 connects to output hardware (speaker).
static const AudioUnitElement kOutputBus = 0;

static const double kAudioSampleRate = 44100.0;


typedef struct AudioRecordFile {
    AudioFileID file;
    SInt64 inStartingByte;
    BOOL running;
} AudioRecordFile;


typedef struct {
    AudioStreamBasicDescription asbd;
    Float32 *data;
    UInt32 numFrames;
    UInt32 sampleNum;
} SoundBuffer, *SoundBufferPtr;


@interface AudioUnitHelper()

@property (nonatomic) AudioRecordFile *recordFilePointer;
@property (nonatomic) SoundBufferPtr mSoundBufferPtr;


@end



@implementation AudioUnitHelper
{
    AudioUnit _VoiceProcessingIOUnit;
    AudioStreamBasicDescription _streamFormat;
    AudioRecordFile _recordFile;
    
    SoundBuffer mSoundBuffer;
}


- (void)dealloc
{
    [self stop];
    
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


- (void)prepareAudioFileToRecord
{
    _recordFilePointer = &_recordFile;
    
    NSURL *fileURL = [NSURL fileURLWithPath:pcm_record_path()];
    OSStatus status = AudioFileCreateWithURL((__bridge CFURLRef)fileURL,
                                             kAudioFileCAFType,
                                             &(_streamFormat),
                                             kAudioFileFlags_EraseFile,
                                             &(_recordFilePointer->file));
    
    NSAssert(status == noErr, @"AudioFileCreateWithURL error");
    _recordFilePointer->inStartingByte = 0;
    _recordFilePointer->running = YES;
}

- (void)closeAudioFile
{
    _recordFilePointer->running = NO;
    OSStatus status = AudioFileClose(_recordFilePointer->file);
    NSAssert(status == noErr, @"AudioFileClose error");
}


- (void)loadFile
{
    AVAudioFormat *clientFormat = [[AVAudioFormat alloc] initWithCommonFormat:AVAudioPCMFormatFloat32
                                                                   sampleRate:kAudioSampleRate
                                                                     channels:1
                                                                  interleaved:YES];
    
    
    ExtAudioFileRef audioFileRef = NULL;
    NSURL *url = [NSURL fileURLWithPath:pcm_play_path()];
    OSStatus status = ExtAudioFileOpenURL((__bridge CFURLRef)url, &audioFileRef);
    NSAssert(status == noErr, @"ExtAudioFileOpenURL error");
    NSAssert(audioFileRef != NULL, @"ExtAudioFileOpenURL error");
    
    // get the file data format, this represents the file's actual data format
    AudioStreamBasicDescription fileFormat;
    UInt32 propSize = sizeof(fileFormat);
    
    status = ExtAudioFileGetProperty(audioFileRef, kExtAudioFileProperty_FileDataFormat, &propSize, &fileFormat);
    NSAssert(audioFileRef != NULL, @"ExtAudioFileGetProperty format error");

    double rateRatio = kAudioSampleRate / fileFormat.mSampleRate;
    
    propSize = sizeof(AudioStreamBasicDescription);
    status = ExtAudioFileSetProperty(audioFileRef, kExtAudioFileProperty_ClientDataFormat, propSize, clientFormat.streamDescription);
    NSAssert(audioFileRef != NULL, @"ExtAudioFileGetProperty kExtAudioFileProperty_ClientDataFormat error");
    
    UInt64 numFrames = 0;
    propSize = sizeof(numFrames);
    status = ExtAudioFileGetProperty(audioFileRef, kExtAudioFileProperty_FileLengthFrames, &propSize, &numFrames);
    NSAssert(audioFileRef != NULL, @"ExtAudioFileGetProperty kExtAudioFileProperty_FileLengthFrames error");
    numFrames = (numFrames * rateRatio); // account for any sample rate conversion
    
    mSoundBuffer.numFrames = (UInt32)numFrames;
    mSoundBuffer.asbd = *(clientFormat.streamDescription);
    
    UInt32 samples = (UInt32)numFrames * mSoundBuffer.asbd.mChannelsPerFrame;
    mSoundBuffer.data = (Float32 *)calloc(samples, sizeof(Float32));
    mSoundBuffer.sampleNum = 0;
    
    // set up a AudioBufferList to read data into
    AudioBufferList bufList;
    bufList.mNumberBuffers = 1;
    bufList.mBuffers[0].mNumberChannels = 1;
    bufList.mBuffers[0].mData = mSoundBuffer.data;
    bufList.mBuffers[0].mDataByteSize = samples * sizeof(Float32);
    
    UInt32 numPackets = (UInt32)numFrames;
    status = ExtAudioFileRead(audioFileRef, &numPackets, &bufList);
    NSAssert(audioFileRef != NULL, @"ExtAudioFileRead error");
    
    if (status) {
        free(mSoundBuffer.data);
        mSoundBuffer.data = NULL;
    }
    
    self.mSoundBufferPtr = &mSoundBuffer;
    
    // close the file and dispose the ExtAudioFileRef
    ExtAudioFileDispose(audioFileRef);
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
    
//    //打开录音的开关
//    UInt32 inputEnableFlag = 1;
//    status = AudioUnitSetProperty(_VoiceProcessingIOUnit,
//                                  kAudioOutputUnitProperty_EnableIO,
//                                  kAudioUnitScope_Input,
//                                  kInputBus,
//                                  &inputEnableFlag,
//                                  sizeof(inputEnableFlag));
//
//    NSAssert(status == noErr, @"EnableIO error");

    //禁用播放的开关,不然就一支打印EXCEPTION (-1): ""
    UInt32 playEnableFlag = 1;
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
                                  kInputBus,
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
    
    
    //设置播放的回调
    AURenderCallbackStruct output;
    output.inputProc = playbackCallback;
    output.inputProcRefCon = (__bridge void *)(self);
    status = AudioUnitSetProperty(_VoiceProcessingIOUnit,
                                  kAudioUnitProperty_SetRenderCallback,
                                  kAudioUnitScope_Global,
                                  kOutputBus,
                                  &output,
                                  sizeof(output));

    NSAssert(status == noErr, @"set playback callback error");
    
    
    _streamFormat.mSampleRate = kAudioSampleRate;
    _streamFormat.mFormatID = kAudioFormatLinearPCM;
    _streamFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    _streamFormat.mFramesPerPacket = 1;
    _streamFormat.mChannelsPerFrame = 1;
    _streamFormat.mBitsPerChannel = 16;
    _streamFormat.mBytesPerPacket = 2;
    _streamFormat.mBytesPerFrame = 2;

    status = AudioUnitSetProperty(_VoiceProcessingIOUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Output,
                                  kInputBus,
                                  &_streamFormat,
                                  sizeof(AudioStreamBasicDescription));
    

    status = AudioUnitSetProperty(_VoiceProcessingIOUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Input,
                                  kOutputBus,
                                  &_streamFormat,
                                  sizeof(AudioStreamBasicDescription));

    NSAssert(status == noErr, @"set stream format error");
    status = AudioUnitInitialize(_VoiceProcessingIOUnit);
    NSAssert(status == noErr, @"AudioUnitInitialize error");
}

- (void)start
{
    [self prepareAudioFileToRecord];
    [self loadFile];
    OSStatus status = AudioOutputUnitStart(_VoiceProcessingIOUnit);
    NSAssert(status == noErr, @"AudioOutputUnitStart error");
}

- (void)stop
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
    AudioUnitHelper *recorder = (__bridge AudioUnitHelper *)inRefCon;
    // a variable where we check the status
    OSStatus status;
    AudioBufferList bufferList;
    bufferList.mNumberBuffers = 1;
    bufferList.mBuffers[0].mData = NULL;
    bufferList.mBuffers[0].mDataByteSize = 0;

    // render input and check for error
    status = AudioUnitRender(recorder->_VoiceProcessingIOUnit, ioActionFlags, inTimeStamp, inBusNumber, inNumberFrames, &bufferList);
    
    if (status) {
        return status;
    }
    
    uint32_t size = bufferList.mBuffers[0].mDataByteSize;
    AudioRecordFile *recordFile = recorder.recordFilePointer;
    status = AudioFileWriteBytes(recordFile->file, FALSE, recordFile->inStartingByte, &size, bufferList.mBuffers[0].mData);
    if (status) {
        return status;
    }
    recordFile->inStartingByte += size;

    return noErr;
}


static OSStatus playbackCallback(void *inRefCon,
                                 AudioUnitRenderActionFlags *ioActionFlags,
                                 const AudioTimeStamp *inTimeStamp,
                                 UInt32 inBusNumber,
                                 UInt32 inNumberFrames,
                                 AudioBufferList *ioData)
{
    
    AudioUnitHelper *helper = (__bridge AudioUnitHelper *)inRefCon;
    if (!helper) {
        return noErr;
    }
    
    SoundBufferPtr sndBuf = helper.mSoundBufferPtr;
    
    if (!sndBuf) {
        return noErr;
    }
    
    
    if (!ioData) {
        return noErr;
    }
    
    UInt32 sample = sndBuf->sampleNum;      // frame number to start from
    UInt32 bufSamples = sndBuf->numFrames;  // total number of frames in the sound buffer
    Float32 *inData = sndBuf->data; // audio data buffer

    Float32 *outA = (Float32 *)ioData->mBuffers[0].mData; // output audio buffer for L channel
    
    
    for (UInt32 i = 0; i< inNumberFrames; ++i) {
        
        outA[i] = inData[sample++];
        if (sample > bufSamples) {
            sample = 0;
        }
        
    }
    
    sndBuf[inBusNumber].sampleNum = sample; // keep track of where we are in the source data buffer
    
    return noErr;
}



@end
