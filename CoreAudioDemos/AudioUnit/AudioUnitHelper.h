//
//  AudioUnitRecorder.h
//  CoreAudioDemos
//
//  Created by yxibng on 2019/9/11.
//  Copyright © 2019 姚晓丙. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN



static inline NSString *pcm_record_path(){
    NSString *name = @"pcm.aif";
    NSString *dir =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    return  [dir stringByAppendingPathComponent:name];
}

static inline NSString *pcm_play_path(){
    return [[NSBundle mainBundle] pathForResource:@"DrumsMonoSTP" ofType:@"aif"];
}

@interface AudioUnitHelper : NSObject
- (void)start;


- (void)stop;


@end

NS_ASSUME_NONNULL_END
