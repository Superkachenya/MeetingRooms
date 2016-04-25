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
#import "MRRoom.h"
#import "MROwner.h"
#import "AFNetworking/AFNetworking.h"
#import "NSDate+MRNextMinute.h"
#import "MRNetworkManager.h"
#import "UIViewController+MRErrorAlert.h"
#import "MRRoomWithVerticalScrollViewController.h"
#import "UIColor+MRColorFromHEX.h"
#import "MRBookingViewController.h"

static const long kCountOfTimeSegment = 48;
static const long kWidthOfCell = 20;

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
@property (weak, nonatomic) IBOutlet UIImageView *userAvatar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *hieghtOfTableView;
@property (weak, nonatomic) IBOutlet UIView *bounseOfPicture;
@property (weak, nonatomic) IBOutlet UILabel *timeLabelOfMeeting;

@property (strong, nonatomic) NSMutableDictionary* dictonaryOfMeeting;
@property (assign, nonatomic) long countOfHidenCellOnView;
@property (assign, nonatomic) long indexOfCellWithNowLine;
@property (assign, nonatomic) long indexOfLastShowCell;

@end

@implementation MRRoomWithHorizontalScrollViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = self.room.roomTitle;
    self.room.meetings = [NSMutableArray new];
    self.countOfHidenCellOnView = ([self.horizontalTableView bounds].size.width / kWidthOfCell) / 2;
    self.hieghtOfTableView.constant = self.horizontalTableView.frame.size.width;
    self.tableView.frame = self.horizontalTableView.frame;
    self.tableView.contentSize = self.horizontalTableView.contentSize;
    [self selectTimeOnTimeLine];
    [self updateClocks];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self viewUpdate];
}

#pragma mark - UITableViewDataSource - 

- (NSInteger)tableView:(PTEHorizontalTableView *)horizontalTableView numberOfRowsInSection:(NSInteger)section {
    return kCountOfTimeSegment + (self.countOfHidenCellOnView * 2) ;
}

- (CGFloat)tableView:(PTEHorizontalTableView *)horizontalTableView widthForCellAtIndexPath:(NSIndexPath *)indexPath {
    return kWidthOfCell;
}

- (UITableViewCell *)tableView:(PTEHorizontalTableView *)horizontalTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MRTableViewHorizontalCell * cell = [horizontalTableView.tableView dequeueReusableCellWithIdentifier:@"cell"];
    [cell showTimeLineWithCountOfLine:kCountOfTimeSegment sizeOfViewIs:self.countOfHidenCellOnView atIndexCell:indexPath.row];
    long centrallCellRow = [self getCentralCellRowByIndexPath:indexPath.row];
    MRMeeting* meetting = [self.dictonaryOfMeeting objectForKey:[NSString stringWithFormat:@"%ld",centrallCellRow]];
    [self changeColorOfMeetingDetailsByMeeting:meetting andAbstractTime:centrallCellRow];
    MRMeeting* meeting = [self.dictonaryOfMeeting objectForKey:[NSString stringWithFormat:@"%ld",[NSNumber numberWithInteger:indexPath.row].longValue]];
    if (meeting) {
        if ([meeting.meetingOwner.email isEqualToString:[MRNetworkManager sharedManager].owner.email]) {
            [cell addMeeting:YES];
        } else {
            [cell addMeeting:NO];
        }
    }
    if (indexPath.row < self.indexOfCellWithNowLine) {
        [cell pastTime];
    } else {
        if (indexPath.row == self.indexOfCellWithNowLine) {
            [cell updateClocks];
        }
    }
    return cell;
}

# pragma mark - Helpers

- (long) getCentralCellRowByIndexPath:(long)index {
    long keyOfCell = index + self.countOfHidenCellOnView;
    if (index > self.indexOfLastShowCell) {
        keyOfCell = index - self.countOfHidenCellOnView;
    }
    self.indexOfLastShowCell = index;
    return keyOfCell;
}

