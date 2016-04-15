//
//  MRTimePickerViewController.m
//  MeetingRooms-iOS
//
//  Created by Danil on 14.04.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

#import "MRTimePickerViewController.h"

@interface MRTimePickerViewController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *timePicker;

@end

@implementation MRTimePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)userDidChangeTime:(UIDatePicker *)sender {
    self.changedTime(sender.date);
}

@end
