//
//  MRRoomWithHorizontalScrollViewController.m
//  MeetingRooms-iOS
//
//  Created by Sergey on 06.04.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

#import "MRRoomWithHorizontalScrollViewController.h"
#import "PTEHorizontalTableView.h"
#import "MRTableViewHorizontalCell.h"
#import "MRMeeting.h"
#import "MRUser.h"
#import "AFNetworking/AFNetworking.h"
#import "NSDate+MRNextMinute.h"
#import "MRNetworkManager.h"
#import "UIViewController+MRErrorAlert.h"
#import "MRRoomWithVerticalScrollViewController.h"

static const double kCountOfTimeSigmente = 48;
static const double kWidthOfCell = 20;

@interface MRRoomWithHorizontalScrollViewController () <PTETableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *clockTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *clockDateLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet PTEHorizontalTableView *horizontalTableView;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UITextView *detail;
@property (weak, nonatomic) IBOutlet UIView *viewOfDetail;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageLine;
@property (weak, nonatomic) IBOutlet UIImageView *userAvatare;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hieghtOfTableView;

@property (strong, nonatomic) NSMutableDictionary* dictonaryOfMeeting;
@property (strong, nonatomic) NSIndexPath* indexPathOfLastShowCell;
@property (strong, nonatomic) NSIndexPath* indexPathOfCentralCell;
@property (strong, nonatomic) NSMutableArray* arrayOfMeeting;
@property (strong, nonatomic) MRMeeting* meetting;
@property (assign, nonatomic) long countOfCellOnView;
@end

@implementation MRRoomWithHorizontalScrollViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = self.room.roomTitle;
    self.dictonaryOfMeeting = [NSMutableDictionary new];
    self.arrayOfMeeting = [NSMutableArray new];
    self.countOfCellOnView = ([self.horizontalTableView bounds].size.width / kWidthOfCell);
    self.hieghtOfTableView.constant = self.horizontalTableView.frame.size.width;
    self.tableView.frame = self.horizontalTableView.frame;
    self.tableView.contentSize = self.horizontalTableView.contentSize;
    [self selectTimeOnTimeLine];
    [self updateClocks];
    [self downloadAndUpdateDate];
}

#pragma mark - UITableViewDataSource - 

- (NSInteger)tableView:(PTEHorizontalTableView *)horizontalTableView numberOfRowsInSection:(NSInteger)section {
    return kCountOfTimeSigmente + self.countOfCellOnView ;
}

- (CGFloat)tableView:(PTEHorizontalTableView *)horizontalTableView widthForCellAtIndexPath:(NSIndexPath *)indexPath {
    return kWidthOfCell;
}

