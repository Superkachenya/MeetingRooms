//
//  MRScheduleViewController.m
//  MeetingRooms-iOS
//
//  Created by Alex on 4/15/16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

#import "MRScheduleViewController.h"
#import "UIColor+MRColorFromHEX.h"
#import "MRMeeting.h"
#import "MRCustomScheduleCell.h"
#import "MRNetworkManager.h"
#import "UIViewController+MRErrorAlert.h"
#import "MRMeetingDetails.h"

typedef NS_ENUM(NSInteger, MRWeekdays) {
    MRSunday = 1,
    MRMonday,
    MRTuesday,
    MRWednesday,
    MRThursday,
    MRFriday,
    MRSaturday
};

static CGFloat const kMinimalRowHeight = 116.0;

@interface MRScheduleViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *monthDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *yearLabel;
@property (weak, nonatomic) IBOutlet UIView *mondayViewOut;
@property (weak, nonatomic) IBOutlet UIView *mondayViewIn;
@property (weak, nonatomic) IBOutlet UILabel *mondayLabel;
@property (weak, nonatomic) IBOutlet UIView *tuesdayViewOut;
@property (weak, nonatomic) IBOutlet UIView *tuesdayViewIn;
@property (weak, nonatomic) IBOutlet UILabel *tuesdayLabel;
@property (weak, nonatomic) IBOutlet UIView *wednesdayViewOut;
@property (weak, nonatomic) IBOutlet UIView *wednesdayViewIn;
@property (weak, nonatomic) IBOutlet UILabel *wednesdayLabel;
@property (weak, nonatomic) IBOutlet UIView *thursdayViewOut;
@property (weak, nonatomic) IBOutlet UIView *thursdayViewIn;
@property (weak, nonatomic) IBOutlet UILabel *thursdayLabel;
@property (weak, nonatomic) IBOutlet UIView *fridayViewOut;
@property (weak, nonatomic) IBOutlet UIView *fridayViewIn;
@property (weak, nonatomic) IBOutlet UILabel *fridayLabel;
@property (weak, nonatomic) IBOutlet UIView *saturdayViewOut;
@property (weak, nonatomic) IBOutlet UIView *saturdayViewIn;
@property (weak, nonatomic) IBOutlet UIView *sundayViewOut;
@property (weak, nonatomic) IBOutlet UIView *sundayViewIn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) MRNetworkManager *manager;

@property (strong, nonatomic) NSMutableArray *sortedArrayMeetings;
@property (strong, nonatomic) NSMutableArray *arrayOfAllMeetings;

@end

@implementation MRScheduleViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    self.sortedArrayMeetings = [NSMutableArray new];
    self.manager = [MRNetworkManager sharedManager];
    [self loadMeetings];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = kMinimalRowHeight;
    [self configureViewsForDays];
    [self configureLabels];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - UIViewController helpers

- (void)configureViewsForDays {
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"MMM d"];
    self.monthDateLabel.text = [dateFormatter stringFromDate:date];
    [dateFormatter setDateFormat:@"yyyy"];
    self.yearLabel.text = [dateFormatter stringFromDate:date];
    NSCalendar *gregorian = [NSCalendar currentCalendar];
    NSDateComponents *components = [gregorian components:NSUIntegerMax fromDate:date];
    switch (components.weekday) {
        case MRSunday:
            self.sundayViewOut.backgroundColor = [UIColor whiteColor];
            self.sundayViewIn.backgroundColor = [UIColor getUIColorFromHexString:@"FF5A5F"];
            break;
        case MRMonday:
            self.mondayViewOut.backgroundColor = [UIColor whiteColor];
            self.mondayViewIn.backgroundColor = [UIColor getUIColorFromHexString:@"FF5A5F"];
            break;
        case MRTuesday:
            self.tuesdayViewOut.backgroundColor = [UIColor whiteColor];
            self.tuesdayViewIn.backgroundColor = [UIColor getUIColorFromHexString:@"FF5A5F"];
            break;
        case MRWednesday:
            self.wednesdayViewOut.backgroundColor = [UIColor whiteColor];
            self.wednesdayViewIn.backgroundColor = [UIColor getUIColorFromHexString:@"FF5A5F"];
            break;
        case MRThursday:
            self.thursdayViewOut.backgroundColor = [UIColor whiteColor];
            self.thursdayViewIn.backgroundColor = [UIColor getUIColorFromHexString:@"FF5A5F"];
            break;
        case MRFriday:
            self.fridayViewOut.backgroundColor = [UIColor whiteColor];
            self.fridayViewIn.backgroundColor = [UIColor getUIColorFromHexString:@"FF5A5F"];
            break;
        case MRSaturday:
            self.saturdayViewOut.backgroundColor = [UIColor whiteColor];
            self.saturdayViewIn.backgroundColor = [UIColor getUIColorFromHexString:@"FF5A5F"];
            break;
    }
}

