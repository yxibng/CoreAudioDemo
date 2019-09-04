//
//  AudioSessionTool.h
//  CoreAudioDemos
//
//  Created by 姚晓丙 on 2019/9/4.
//  Copyright © 2019 姚晓丙. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

NS_ASSUME_NONNULL_BEGIN

@interface AudioSessionTool : NSObject

+ (instancetype)sharedSessionTool;

- (double)recordSampleRate;
- (void)setSessionPlaybackAndRecord;

@end

NS_ASSUME_NONNULL_END
