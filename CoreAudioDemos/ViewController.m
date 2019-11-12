//
//  ViewController.m
//  CoreAudioDemos
//
//  Created by 姚晓丙 on 2019/9/4.
//  Copyright © 2019 姚晓丙. All rights reserved.
//

#import "ViewController.h"
#import "AudioUnitHelper.h"
#import "AudioSessionTool.h"



@interface ViewController ()
@property (nonatomic, strong) AudioUnitHelper *audioUnitHelper;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[AudioSessionTool sharedSessionTool] setSessionPlaybackAndRecord];
    
    // Do any additional setup after loading the view.
}

- (IBAction)startRecord:(id)sender {
    [self.audioUnitHelper start];
    
    NSLog(@"%s",__FUNCTION__);
    
}

- (IBAction)stopRecord:(id)sender {
    [self.audioUnitHelper stop];
    NSLog(@"%s",__FUNCTION__);

}


- (AudioUnitHelper *)audioUnitHelper
{
    if (!_audioUnitHelper) {
        _audioUnitHelper = [AudioUnitHelper new];
    }
    return _audioUnitHelper;
}


@end
