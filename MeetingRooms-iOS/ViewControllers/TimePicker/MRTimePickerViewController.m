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
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitMinute|
                                    NSCalendarUnitHour|
                                    NSCalendarUnitDay|
                                    NSCalendarUnitMonth|
                                    NSCalendarUnitYear fromDate:self.minDate];
    NSDate *comparisonDate = [NSDate date];
    NSDateComponents *compareComponents = [calendar components:NSCalendarUnitDay|
                                           NSCalendarUnitMonth
                                                      fromDate:comparisonDate];
    if (components.day == compareComponents.day && components.month == compareComponents.month) {
        if (components.minute > 45) {
            components.hour ++;

        }
        self.timePicker.minimumDate = [NSDate date];
    } else {
        components.hour = 8;
        components.minute = 0;
        NSDate *min = [calendar dateFromComponents:components];
        self.timePicker.minimumDate = min;
    }
    components.hour = 19;
    components.minute = 45;
    NSDate *max = [calendar dateFromComponents:components];
    self.timePicker.maximumDate = max;
    self.changedTime(self.timePicker.minimumDate);
}

- (IBAction)userDidChangeTime:(UIDatePicker *)sender {
    self.changedTime(sender.date);
}

@end
