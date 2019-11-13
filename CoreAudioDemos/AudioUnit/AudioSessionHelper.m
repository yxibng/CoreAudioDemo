//
//  AudioSessionHelper.m
//  CoreAudioDemos
//
//  Created by 姚晓丙 on 2019/11/4.
//  Copyright © 2019 姚晓丙. All rights reserved.
//

#import "AudioSessionHelper.h"
#import <AVFoundation/AVFoundation.h>
#import "AudioConfig.h"

@implementation AudioSessionHelper


+ (int)setSessionPlaybackAndRecord
{
    
    // Configure the audio session for playback and recording
    NSError *audioSessionError = nil;
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    if (@available(ios 9.0, *)) {
        [session setCategory:AVAudioSessionCategoryPlayback
                 withOptions:
         AVAudioSessionCategoryOptionMixWithOthers |
         AVAudioSessionCategoryOptionDuckOthers |
         AVAudioSessionCategoryOptionInterruptSpokenAudioAndMixWithOthers
                       error:&audioSessionError];
    } else if (@available (iOS 10, *)) {
        [session setCategory:AVAudioSessionCategoryPlayback
                 withOptions:
         AVAudioSessionCategoryOptionMixWithOthers |
         AVAudioSessionCategoryOptionDuckOthers |
         AVAudioSessionCategoryOptionInterruptSpokenAudioAndMixWithOthers  |
         AVAudioSessionCategoryOptionAllowBluetoothA2DP |
         AVAudioSessionCategoryOptionAllowAirPlay
                       error:&audioSessionError];
        
    } else if(@available(iOS 11, *)) {
        [session setCategory:AVAudioSessionCategoryPlayback
                        mode:AVAudioSessionModeVoiceChat options:
        AVAudioSessionCategoryOptionMixWithOthers |
        AVAudioSessionCategoryOptionDuckOthers |
        AVAudioSessionCategoryOptionInterruptSpokenAudioAndMixWithOthers  |
        AVAudioSessionCategoryOptionAllowBluetoothA2DP |
        AVAudioSessionCategoryOptionAllowAirPlay
                       error:&audioSessionError];
        
    } else {
        //before ios 9.0
        [session setCategory:AVAudioSessionCategoryPlayback
                 withOptions:
         AVAudioSessionCategoryOptionMixWithOthers |
         AVAudioSessionCategoryOptionDuckOthers
                       error:&audioSessionError];
        
    }
    
    if (audioSessionError) {
        NSLog(@"Error %ld, %@",
              (long)audioSessionError.code, audioSessionError.localizedDescription);
        return -1;
    }
     
    
    // Set some preferred values
    NSTimeInterval bufferDuration = kIOBufferDuration; // I would prefer a 5ms buffer duration
    [session setPreferredIOBufferDuration:bufferDuration error:&audioSessionError];
    if (audioSessionError) {
        NSLog(@"Error %ld, %@",
              (long)audioSessionError.code, audioSessionError.localizedDescription);
        return -1;
    }
     
    double sampleRate = kAudioSampleRate; // I would prefer a sample rate of 44.1kHz
    [session setPreferredSampleRate:sampleRate error:&audioSessionError];
    if (audioSessionError) {
        NSLog(@"Error %ld, %@",
              (long)audioSessionError.code, audioSessionError.localizedDescription);
        return -1;
    }
     
    // Register for Route Change notifications
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleRouteChange:)
                                                 name: AVAudioSessionRouteChangeNotification
                                               object: session];
     
    // *** Activate the audio session before asking for the "Current" values ***
    [session setActive:YES error:&audioSessionError];
    if (audioSessionError) {
        NSLog(@"Error %ld, %@",
              (long)audioSessionError.code, audioSessionError.localizedDescription);
        return -1;
    }
     
    // Get current values
    sampleRate = session.sampleRate;
    bufferDuration = session.IOBufferDuration;
     
    NSLog(@"Sample Rate:%0.0fHz I/O Buffer Duration:%f", sampleRate, bufferDuration);
    return 0;
}

+ (void)handleRouteChange:(NSNotification *)notification
{
    
}


@end