- (UITableViewCell *)tableView:(PTEHorizontalTableView *)horizontalTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MRTableViewHorizontalCell * cell = [horizontalTableView.tableView dequeueReusableCellWithIdentifier:@"cell"];
    [cell showTimeLineWithCountOfLine:kCountOfTimeSigmente sizeOfViewIs:(self.countOfCellOnView/2) onIndexPathCell:indexPath.row];
    if (indexPath > self.indexPathOfLastShowCell) {
        NSString* key = [NSString new];
        long keyOfCell = (long)indexPath.row - self.countOfCellOnView/2;
        key = [NSString stringWithFormat:@"%ld",keyOfCell];
        self.meetting = [self.dictonaryOfMeeting objectForKey:key];
        self.timeLabel.text = [self abstractTimeToTimeAfterNow:[NSNumber numberWithInteger:indexPath.row - self.countOfCellOnView/2]];
        if (![[self abstractTimeToTimeAfterNow:[NSNumber numberWithInteger:indexPath.row - self.countOfCellOnView/2]] isEqualToString:@"Past"]) {
            self.imageLine.image = [UIImage imageNamed:@"ic_curve_blue_red"];
        }
        [self showInfo:self.meetting];
    } else {
        NSString* key = [NSString new];
        long keyOfCell = (long)indexPath.row + self.countOfCellOnView/2;
        key = [NSString stringWithFormat:@"%ld",keyOfCell];
        self.meetting = [self.dictonaryOfMeeting objectForKey:key];
        self.timeLabel.text = [self abstractTimeToTimeAfterNow:[NSNumber numberWithInteger:indexPath.row + self.countOfCellOnView/2]];
        if (![[self abstractTimeToTimeAfterNow:[NSNumber numberWithInteger:indexPath.row + self.countOfCellOnView/2]] isEqualToString:@"Past"]) {
            self.imageLine.image = [UIImage imageNamed:@"ic_curve_blue_red"];
        }
        [self showInfo:self.meetting];
    }
    if (!self.meetting) {
        for (long i = 0; i < [self.arrayOfMeeting count]; i++) {
            self.meetting = self.arrayOfMeeting[i];
            NSNumber* startAbstractTime = [NSNumber numberWithLong:([[self timeToAbstractTime:self.meetting.meetingStart] longValue] + self.countOfCellOnView/2)];
            NSNumber* endAbstractTime = [NSNumber numberWithFloat:([[self timeToAbstractTime:self.meetting.meetingFinish] longValue] + self.countOfCellOnView/2)];
            if ((indexPath.row >= startAbstractTime.integerValue) && (indexPath.row < endAbstractTime.integerValue)) {
                [cell addMeeting];
                self.imageLine.image = [UIImage imageNamed:@"ic_curve_blue"];
                NSString* key = [NSString new];
                key = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
                [self.dictonaryOfMeeting setObject:self.meetting forKey:key];
                if ((startAbstractTime.integerValue < self.indexPathOfCentralCell.row) && (endAbstractTime.integerValue >= self.indexPathOfCentralCell.row)) {
                    [cell showYelloy];
                    self.imageLine.image = [UIImage imageNamed:@"ic_curve_yellow"];
                }
            }
        }
    }
    if (indexPath < self.indexPathOfCentralCell) {
        [cell pastTime];
        self.imageLine.image = [UIImage imageNamed:@"ic_curve_grey"];
    }
        self.indexPathOfLastShowCell = indexPath;
    return cell;
}

# pragma mark - Helpers -

- (NSString*) abstractTimeToTimeAfterNow:(NSNumber*)abstractTime {
    NSString* leftTimeIfStr = [NSString new];
    if ([abstractTime longValue] >= [[NSNumber numberWithInteger:self.indexPathOfCentralCell.row] longValue]) {
        long leftTime = [abstractTime longValue]  - [[NSNumber numberWithInteger:self.indexPathOfCentralCell.row] longValue];
        NSNumber* hours = [NSNumber numberWithFloat:(leftTime / 4)];
        NSNumber* minute = [NSNumber numberWithLong:((leftTime % 4)*15)];
        
        if ((!([minute longValue] == 0)) && (!([hours longValue] == 0))) {
            leftTimeIfStr = [NSString stringWithFormat:@"In %@ hours and %@ minute", hours, minute];
        } else {
            if ((!([minute longValue] == 0)) && (([hours longValue] == 0))) {
                leftTimeIfStr = [NSString stringWithFormat:@"In %@ minute", minute];
            } else {
                if ((([minute longValue] == 0)) && (!([hours longValue] == 0))) {
                    leftTimeIfStr = [NSString stringWithFormat:@"In %@ hours", hours];
                } else {
                    leftTimeIfStr = [NSString stringWithFormat:@"Now"];
                }
            }
        }
    } else {
        leftTimeIfStr = [NSString stringWithFormat:@"Past"];
    }
    return leftTimeIfStr;
}

- (NSNumber*) timeToAbstractTime:(NSDate *)time {
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"HH:mm"];
    NSString* timeString = [formatter stringFromDate:time];
    NSArray *components = [timeString componentsSeparatedByString: @":"];
    NSNumberFormatter *formater = [[NSNumberFormatter alloc] init];
    formater.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber* hours = [formater numberFromString:components[0]];
    NSNumber* minute = [formater numberFromString:components[1]];
    NSNumber* abstractTime = [NSNumber new];
    if ((hours >= [NSNumber numberWithInt:8]) && (hours <= [NSNumber numberWithInt:20])) {
        abstractTime = [NSNumber numberWithFloat:(([hours floatValue] - 8)*4)];
        if (minute >= [NSNumber numberWithInt:45]) {
            abstractTime = [NSNumber numberWithFloat:([abstractTime floatValue] + 3)];
        } else {
            if (minute >= [NSNumber numberWithInt:30]) {
                abstractTime = [NSNumber numberWithFloat:([abstractTime floatValue] + 2)];
            } else {
                if (minute >= [NSNumber numberWithInt:15]) {
                    abstractTime = [NSNumber numberWithFloat:([abstractTime floatValue] + 1)];
                }
            }
        }
    }
    if (!abstractTime) {
        if (hours < [NSNumber numberWithInt:8]) {
            abstractTime = [NSNumber numberWithFloat:(0)];
        } else {
            abstractTime = [NSNumber numberWithFloat:(kCountOfTimeSigmente  + (self.countOfCellOnView/2))];
        }
    }
    return abstractTime;
}