- (void) createDictionaryWithMeeting {
    self.dictonaryOfMeeting = [NSMutableDictionary new];
    if ([self.room.meetings count]) {
        MRMeeting* meetting = [MRMeeting new];
        for (long i = 0; i < [self.room.meetings count]; i++) {
            meetting = self.room.meetings[i];
            long startAbstractTime = [NSDate timeToAbstractTime:meetting.meetingStart visiblePath:kCountOfTimeSegment andHidenPath:self.countOfHidenCellOnView];
            long endAbstractTime = [NSDate timeToAbstractTime:meetting.meetingFinish visiblePath:kCountOfTimeSegment andHidenPath:self.countOfHidenCellOnView];
            for (long i = startAbstractTime; i < endAbstractTime; i++) {
                [self.dictonaryOfMeeting setObject:meetting forKey:[NSString stringWithFormat:@"%ld",i]];
            }
        }
    }
}

- (void) showInfo:(MRMeeting*) meet {
    if (meet) {
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            UIImage* avatare = [UIImage imageWithData:[[NSData alloc] initWithContentsOfURL:meet.meetingOwner.avatar]];
            dispatch_async(dispatch_get_main_queue(), ^(void){
                self.userAvatar.image = avatare;
            });
        });
        self.name.text = [meet.meetingOwner.email componentsSeparatedByString: @"@"][0];
        self.detail.text = [NSString stringWithFormat:@"<< %@ >>",meet.meetingInfo];
        [self.detail setTextAlignment:NSTextAlignmentCenter];
        [self.detail setTextColor:[UIColor lightGrayColor]];
        NSDateFormatter *formatter = [NSDateFormatter new];
        [formatter setDateFormat:@"HH:mm"];
        NSString* timeFirst = [formatter stringFromDate:meet.meetingStart];
        NSString* timeSecond = [formatter stringFromDate:meet.meetingFinish];
        self.time.text = [NSString stringWithFormat:@"%@ - %@",timeFirst , timeSecond];
        CALayer * layer = [self.userAvatar layer];
        [layer setMasksToBounds:YES];
        [layer setCornerRadius:self.userAvatar.frame.size.width / 2];
        self.viewOfDetail.hidden = NO;
    } else {
        self.userAvatar.image = [UIImage new];
        self.viewOfDetail.hidden = YES;
    }
}

- (void) changeColorOfMeetingDetailsByMeeting:(MRMeeting*) meeting andAbstractTime:(long)abstractTime {
    long currentAbstractTime = [NSDate timeToAbstractTime:[NSDate new] visiblePath:kCountOfTimeSegment andHidenPath:self.countOfHidenCellOnView];
    if (currentAbstractTime < abstractTime) {
        if (meeting) {
            if ([meeting.meetingOwner.email isEqualToString:[MRNetworkManager sharedManager].owner.email]) {
                self.imageLine.image = [UIImage imageNamed:@"ic_curve_yellow"];
                self.bounseOfPicture.backgroundColor = [UIColor getUIColorFromHexString:@"F8E71C"];
                self.timeLabelOfMeeting.textColor = [UIColor getUIColorFromHexString:@"F8E71C"];
            } else {
                self.imageLine.image = [UIImage imageNamed:@"ic_curve_blue"];
                self.bounseOfPicture.backgroundColor = [UIColor getUIColorFromHexString:@"008FFB"];
                self.timeLabelOfMeeting.textColor = [UIColor getUIColorFromHexString:@"008FFB"];
            }
        } else {
            self.imageLine.image = [UIImage imageNamed:@"ic_curve_blue_red"];
        }
    } else {
        self.imageLine.image = [UIImage imageNamed:@"ic_curve_grey"];
        self.bounseOfPicture.backgroundColor = [UIColor getUIColorFromHexString:@"4E4B62"];
        self.timeLabelOfMeeting.textColor = [UIColor getUIColorFromHexString:@"4E4B62"];
    }
    [self showInfo:meeting];
}