- (void)configureLabels {
    NSDate *nearestMonday = [self findNearestMonday];
    NSArray *arrayOfLabels = @[self.mondayLabel, self.tuesdayLabel, self.wednesdayLabel,
                               self.thursdayLabel, self.fridayLabel];
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    dayComponent.day = 0;
    for (UILabel *label in arrayOfLabels) {
        NSCalendar *theCalendar = [NSCalendar currentCalendar];
        NSDate *nextDate = [theCalendar dateByAddingComponents:dayComponent toDate:nearestMonday options:0];
        [self.manager getAllOwnersMeetingsForDate:nextDate offset:0
                              WithCompletionBlock:^(id success, NSError *error) {
                                  if (error) {
                                      [self createAlertForError:error];
                                  } else {
                                      self.arrayOfAllMeetings = success;
                                      label.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.arrayOfAllMeetings.count];
                                  }
                              }];
        dayComponent.day++;
    }
}

- (NSDate *)findNearestMonday {
    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [NSCalendar currentCalendar];
    NSDateComponents *weekdayComponents = [gregorian components:NSCalendarUnitWeekday fromDate:today];
    NSDateComponents *componentsToSubtract = [NSDateComponents new];
    [componentsToSubtract setDay: 1 - (weekdayComponents.weekday - 1)];
    NSDate *nearestMonday = [gregorian dateByAddingComponents:componentsToSubtract toDate:today options:0];
    return nearestMonday;
}

- (void)loadMeetings {
    [self.manager getAllOwnersMeetingsForDate:[NSDate date] offset:self.sortedArrayMeetings.count WithCompletionBlock:^(id success, NSError *error) {
        if (error) {
            [self createAlertForError:error];
        } else {
            [self.sortedArrayMeetings addObjectsFromArray:[self sortArrayOfMeetingsCurrentHour:success]];
            [self.tableView reloadData];
        }
    }];
}

- (NSMutableArray *)sortArrayOfMeetingsCurrentHour:(NSMutableArray *)array {
    NSSortDescriptor *dateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"meetingStart" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:dateDescriptor];
    array = (NSMutableArray *)[array sortedArrayUsingDescriptors:sortDescriptors];
    return  array;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sortedArrayMeetings.count;
}

- (MRCustomScheduleCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MRCustomScheduleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    MRMeeting *currentMeeting = [self.sortedArrayMeetings objectAtIndex:indexPath.row];
    [cell configureCellWithMeeting:currentMeeting atIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.sortedArrayMeetings.count - 1) {
        [self loadMeetings];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toMeetingDetails"]) {
        MRMeetingDetails *details = segue.destinationViewController;
        NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
        MRMeeting *sendMeeting = self.sortedArrayMeetings[indexPath.row];
        details.meeting = sendMeeting;
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    }
}

- (IBAction)prepareForUnwindSegueToSheduleScene:(UIStoryboardSegue *)segue {
    [self loadMeetings];
}

@end
