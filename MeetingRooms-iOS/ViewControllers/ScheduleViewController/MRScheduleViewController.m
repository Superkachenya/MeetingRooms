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

typedef NS_ENUM(NSInteger, MRWeekdays) {
    MRSunday = 1,
    MRMonday,
    MRTuesday,
    MRWednesday,
    MRThursday,
    MRFriday,
    MRSaturday
};

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

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *viewsOut;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *viewsIn;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *labels;
@property (strong, nonatomic) MRNetworkManager *manager;

@property (strong, nonatomic) NSMutableArray *sortedArrayMeetings;

@end

@implementation MRScheduleViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    self.sortedArrayMeetings = [NSMutableArray new];
    self.manager = [MRNetworkManager sharedManager];
    [self loadMeetings];
    [self configureLabels];
    self.tableView.allowsSelection = NO;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 116.0;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - UIViewController helpers

- (void)configureLabels {
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM d"];
    self.monthDateLabel.text = [dateFormatter stringFromDate:date];
    [dateFormatter setDateFormat:@"yyyy"];
    self.yearLabel.text = [dateFormatter stringFromDate:date];
    NSLog(@"%lu", (unsigned long)self.viewsIn.count);
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components: NSUIntegerMax fromDate:date];
    switch (components.weekday) {
        case MRSunday:
            self.sundayViewOut.backgroundColor = [UIColor whiteColor];
            self.sundayViewIn.backgroundColor = [UIColor getUIColorFromHexString:@"FF5A5F"];
            break;
        case MRMonday:
            self.mondayViewOut.backgroundColor = [UIColor whiteColor];
            self.mondayViewIn.backgroundColor = [UIColor getUIColorFromHexString:@"FF5A5F"];
            self.mondayLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.sortedArrayMeetings.count];
            self.mondayLabel.adjustsFontSizeToFitWidth = YES;
            break;
        case MRTuesday:
            self.tuesdayViewOut.backgroundColor = [UIColor whiteColor];
            self.tuesdayViewIn.backgroundColor = [UIColor getUIColorFromHexString:@"FF5A5F"];
            self.tuesdayLabel.adjustsFontSizeToFitWidth = YES;
            break;
        case MRWednesday:
            self.wednesdayViewOut.backgroundColor = [UIColor whiteColor];
            self.wednesdayViewIn.backgroundColor = [UIColor getUIColorFromHexString:@"FF5A5F"];
            self.wednesdayLabel.adjustsFontSizeToFitWidth = YES;
            break;
        case MRThursday:
            self.thursdayViewOut.backgroundColor = [UIColor whiteColor];
            self.thursdayViewIn.backgroundColor = [UIColor getUIColorFromHexString:@"FF5A5F"];
            self.thursdayLabel.adjustsFontSizeToFitWidth = YES;
            break;
        case MRFriday:
            self.fridayViewOut.backgroundColor = [UIColor whiteColor];
            self.fridayViewIn.backgroundColor = [UIColor getUIColorFromHexString:@"FF5A5F"];
            self.fridayLabel.adjustsFontSizeToFitWidth = YES;
            break;
        case MRSaturday:
            self.saturdayViewOut.backgroundColor = [UIColor whiteColor];
            self.saturdayViewIn.backgroundColor = [UIColor getUIColorFromHexString:@"FF5A5F"];
            break;
    }
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
    [cell configureCellWithMeeting:currentMeeting atIndexpath:indexPath];
    return cell;
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
