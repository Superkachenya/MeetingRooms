//
//  MRDatePickerVC.m
//  MeetingRooms-iOS
//
//  Created by Danil on 14.04.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

#import "MRDatePickerViewController.h"

static double const kWeekInSeconds = 604800.0;

@interface MRDatePickerViewController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

@implementation MRDatePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.datePicker.minimumDate = [NSDate date];
    self.datePicker.maximumDate = [NSDate dateWithTimeIntervalSinceNow:kWeekInSeconds];
}
- (IBAction)userDidChangeDate:(UIDatePicker *)sender {
    self.changedDate(sender.date);
}

@end
