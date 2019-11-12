//
//  AudioUnitRecorder.h
//  CoreAudioDemos
//
//  Created by 姚晓丙 on 2019/11/4.
//  Copyright © 2019 姚晓丙. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSUInteger, AudioUnitErrorCode) {
    AudioUnitErrorCodeOK,
    AudioUnitErrorCodeNoPression,
    AudioUnitErrorCodeSystemBusy,
    AudioUnitErrorCodeFailed,
};


typedef NS_ENUM(NSUInteger, AudioUnitStopReason) {
    AudioUnitStopReasonUserTrigger,
    AudioUnitStopReasonSystemInterrupt,
    AudioUnitStopReasonOther
};


@class AudioUnitRecorder;
@protocol AudioUnitRecorderDelegate <NSObject>

@optional
- (void)audioRecorder:(AudioUnitRecorder *)recorder didStartWithError:(AudioUnitErrorCode)error;
- (void)audioRecorder:(AudioUnitRecorder *)recorder didReceiveAudioData:(void *)auidoData length:(int)length;
- (void)audioRecorder:(AudioUnitRecorder *)recorder didStopWithReason:(AudioUnitStopReason)reason;

@end


@interface AudioUnitRecorder : NSObject

- (instancetype)initWithDelegate:(id<AudioUnitRecorderDelegate>)delegate;

@property (nonatomic, weak) id<AudioUnitRecorderDelegate>delegate;


- (void)startRecording;
- (void)stopRecording;
- (BOOL)running;


@end

NS_ASSUME_NONNULL_END
