//
//  AudioUnitPlayerViewController.m
//  CoreAudioDemos
//
//  Created by yxibng on 2019/11/14.
//  Copyright © 2019 姚晓丙. All rights reserved.
//

#import "AudioUnitPlayerViewController.h"
#import "AudioSessionTool.h"
#import "AudioUnitPlayer.h"
#import "AudioFileHelper.h"
#import "AudioConfig.h"

@interface AudioUnitPlayerViewController ()<AudioUnitPlayerDelegate>
@property (nonatomic, strong) AudioUnitPlayer *audioPlayer;
@property (nonatomic, strong) AudioFileReader *fileReader;
@end

@implementation AudioUnitPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[AudioSessionTool sharedSessionTool] setSessionPlaybackAndRecord];
    
    _audioPlayer = [[AudioUnitPlayer alloc] initWithDelegate:self];
    _fileReader = [[AudioFileReader alloc] initWithFilePath:[AudioConfig writeFilePath] streamFormat:[AudioConfig audioStreamFormat]];
    

    // Do any additional setup after loading the view from its nib.
}
- (IBAction)start:(id)sender {
    
    [_fileReader start];
    [_audioPlayer startPlaying];
    
    
}
- (IBAction)stop:(id)sender {
    [_audioPlayer stopPlaying];
}

- (void)audioPlayer:(AudioUnitPlayer *)audioPlayer didStartWithError:(NSError *)error
{
    
}

- (void)audioPlayer:(AudioUnitPlayer *)audioPlayer fillBuffer:(void *)buffer size:(int)size
{
    NSLog(@"size = %d",size);
    
    
    BOOL ret = [_fileReader readSoundTo:buffer size:size];
    if (!ret) {
        [_audioPlayer stopPlaying];
    }
}

- (void)audioPlayer:(AudioUnitPlayer *)audioPlayer didStopWithError:(NSError *)error
{
    [_fileReader stop];
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
