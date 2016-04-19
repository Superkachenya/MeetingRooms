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
#import "MROwner.h"
#import "AFNetworking/AFNetworking.h"
#import "NSDate+MRNextMinute.h"
#import "MRNetworkManager.h"
#import "UIViewController+MRErrorAlert.h"
#import "MRRoomWithVerticalScrollViewController.h"
#import "UIColor+MRColorFromHEX.h"
#import "MRBookingViewController.h"

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
@property (weak, nonatomic) IBOutlet UIView *bounseOfPicture;
@property (weak, nonatomic) IBOutlet UILabel *timeLabelOfMeeting;

@property (strong, nonatomic) NSMutableDictionary* dictonaryOfMeeting;
@property (strong, nonatomic) NSIndexPath* indexPathOfLastShowCell;
@property (strong, nonatomic) NSIndexPath* indexPathOfCentralCell;
@property (strong, nonatomic) MRMeeting* meetting;
@property (assign, nonatomic) long countOfCellOnView;

@end

@implementation MRRoomWithHorizontalScrollViewController

#pragma mark - UIViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = self.room.roomTitle;
    self.room.meetings = [NSMutableArray new];
    self.dictonaryOfMeeting = [NSMutableDictionary new];
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
    [cell showTimeLineWithCountOfLine:kCountOfTimeSigmente sizeOfViewIs:(self.countOfCellOnView/2)
                      onIndexPathCell:indexPath.row];
    long keyOfCell = (long)indexPath.row + self.countOfCellOnView/2;
    if (indexPath > self.indexPathOfLastShowCell) {
        keyOfCell = (long)indexPath.row - self.countOfCellOnView/2;
    }
    NSString *key = [NSString stringWithFormat:@"%ld",keyOfCell];
    self.imageLine.image = [UIImage imageNamed:@"ic_curve_blue_red"];
    self.meetting = [self.dictonaryOfMeeting objectForKey:key];
    self.timeLabel.text = [NSDate abstractTimeToTimeAfterNow:keyOfCell inTimeLineSegment:kCountOfTimeSigmente/2];
    if (![self.timeLabel.text isEqualToString:@"Past"]) {
        if (self.meetting) {
            if ([self.meetting.meetingOwner.email isEqualToString:[MRNetworkManager sharedManager].owner.email]) {
                [cell showYelloy];
                self.imageLine.image = [UIImage imageNamed:@"ic_curve_yellow"];
                self.bounseOfPicture.backgroundColor = [UIColor getUIColorFromHexString:@"F8E71C" alpha:1.0];
                self.timeLabelOfMeeting.textColor = [UIColor getUIColorFromHexString:@"F8E71C" alpha:1.0];
            } else {
                self.imageLine.image = [UIImage imageNamed:@"ic_curve_blue"];
                self.bounseOfPicture.backgroundColor = [UIColor getUIColorFromHexString:@"008FFB" alpha:1.0];
                self.timeLabelOfMeeting.textColor = [UIColor getUIColorFromHexString:@"008FFB" alpha:1.0];
            }
        }
    } else {
        self.imageLine.image = [UIImage imageNamed:@"ic_curve_grey"];
        self.bounseOfPicture.backgroundColor = [UIColor getUIColorFromHexString:@"4E4B62" alpha:1.0];
        self.timeLabelOfMeeting.textColor = [UIColor getUIColorFromHexString:@"4E4B62" alpha:1.0];
    }
    [self showInfo:self.meetting];
    
    if ([self.room.meetings count]) {
        for (long i = 0; i < [self.room.meetings count]; i++) {
            self.meetting = [MRMeeting new];
            self.meetting = self.room.meetings[i];
            NSNumber* startAbstractTime = [NSNumber numberWithLong:([[NSDate timeToAbstractTime:self.meetting.meetingStart
                                                                                        endTime:kCountOfTimeSigmente  +
                                                                      (self.countOfCellOnView/2)] longValue] +
                                                                    self.countOfCellOnView/2)];
            NSNumber* endAbstractTime = [NSNumber numberWithFloat:([[NSDate timeToAbstractTime:self.meetting.meetingFinish
                                                                                       endTime:kCountOfTimeSigmente  +
                                                                     (self.countOfCellOnView/2)] longValue] +
                                                                   self.countOfCellOnView/2)];
            if ((indexPath.row >= startAbstractTime.integerValue) && (indexPath.row < endAbstractTime.integerValue)) {
                if ([self.meetting.meetingOwner.email isEqualToString:[MRNetworkManager sharedManager].owner.email]) {
                    [cell addMeeting:YES];
                } else {
                    [cell addMeeting:NO];
                }
                NSString *key = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
                [self.dictonaryOfMeeting setObject:self.meetting forKey:key];
            }
        }
    }
    if (indexPath < self.indexPathOfCentralCell) {
        [cell pastTime];
    } else {
        if (indexPath == self.indexPathOfCentralCell) {
            [cell nowLineShow];
        }
    }
    [cell updateClocks];
    self.indexPathOfLastShowCell = indexPath;
    return cell;
}

