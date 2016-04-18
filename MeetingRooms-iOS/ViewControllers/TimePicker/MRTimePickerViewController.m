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
    
    NSDateComponents *components = [NSDateComponents new];
    NSDate *donorDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    components = [calendar components:NSCalendarUnitMinute|
                                        NSCalendarUnitHour|
                                         NSCalendarUnitDay|
                                       NSCalendarUnitMonth|
                                        NSCalendarUnitYear fromDate:donorDate];
    components.hour = 8;
    components.minute = 0;
    NSDate *min = [calendar dateFromComponents:components];
    components.hour = 19;
    components.minute = 30;
    NSDate *max = [calendar dateFromComponents:components];
    self.timePicker.minimumDate = min;
    self.timePicker.maximumDate = max;
}

- (IBAction)userDidChangeTime:(UIDatePicker *)sender {
    self.changedTime(sender.date);
}

@end
