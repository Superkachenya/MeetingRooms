//
//  MRRoomWithVerticalScrollViewController.m
//  MeetingRooms-iOS
//
//  Created by Alex on 08.04.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

#import "MRRoomWithVerticalScrollViewController.h"
#import "UIViewController+MRErrorAlert.h"
#import "MRTableViewCustomCell.h"
#import "MRMeeting.h"
#import "MRUser.h"
#import "MRNetworkManager.h"
#import "UIColor+MRColorFromHEX.h"

@interface MRRoomWithVerticalScrollViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *arrayOfHours;
@property (strong, nonatomic) NSMutableArray *arrayMeetings;
@property (strong, nonatomic) NSMutableDictionary *hours;
@property (assign, nonatomic) NSUInteger count;

@end

@implementation MRRoomWithVerticalScrollViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.count = 8;
    [self setNeedsStatusBarAppearanceUpdate];
    self.hours = [[NSMutableDictionary alloc] init];
    self.arrayMeetings = [[NSMutableArray alloc] init];
    self.arrayOfHours = [[NSArray alloc] initWithObjects:@"8:00",@"9:00",@"10:00",@"11:00",@"12:00",@"13:00",@"14:00",
                         @"15:00", @"16:00",@"17:00",@"18:00",@"19:00",@"20:00", @"21:00", nil];
    self.tableView.allowsSelection = NO;
    [self loadMeetings];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - UIViewController helpers

- (NSMutableArray *)sortArrayOfMeetingsCurrentHour:(NSMutableArray *)array {
    NSSortDescriptor *dateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"meetingStart" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:dateDescriptor];
    array = (NSMutableArray *)[array sortedArrayUsingDescriptors:sortDescriptors];
    return  array;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return  self.arrayOfHours.count - 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *sectionTitle = [self.arrayOfHours objectAtIndex:section];
    NSArray *sectionMeetings = [self.hours objectForKey:sectionTitle];
    return sectionMeetings.count;
}

- (MRTableViewCustomCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MRTableViewCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSString *sectionTitle = [self.arrayOfHours objectAtIndex:indexPath.section];
    NSArray *sectionAnimals = [self.hours objectForKey:sectionTitle];
    MRMeeting *currentMeeting = [sectionAnimals objectAtIndex:indexPath.row];
    [cell configureCellWithMeeting:currentMeeting];
    return cell;
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width, 18)];
    [label setFont:[UIFont fontWithName:@"GlacialIndifference-Regular" size:18]];
    [label setTextColor:[UIColor whiteColor]];
    NSString *string = [self.arrayOfHours objectAtIndex:section];
    [label setText:string];
    [view addSubview:label];
    NSInteger yPosition = [self findY:section + 8];
    UIView *currentTime = [[UIView alloc] init];
    if (yPosition >= 0) {
        currentTime.frame = CGRectMake(0, yPosition, 3, 3);
        currentTime.layer.cornerRadius = 1.5;
        currentTime.backgroundColor = [UIColor redColor];
        [view addSubview:currentTime];
    }
    return view;
}

#pragma mark - UITableViewDelegate helpers

- (NSInteger)findY:(NSUInteger)hour {
    if ([self comparisonWithStartMinute:0 finishMinute:10 startHour:hour finishHour:hour]) {
        return 1;
    } else if ([self comparisonWithStartMinute:10 finishMinute:20 startHour:hour finishHour:hour]) {
        return 4;
    } else if ([self comparisonWithStartMinute:20 finishMinute:30 startHour:hour finishHour:hour]) {
        return 7;
    } else if ([self comparisonWithStartMinute:30 finishMinute:40 startHour:hour finishHour:hour]) {
        return 10;
    } else if ([self comparisonWithStartMinute:40 finishMinute:50 startHour:hour finishHour:hour]) {
        return 13;
    } else if ([self comparisonWithStartMinute:50 finishMinute:00 startHour:hour finishHour:hour + 1]) {
        return 16;
    } else {
        return -1;
    }
}

- (BOOL)comparisonWithStartMinute:(NSInteger )startMinute finishMinute:(NSInteger )finishMinute
                        startHour:(NSInteger )startHour finishHour:(NSInteger )finishHour {
    NSDate *current = [[NSDate alloc] init];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components: NSUIntegerMax fromDate:current];
    [components setHour: startHour];
    [components setMinute: startMinute];
    [components setSecond: 0];
    NSDate *dateStart = [gregorian dateFromComponents: components];
    [components setHour: finishHour];
    [components setMinute: finishMinute];
    [components setSecond: 0];
    NSDate *dateIn10Minutes = [gregorian dateFromComponents: components];
    if (([dateStart compare:current] ==  NSOrderedAscending ||
         [dateStart compare:current] ==  NSOrderedSame) &&
        [dateIn10Minutes compare:current] ==  NSOrderedDescending) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - Loading meetings and configuration

- (void)loadMeetings {
    NSDate *date = [[NSDate alloc] init];
    [[MRNetworkManager sharedManager] getRoomInfoById:self.room.roomId toDate:date completion:^(id success, NSError *error) {
        if (error) {
            [self createAlertForError:error];
        } else {
            self.navigationItem.title = self.room.roomTitle;
            [self.arrayMeetings addObjectsFromArray:success];
            [self sortArrayOfMeetingsCurrentHour:self.arrayMeetings];
            [self fillDictionaryHours];
            [self.tableView reloadData];
        }
    }];
}

- (void)fillDictionaryHours {
    for (int i = 0; i < self.arrayOfHours.count - 1; ++i) {
        NSDate *date = [NSDate date];
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
        NSDateComponents *components = [gregorian components: NSUIntegerMax fromDate:date];
        [components setHour: self.count - 1];
        [components setMinute: 59];
        [components setSecond: 0];
        NSDate *dateCurrent = [gregorian dateFromComponents: components];
        [components setMinute: 59];
        [components setHour: self.count++];
        NSDate *dateInHour = [gregorian dateFromComponents: components];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [self.hours setObject:array forKey:self.arrayOfHours[i]];
        for (MRMeeting *meeting in self.arrayMeetings) {
            if (([meeting.meetingStart compare:dateCurrent] ==  NSOrderedDescending ||
                 [meeting.meetingStart compare:dateCurrent] ==  NSOrderedSame) &&
                [meeting.meetingStart compare:dateInHour] ==  NSOrderedAscending) {
                [array addObject:meeting];
            }
        }
    }
}

- (IBAction)unwindToRoomWithVerticalScroll:(UIStoryboardSegue *)unwindSegue {
    
}


@end
