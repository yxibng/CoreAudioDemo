//
//  AudioUnitRecorder.h
//  CoreAudioDemos
//
//  Created by yxibng on 2019/9/11.
//  Copyright © 2019 姚晓丙. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *kPcmName = @"audio.pcm";

static inline NSString *pcm_path(){
   NSString *dir =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    return  [dir stringByAppendingPathComponent:kPcmName];
    
}

@interface AudioUnitRecorder : NSObject
- (void)startRecording;
- (void)stopRecording;
@end

NS_ASSUME_NONNULL_END
