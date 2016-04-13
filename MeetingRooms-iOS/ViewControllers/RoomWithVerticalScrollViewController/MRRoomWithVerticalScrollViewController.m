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

@interface MRRoomWithVerticalScrollViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *arrayOfHours;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *arrayMeetings;
@property (strong, nonatomic) NSMutableArray *arrayMeetingsCurrentHour;
@property (strong, nonatomic) NSMutableDictionary *hours;

@end

@implementation MRRoomWithVerticalScrollViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setNeedsStatusBarAppearanceUpdate];
    self.hours = [[NSMutableDictionary alloc] init];
    self.arrayMeetings = [[NSMutableArray alloc] init];
    self.arrayMeetingsCurrentHour = [[NSMutableArray alloc] init];
    self.arrayOfHours = [[NSArray alloc] initWithObjects:@"8:00",@"9:00",@"10:00",@"11:00",@"12:00",@"13:00",@"14:00",@"15:00", @"16:00",@"17:00",@"18:00",@"19:00",@"20:00", @"21:00", nil];
    self.tableView.allowsSelection = NO;
    [self loadMeetings];
   // self.arrayMeetings =  [self sortArrayOfMeetingsCurrentHour:self.arrayMeetings];
    //[self fillDictionaryHours];
    NSLog(@"ert");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return  self.arrayOfHours.count - 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.arrayOfHours objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *sectionTitle = [self.arrayOfHours objectAtIndex:section];
    NSArray *sectionMeetings = [self.hours objectForKey:sectionTitle];
    return sectionMeetings.count;
}

- (MRTableViewCustomCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MRTableViewCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    [cell configureCellAtIndexPath:indexPath withHour:self.arrayOfHours[indexPath.row]];
    
    NSString *sectionTitle = [self.arrayOfHours objectAtIndex:indexPath.section];
    NSArray *sectionAnimals = [self.hours objectForKey:sectionTitle];
    MRMeeting *currentMeeting = [sectionAnimals objectAtIndex:indexPath.row];
    [cell configureCellWithMeeting:currentMeeting];
    
    return cell;
}

- (NSMutableArray *)sortArrayOfMeetingsCurrentHour:(NSMutableArray *)array {
    NSSortDescriptor *dateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"meetingStart" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:dateDescriptor];
    array = (NSMutableArray *)[array sortedArrayUsingDescriptors:sortDescriptors];
    return  array;
}

- (void)fillDictionaryHours {
    for (int i = 0; i < self.arrayOfHours.count - 1; ++i) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        dateFormat.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:2];
        [dateFormat setDateFormat:@"HH:mm"];
        NSDate *dateCurrent = [dateFormat dateFromString:self.arrayOfHours[i]];
        NSDate *dateInHour = [dateFormat dateFromString:self.arrayOfHours[i + 1]];
        self.arrayMeetingsCurrentHour = [[NSMutableArray alloc] init];
        [self.hours setObject:self.arrayMeetingsCurrentHour forKey:self.arrayOfHours[i]];
        //[array addObject:@"withOutMeetings"];
        for (MRMeeting *meeting in self.arrayMeetings) {
            if (([meeting.meetingStart compare:dateCurrent] ==  NSOrderedDescending ||
                 [meeting.meetingStart compare:dateCurrent] ==  NSOrderedSame) &&
                [meeting.meetingStart compare:dateInHour] ==  NSOrderedAscending) {
                [self.arrayMeetingsCurrentHour addObject:meeting];
            }
        }
    }
    //NSLog(@"dateInHour - %@", dateInHour.description);
}

- (void)loadMeetings {
    NSDate *date = [[NSDate alloc] init];
    [[MRNetworkManager sharedManager] getRoomInfoById:self.room.roomId toDate:date completion:^(id success, NSError *error) {
        if (error) {
            [self createAlertForError:error];
        } else {
            [self.arrayMeetings addObjectsFromArray:success];
            [self sortArrayOfMeetingsCurrentHour:self.arrayMeetings];
            [self fillDictionaryHours];
            [self.tableView reloadData];
        }
    }];
}

@end
