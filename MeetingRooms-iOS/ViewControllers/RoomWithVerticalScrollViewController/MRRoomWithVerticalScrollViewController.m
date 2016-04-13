//
//  MRRoomWithVerticalScrollViewController.m
//  MeetingRooms-iOS
//
//  Created by Alex on 08.04.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

#import "MRRoomWithVerticalScrollViewController.h"
#import "MRTableViewCustomCell.h"
#import "MRMeeting.h"
#import "MRUser.h"

@interface MRRoomWithVerticalScrollViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *arrayOfHours;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *arrayMeetings;
@property (strong, nonatomic) NSMutableArray *arrayMeetingsCurrentHour;

@end

@implementation MRRoomWithVerticalScrollViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setNeedsStatusBarAppearanceUpdate];
    self.arrayOfHours = [[NSArray alloc] initWithObjects:@"8:00",@"9:00",@"10:00",@"11:00",@"12:00",@"13:00",@"14:00",@"15:00", @"16:00",@"17:00",@"18:00",@"19:00",@"20:00", @"21:00", nil];
    self.tableView.allowsSelection = NO;
    
    self.arrayMeetings = [[NSMutableArray alloc] init];
    self.arrayMeetingsCurrentHour = [[NSMutableArray alloc] init];
    MRMeeting* meetOnTheDay = [MRMeeting new];
    meetOnTheDay.meetingInfo = @"first";
    NSString *dateStr = @"9:45";
    NSDateFormatter *dateFormat = [NSDateFormatter new];
    dateFormat.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:2];
    [dateFormat setDateFormat:@"HH:mm"];
    NSDate *date = [dateFormat dateFromString:dateStr];
    meetOnTheDay.meetingStart = date;
    dateStr = @"10:15";
    [dateFormat setDateFormat:@"HH:mm"];
    date = [dateFormat dateFromString:dateStr];
    meetOnTheDay.meetingFinish = date;
    MRUser* userInfo = [MRUser new];
    userInfo.firstName = @"first";
    userInfo.lastName = @"last";
    userInfo.avatar = [NSURL URLWithString:@"test url"];
    meetOnTheDay.meetingOwner = userInfo;
    [self.arrayMeetings addObject:meetOnTheDay];
    
    MRMeeting* from915 = [MRMeeting new];
    from915.meetingInfo = @"first2";
    NSString *dateStrq = @"9:15";
    NSDate *dateq = [dateFormat dateFromString:dateStrq];
    from915.meetingStart = dateq;
    dateStrq = @"9:30";
    dateq = [dateFormat dateFromString:dateStrq];
    from915.meetingFinish = dateq;
    MRUser* userInfoq = [MRUser new];
    userInfoq.firstName = @"first45";
    userInfoq.lastName = @"last45";
    userInfoq.avatar = [NSURL URLWithString:@"test url2"];
    from915.meetingOwner = userInfoq;
    [self.arrayMeetings addObject:from915];
    
    
    MRMeeting* smeetOnTheDayq = [MRMeeting new];
    smeetOnTheDayq.meetingInfo = @"firsasdasddasdast2";
    NSString *dateStrqq = @"9:00";
    NSDate *dateqq = [dateFormat dateFromString:dateStrqq];
    smeetOnTheDayq.meetingStart = dateqq;
    dateStrqq = @"9:15";
    dateqq = [dateFormat dateFromString:dateStrqq];
    smeetOnTheDayq.meetingFinish = dateqq;
    MRUser* userInfoqq = [MRUser new];
    userInfoqq.firstName = @"Hehe";
    userInfoqq.lastName = @"lheeeee";
    userInfoqq.avatar = [NSURL URLWithString:@"tesaasdasdrl2"];
    smeetOnTheDayq.meetingOwner = userInfoqq;
    [self.arrayMeetings addObject:smeetOnTheDayq];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 13;
}

- (MRTableViewCustomCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MRTableViewCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    [cell configureCellAtIndexPath:indexPath withHour:self.arrayOfHours[indexPath.row]];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:2];
    [dateFormat setDateFormat:@"HH:mm"];
    NSDate *dateCurrent = [dateFormat dateFromString:self.arrayOfHours[indexPath.row]];
    NSLog(@"arrayOfHours - %@", self.arrayOfHours[indexPath.row]);
    NSDate *dateInHour = [dateFormat dateFromString:self.arrayOfHours[indexPath.row + 1]];
    NSLog(@"dateCurrent - %@", dateCurrent.description);
    NSLog(@"dateInHour - %@", dateInHour.description);
    for (MRMeeting *meeting in self.arrayMeetings) {
        if (([meeting.meetingStart compare:dateCurrent] ==  NSOrderedDescending ||
            [meeting.meetingStart compare:dateCurrent] ==  NSOrderedSame) &&
            [meeting.meetingStart compare:dateInHour] ==  NSOrderedAscending) {
            [self.arrayMeetingsCurrentHour addObject:meeting];
        }
    }
    if (self.arrayMeetingsCurrentHour.count == 1) {
        [cell configureCellWithMeeting:self.arrayMeetingsCurrentHour[0]];
    } else if (self.arrayMeetingsCurrentHour.count > 1) {
        [self sortArrayOfMeetingsCurrentHour:self.arrayMeetingsCurrentHour];
        [cell configureCellWithMeeting:self.arrayMeetingsCurrentHour[0]];
    }
    return cell;
}

- (NSMutableArray *)sortArrayOfMeetingsCurrentHour:(NSMutableArray *)array {
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"meetingStart" ascending:YES];
    array = (NSMutableArray *)[array sortedArrayUsingDescriptors:@[sortDescriptor]];
    return  array;
}

@end
