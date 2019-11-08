//
//  AudioUnitConfig.h
//  CoreAudioDemos
//
//  Created by 姚晓丙 on 2019/11/4.
//  Copyright © 2019 姚晓丙. All rights reserved.
//

#ifndef AudioUnitConfig_h
#define AudioUnitConfig_h

@import AudioToolbox;

// A VP I/O unit's bus 1 connects to input hardware (microphone).
static const AudioUnitElement kInputBus = 1;
// A VP I/O unit's bus 0 connects to output hardware (speaker).
static const AudioUnitElement kOutputBus = 0;

/*
 采样率， 单位 HZ
 */
static const double kAudioSampleRate = 44100.0;
/*
 每次读取写入的音频buffer时间长度，单位s
 */
static const double kIOBufferDuration = 0.005;

#endif /* AudioUnitConfig_h */