# pragma mark - Helpers -

- (void) showInfo:(MRMeeting*) meet {
    if (meet) {
        NSArray *components = [meet.meetingOwner.email componentsSeparatedByString: @"@"];
        self.name.text = components[0];
        self.detail.text = meet.meetingInfo;
        [self.detail setTextAlignment:NSTextAlignmentCenter];
        [self.detail setTextColor:[UIColor lightGrayColor]];
        NSDateFormatter *formatter = [NSDateFormatter new];
        [formatter setDateFormat:@"HH:mm"];
        NSString* timeFirst = [formatter stringFromDate:meet.meetingStart];
        NSString* timeSecond = [formatter stringFromDate:meet.meetingFinish];
        self.time.text = [NSString stringWithFormat:@"%@ - %@",timeFirst , timeSecond];
        self.userAvatare.image = [UIImage imageNamed:@"Google+"];
        self.userAvatare.image = [UIImage imageWithData:[[NSData alloc] initWithContentsOfURL:meet.meetingOwner.avatar]];
        CALayer * l = [self.userAvatare layer];
        [l setMasksToBounds:YES];
        [l setCornerRadius:self.userAvatare.frame.size.width / 2];
        self.viewOfDetail.hidden = NO;
    } else {
        self.viewOfDetail.hidden = YES;
    }
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
    int time = [[clocksFormat stringFromDate:actualTime] intValue];
    if (time == 0 || time == 15 || time == 30 || time == 45) {
        [self viewUpdate];
    }
    __weak id weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf performSelector:@selector(updateClocks) withObject:nil afterDelay:delay];
    });
}

- (void) viewUpdate {
    NSDate *currentDate = [NSDate date];
    NSNumber* abstractTime = [NSDate timeToAbstractTime:currentDate endTime:kCountOfTimeSigmente  +
                              (self.countOfCellOnView/2)];
    abstractTime = [NSNumber numberWithFloat:([abstractTime floatValue] + self.countOfCellOnView/2)];
    self.indexPathOfCentralCell = [NSIndexPath indexPathForRow:abstractTime.integerValue inSection:0];
    [self downloadAndUpdateDate];
}

- (void) selectTimeOnTimeLine {
    NSDate *currentDate = [NSDate date];
    NSNumber* abstractTime = [NSDate timeToAbstractTime:currentDate endTime:kCountOfTimeSigmente  +
                              (self.countOfCellOnView/2)];
    NSIndexPath* ip = [NSIndexPath indexPathForRow:abstractTime.integerValue inSection:0];
    abstractTime = [NSNumber numberWithFloat:([abstractTime floatValue] + self.countOfCellOnView/2)];
    self.indexPathOfCentralCell = [NSIndexPath indexPathForRow:abstractTime.integerValue inSection:0];
    [self.tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void) downloadAndUpdateDate {
    [[MRNetworkManager sharedManager] getRoomInfoById:self.room.roomId toDate:nil completion:^(id success, NSError *error) {
        if (error) {
            [self createAlertForError:error];
        } else {
            self.room.meetings = [success copy];
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toVerticalScreen"]) {
        MRRoomWithVerticalScrollViewController *details = segue.destinationViewController;
        details.room = self.room;
    } else if ([segue.identifier isEqualToString:@"toBookingScreenFromHorizontal"]) {
        MRBookingViewController *booking = segue.destinationViewController;
        booking.room = self.room;
    }

}

- (IBAction)unwindToRoomWithHorizontalScroll:(UIStoryboardSegue *)unwindSegue {
    
}

@end
