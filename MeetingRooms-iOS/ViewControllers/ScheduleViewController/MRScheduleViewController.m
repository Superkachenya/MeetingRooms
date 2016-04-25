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

static CGFloat const kMinimalRowHeight = 116.0;
static NSInteger const kSunday = 1;
static NSInteger const kNextWeek = 7;
static NSInteger const kPreviousWeek = -7;


@interface MRScheduleViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *monthDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *yearLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutletCollection(UIButton)NSArray *dateButtons;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *weekDayOutViews;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *weekdayInViews;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *weekdayLabels;
@property (weak, nonatomic) IBOutlet UIView *swipeView;

@property (strong, nonatomic) MRNetworkManager *manager;
@property (strong, nonatomic) NSCalendar *calendar;
@property (strong, nonatomic) NSDate *currentDate;

@property (strong, nonatomic) NSMutableArray *arrayOfAllMeetings;

@end

@implementation MRScheduleViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    self.currentDate = [NSDate date];
    self.calendar = [NSCalendar currentCalendar];
    self.manager = [MRNetworkManager sharedManager];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = kMinimalRowHeight;
    [self loadMeetingsToDate:self.currentDate];
    [self configureViewsForDays];
    [self configureLabels];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - UIViewController helpers

- (void)configureViewsForDays {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"MMM d"];
    self.monthDateLabel.text = [dateFormatter stringFromDate:self.currentDate];
    [dateFormatter setDateFormat:@"yyyy"];
    self.yearLabel.text = [dateFormatter stringFromDate:self.currentDate];
    NSDateComponents *components = [self.calendar components:NSUIntegerMax fromDate:self.currentDate];
    UIView *weekdayIn = nil;
    NSUInteger day;
    for (UIView *weekdayOut in self.weekDayOutViews) {
        day = [self.weekDayOutViews indexOfObject:weekdayOut];
        weekdayIn = self.weekdayInViews[day];
        if (day == components.weekday) {
            weekdayOut.backgroundColor = [UIColor whiteColor];
            weekdayIn.backgroundColor = [UIColor getUIColorFromHexString:@"#ff5a5f"];
        } else {
            weekdayOut.backgroundColor = [UIColor getUIColorFromHexString:@"#302D44"];
            weekdayIn.backgroundColor = [UIColor getUIColorFromHexString:@"#4e4b62"];
        }
    }
}

- (void)configureLabels {
    [self.manager getAllMeetingsForWeekSinceDate:[self findNearestMonday] completion:^(id success, NSError *error) {
        if (error) {
            [self createAlertForError:error];
        } else {
            NSArray *tempArray = success;
            NSUInteger index;
            for (UILabel *weekday in self.weekdayLabels) {
                index = [self.weekdayLabels indexOfObject:weekday];
                NSNumber *todaysCount = tempArray[index];
                weekday.text = todaysCount.stringValue;
            }
        }
    }];
}

- (NSDate *)findNearestMonday {
    NSDateComponents *weekdayComponents = [self.calendar components:NSCalendarUnitWeekday fromDate:self.currentDate];
    NSDateComponents *componentsToSubtract = [NSDateComponents new];
    [componentsToSubtract setDay: kSunday - (weekdayComponents.weekday - 1)];
    NSDate *nearestMonday = [self.calendar dateByAddingComponents:componentsToSubtract toDate:self.currentDate options:0];
    return nearestMonday;
}

- (void)loadMeetingsToDate:(NSDate *)date {
    [self.manager getAllOwnersMeetingsForDate:date offset:self.arrayOfAllMeetings.count WithCompletionBlock:^(id success, NSError *error) {
        if (error) {
            [self createAlertForError:error];
        } else {
            if (!self.arrayOfAllMeetings) {
                self.arrayOfAllMeetings = [NSMutableArray new];
            }
            [self.arrayOfAllMeetings addObjectsFromArray:success];
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayOfAllMeetings.count;
}

- (MRCustomScheduleCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MRCustomScheduleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    MRMeeting *currentMeeting = [self.arrayOfAllMeetings objectAtIndex:indexPath.row];
    [cell configureCellWithMeeting:currentMeeting atIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.arrayOfAllMeetings.count - 1) {
        [self loadMeetingsToDate:self.currentDate];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toMeetingDetails"]) {
        MRMeetingDetails *details = segue.destinationViewController;
        NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
        MRMeeting *sendMeeting = self.arrayOfAllMeetings[indexPath.row];
        details.meeting = sendMeeting;
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    }
}

- (IBAction)prepareForUnwindSegueToSheduleScene:(UIStoryboardSegue *)segue {
    self.arrayOfAllMeetings = nil;
    [self loadMeetingsToDate:self.currentDate];
    [self configureLabels];
    [self configureViewsForDays];
    [self.tableView reloadData];
}

#pragma mark - HandleEvents

- (IBAction)dateButtonDidPress:(UIButton *)sender {
    NSDateComponents *dayComponent = [NSDateComponents new];
    dayComponent.day = [self.dateButtons indexOfObject:sender];
    NSDate *date = [self.calendar dateByAddingComponents:dayComponent toDate:[self findNearestMonday] options:0];
    self.currentDate = date;
    self.arrayOfAllMeetings = nil;
    [self loadMeetingsToDate:date];
    [self configureViewsForDays];
}

- (IBAction)swipeDidSwipeLeft:(id)sender {
    [UIView transitionWithView:self.swipeView
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    animations:^{
                        NSDateComponents *dayComponent = [NSDateComponents new];
                        dayComponent.day = kNextWeek;
                        NSDate *date = [self.calendar dateByAddingComponents:dayComponent toDate:[self findNearestMonday] options:0];
                        self.currentDate = date;
                        self.arrayOfAllMeetings = nil;
                        [self loadMeetingsToDate:date];
                        [self configureLabels];
                        [self configureViewsForDays];
                    }
                    completion:nil];
}

- (IBAction)swipeDidSwipeRight:(id)sender {
    [UIView transitionWithView:self.swipeView
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        NSDateComponents *dayComponent = [NSDateComponents new];
                        dayComponent.day = kPreviousWeek;
                        NSDate *date = [self.calendar dateByAddingComponents:dayComponent toDate:[self findNearestMonday] options:0];
                        self.currentDate = date;
                        self.arrayOfAllMeetings = nil;
                        [self loadMeetingsToDate:date];
                        [self configureLabels];
                        [self configureViewsForDays];
                    }
                    completion:nil];
}

@end
