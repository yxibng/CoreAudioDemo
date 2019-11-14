//
//  MainViewController.m
//  CoreAudioDemos
//
//  Created by yxibng on 2019/11/12.
//  Copyright © 2019 姚晓丙. All rights reserved.
//

#import "MainViewController.h"
#import "AudioUnitRecordViewController.h"
#import "AudioUnitPlayerViewController.h"


static NSString *cellIdentifier = @"cell";

@interface MainViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:cellIdentifier];

    // Do any additional setup after loading the view.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    NSString *text = self.items[indexPath.row];
    cell.textLabel.text = text;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        AudioUnitRecordViewController *vc = [AudioUnitRecordViewController new];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (indexPath.row == 1) {
        AudioUnitPlayerViewController *vc = [AudioUnitPlayerViewController new];
        [self.navigationController pushViewController:vc animated:YES];
    }
    

}



- (NSArray *)items
{
    return @[@"Audio Unit record demo",
    @"Audio Unit play demo"];
}

@end
