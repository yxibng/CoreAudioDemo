//
//  AudioUnitRecordViewController.m
//  CoreAudioDemos
//
//  Created by yxibng on 2019/11/12.
//  Copyright © 2019 姚晓丙. All rights reserved.
//

#import "AudioUnitRecordViewController.h"
#import "AudioUnitRecorder.h"
#import "AudioSessionTool.h"
#import "AudioFileHelper.h"
#import "AudioConfig.h"

@interface AudioUnitRecordViewController ()<AudioUnitRecorderDelegate>
@property (nonatomic, strong) AudioUnitRecorder *audioUnitRecorder;
@property (nonatomic, strong) AudioFileWriter *fileWriter;
@end

@implementation AudioUnitRecordViewController

- (void)dealloc
{
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [[AudioSessionTool sharedSessionTool] setSessionPlaybackAndRecord];
    _audioUnitRecorder = [[AudioUnitRecorder alloc] initWithDelegate:self];
    _fileWriter = [[AudioFileWriter alloc] initWithFilePath:[AudioConfig writeFilePath] streamFormat:[AudioConfig audioStreamFormat]];
    
}

- (IBAction)startRecording:(id)sender {
    
    if (self.audioUnitRecorder.running) {
        return;
    }
    [self.audioUnitRecorder startRecording];
}
- (IBAction)stopRecording:(id)sender {
    if (!self.audioUnitRecorder.running) {
        return;
    }
    [self.audioUnitRecorder stopRecording];
}

- (void)audioRecorder:(AudioUnitRecorder *)recorder didStartWithError:(AudioUnitErrorCode)error
{
    if (error == AudioUnitErrorCodeOK) {
        NSLog(@"%s, success", __FUNCTION__);
        [_fileWriter start];
    } else {
        NSLog(@"%s, failed reason = %lu", __FUNCTION__, (unsigned long)error);
    }
}

- (void)audioRecorder:(AudioUnitRecorder *)recorder didStopWithReason:(AudioUnitStopReason)reason
{
    NSLog(@"%s",__FUNCTION__);
    [_fileWriter stop];
}

- (void)audioRecorder:(AudioUnitRecorder *)recorder didReceiveAudioData:(void *)auidoData length:(int)length
{
    [_fileWriter writeData:auidoData size:length];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