- (void) viewUpdate {
    NSDate *currentDate = [NSDate date];
    NSNumber* abstractTime = [self timeToAbstractTime:currentDate];
    abstractTime = [NSNumber numberWithFloat:([abstractTime floatValue] + self.countOfCellOnView/2)];
    self.indexPathOfCentralCell = [NSIndexPath indexPathForRow:abstractTime.integerValue inSection:0];
    [self downloadAndUpdateDate];
}

- (void)updateClocks {
    NSDate *actualTime = [NSDate date];
    NSTimeInterval delay = [[actualTime nextMinute] timeIntervalSinceDate:actualTime];
    NSDateFormatter *clocksFormat = [NSDateFormatter new];
    clocksFormat.dateFormat = @"HH:mm";
    NSDateFormatter *dateFormat = [NSDateFormatter new];
    dateFormat.dateFormat = @"MMMM d";
    self.clockTimeLabel.text = [clocksFormat stringFromDate:actualTime];
    self.clockDateLabel.text = [dateFormat stringFromDate:actualTime];
    clocksFormat.dateFormat = @"mm";
    switch ([[clocksFormat stringFromDate:actualTime] integerValue] ) {
        case 00:
            [self viewUpdate];
            break;
        case 15:
            [self viewUpdate];
            break;
        case 30:
            [self viewUpdate];
            break;
        case 45:
            [self viewUpdate];
            break;
    }
    __weak id weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf performSelector:@selector(updateClocks) withObject:nil afterDelay:delay];
    });
}

- (void) selectTimeOnTimeLine {
    NSDate *currentDate = [NSDate date];
    NSNumber* abstractTime = [self timeToAbstractTime:currentDate];
    NSIndexPath* ip = [NSIndexPath indexPathForRow:abstractTime.integerValue inSection:0];
    abstractTime = [NSNumber numberWithFloat:([abstractTime floatValue] + self.countOfCellOnView/2)];
    self.indexPathOfCentralCell = [NSIndexPath indexPathForRow:abstractTime.integerValue inSection:0];
    [self.tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void) showInfo:(MRMeeting*) meet {
    if (meet) {
        self.name.text = [NSString stringWithFormat:@"%@ %@", meet.meetingOwner.firstName, meet.meetingOwner.lastName];
        self.detail.text = [NSString stringWithFormat:@"<< %@ >>", meet.meetingInfo];
        NSDateFormatter *formatter = [NSDateFormatter new];
        [formatter setDateFormat:@"HH:mm"];
        NSString* timeFirst = [formatter stringFromDate:meet.meetingStart];
        NSString* timeSecond = [formatter stringFromDate:meet.meetingFinish];
        self.time.text = [NSString stringWithFormat:@"%@ - %@",timeFirst , timeSecond];
        self.userAvatare.image = [UIImage imageNamed:@"Google+"];
        self.userAvatare.image = [UIImage imageWithData:[[NSData alloc] initWithContentsOfURL:meet.meetingOwner.avatar]];
        self.viewOfDetail.hidden = NO;
    } else {
        self.viewOfDetail.hidden = YES;
    }
}

- (void) downloadAndUpdateDate {
//    [[MRNetworkManager sharedManager] getRoomInfoById:self.room.roomId toDate:nil completion:^(id success, NSError *error) {
//        if (error) {
//            [self createAlertForError:error];
//        } else {
//            self.arrayOfMeeting = success;
//            [self.tableView reloadData];
//        }
//    }];
}

#pragma mark - Navigation -

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"horizontalView"]) {
        MRRoomWithVerticalScrollViewController *details = segue.destinationViewController;
        details.room = self.room;
    }
}

- (IBAction)unwindToRoomWithHorizontalScroll:(UIStoryboardSegue *)unwindSegue {
    
}

@end
