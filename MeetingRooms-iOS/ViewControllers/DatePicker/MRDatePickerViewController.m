//
//  MRDatePickerVC.m
//  MeetingRooms-iOS
//
//  Created by Danil on 14.04.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

#import "MRDatePickerViewController.h"
#import "UIColor+MRColorFromHEX.h"

@interface MRDatePickerViewController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

@implementation MRDatePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.datePicker.minimumDate = [NSDate date];
}
- (IBAction)userDidChangeDate:(UIDatePicker *)sender {
    self.changedDate(sender.date);
}

@end
