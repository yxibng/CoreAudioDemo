//
//  AudioUnitPlayer.h
//  CoreAudioDemos
//
//  Created by yxibng on 2019/11/14.
//  Copyright © 2019 姚晓丙. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class AudioUnitPlayer;
@protocol AudioUnitPlayerDelegate <NSObject>

- (void)audioPlayer:(AudioUnitPlayer *)audioPlayer didStartWithError:(NSError *)error;
- (void)audioPlayer:(AudioUnitPlayer *)audioPlayer fillBuffer:(void *)buffer size:(int)size;
- (void)audioPlayer:(AudioUnitPlayer *)audioPlayer didStopWithError:(NSError *)error;
@end


@interface AudioUnitPlayer : NSObject

- (instancetype)initWithDelegate:(id<AudioUnitPlayerDelegate>)delegate;

@property (nonatomic, weak) id<AudioUnitPlayerDelegate>delegate;
- (void)startPlaying;
- (void)stopPlaying;

@end

NS_ASSUME_NONNULL_END