- (void)refleshTimeLabel {
    if ([self getTimeFreeRoom:self.indexOfCellWithNowLine]) {
        NSTimeInterval interval = [[self getTimeFreeRoom:self.indexOfCellWithNowLine] timeIntervalSinceDate:[NSDate new]];
        int timeToFree = [NSNumber numberWithFloat:interval / 60].intValue;
        if (timeToFree < 60) {
            self.timeLabel.text = [NSString stringWithFormat:@"%dm. to the ending",timeToFree];
        } else {
            self.timeLabel.text = [NSString stringWithFormat:@"%dh. %dm. to the ending",timeToFree / 60,timeToFree % 60];
        }
    } else {
        self.timeLabel.text = @"Free now!";
    }
}

- (void)updateClocks {
    NSDate *actualTime = [NSDate date];
    NSTimeInterval delay = [[actualTime nextMinute] timeIntervalSinceDate:actualTime];
    NSDateFormatter *formater = [NSDateFormatter new];
    formater.dateFormat = @"HH:mm";
    self.clockTimeLabel.text = [formater stringFromDate:actualTime];
    formater.dateFormat = @"MMMM d";
    self.clockDateLabel.text = [formater stringFromDate:actualTime];
    [self refleshTimeLabel];
    __weak id weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf performSelector:@selector(updateClocks) withObject:nil afterDelay:delay];
    });
}

- (NSDate*) getTimeFreeRoom:(long)forTimeInAbstractTime {
    MRMeeting* meetting = [self.dictonaryOfMeeting objectForKey:[NSString stringWithFormat:@"%ld",forTimeInAbstractTime]];
    if (!meetting) {
        return nil;
    } else {
        if (![self.dictonaryOfMeeting objectForKey:[NSString stringWithFormat:@"%ld",forTimeInAbstractTime + 1]]) {
            return meetting.meetingFinish;
        } else {
            return [self getTimeFreeRoom:forTimeInAbstractTime + 1];
        }
    }
}

- (void) viewUpdate {
    long abstractTime = [NSDate timeToAbstractTime:[NSDate date] visiblePath:kCountOfTimeSegment andHidenPath:self.countOfHidenCellOnView];
    self.indexOfCellWithNowLine = [NSIndexPath indexPathForRow:abstractTime inSection:0].row;
    [self downloadAndUpdateDate];
}

- (void) selectTimeOnTimeLine {
    long abstractTime = [NSDate timeToAbstractTime:[NSDate date] visiblePath:kCountOfTimeSegment andHidenPath:self.countOfHidenCellOnView];
    NSIndexPath* ip = [NSIndexPath indexPathForRow:abstractTime - self.countOfHidenCellOnView inSection:0];
    [self.tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:YES];
    self.indexOfCellWithNowLine = [NSIndexPath indexPathForRow:abstractTime inSection:0].row;
}

- (void) downloadAndUpdateDate {
    [[MRNetworkManager sharedManager] getRoomInfoById:self.room.roomId toDate:nil completion:^(id success, NSError *error) {
        if (error) {
            [self createAlertForError:error];
        } else {
            self.room.meetings = [success copy];
            [self createDictionaryWithMeeting];
            [self.tableView reloadData];
            [self refleshTimeLabel];
        }
    }];
}

#pragma mark - Navigation -

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toVerticalScreen"]) {
        MRRoomWithVerticalScrollViewController *details = segue.destinationViewController;
        details.room = self.room;
    }
    if ([segue.identifier isEqualToString:@"toBookingScreenFromHorizontal"]) {
        MRBookingViewController *bookRoom = segue.destinationViewController;
        bookRoom.room = self.room;
    }
}

- (IBAction)unwindToRoomWithHorizontalScroll:(UIStoryboardSegue *)unwindSegue {
    
}

@end
