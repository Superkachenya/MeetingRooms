///Users/chuchukalo_cr/Documents/Meetingrooms-iOS/MeetingRooms-iOS
//  MRTableViewHorizontalCell.m
//  MeetingRooms-iOS
//
//  Created by Sergey on 06.04.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

#import "MRTableViewHorizontalCell.h"
#import "UIColor+MRColorFromHEX.h"
#import "NSDate+MRNextMinute.h"

@interface MRTableViewHorizontalCell()

@property (weak, nonatomic) IBOutlet UIView *rightLine;
@property (weak, nonatomic) IBOutlet UIView *leftLine;
@property (weak, nonatomic) IBOutlet UIView *littleLeftLine;
@property (weak, nonatomic) IBOutlet UIView *littleRightLine;
@property (weak, nonatomic) IBOutlet UIView *statusLine;
@property (weak, nonatomic) IBOutlet UIView *nowLine;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIView *nowRedLine;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftOutletForNowRedLine;

@property (strong, nonatomic) NSDate *nextMinute;

@end

@implementation MRTableViewHorizontalCell

- (void)prepareForReuse {
    [super prepareForReuse];
    self.statusLine.backgroundColor = [UIColor getUIColorFromHexString:@"#FFFFFF" alpha:1];
    self.rightLine.backgroundColor = [UIColor getUIColorFromHexString:@"#FFFFFF" alpha:1];
    self.leftLine.backgroundColor = [UIColor getUIColorFromHexString:@"#FFFFFF" alpha:1];
    self.statusLine.hidden = NO;
    self.nowRedLine.hidden = YES;
}

- (void) showTimeLineWithCountOfLine:(long)countOfTimeLine sizeOfViewIs:(long)sizeOfHalfScreen onIndexPathCell:(long)indexPath{
    if ((indexPath >= sizeOfHalfScreen) && (indexPath < (countOfTimeLine + sizeOfHalfScreen))) {
        self.rightLine.hidden = NO;
        self.leftLine.hidden = NO;
        self.littleLeftLine.hidden = NO;
        self.littleRightLine.hidden = NO;
        self.timeLabel.hidden = NO;
        [self showTimeLine:indexPath - 1];
    } else {
        self.statusLine.hidden = YES;
        self.rightLine.hidden = YES;
        self.leftLine.hidden = YES;
        self.littleLeftLine.hidden = YES;
        self.littleRightLine.hidden = YES;
        self.nowLine.hidden = YES;
        self.timeLabel.hidden = YES;
        if ((indexPath + 1 == sizeOfHalfScreen) || (indexPath  == (countOfTimeLine + sizeOfHalfScreen))) {
            [self showFirstOrLast:indexPath - 1];
        }
    }
}

- (void) showTimeLine:(long) number {
    switch ((number % 4)) {
        case 0:
            self.timeLabel.text = @"00";
            self.timeLabel.textAlignment = NSTextAlignmentLeft;
            self.littleLeftLine.backgroundColor = [UIColor getUIColorFromHexString:@"#FFFFFF" alpha:1];
            self.littleRightLine.backgroundColor = [UIColor getUIColorFromHexString:@"#6A6776" alpha:1];
            break;
        case 1:
            self.timeLabel.hidden = YES;
            self.littleLeftLine.backgroundColor = [UIColor getUIColorFromHexString:@"#6A6776" alpha:1];
            self.littleRightLine.backgroundColor = [UIColor getUIColorFromHexString:@"#6A6776" alpha:1];
            break;
        case 2:
            self.timeLabel.hidden = YES;
            self.littleLeftLine.backgroundColor = [UIColor getUIColorFromHexString:@"#6A6776" alpha:1];
            self.littleRightLine.backgroundColor = [UIColor getUIColorFromHexString:@"#6A6776" alpha:1];
            break;
        case 3:
            self.timeLabel.text = [NSString stringWithFormat:@"%ld:",((number / 4) + 7)];
            self.timeLabel.textAlignment = NSTextAlignmentRight;
            self.littleLeftLine.backgroundColor = [UIColor getUIColorFromHexString:@"#6A6776" alpha:1];
            self.littleRightLine.backgroundColor = [UIColor getUIColorFromHexString:@"#FFFFFF" alpha:1];
            break;
    }
}

- (void) showFirstOrLast:(long) number {
    if ((number % 4) == 0) {
        self.timeLabel.hidden = NO;
        self.timeLabel.text = @"00";
        self.timeLabel.textAlignment = NSTextAlignmentLeft;
        self.littleLeftLine.backgroundColor = [UIColor getUIColorFromHexString:@"#FFFFFF" alpha:1];
    } else {
        self.timeLabel.hidden = NO;
        self.timeLabel.text = [NSString stringWithFormat:@"%ld:",((number / 4) + 7)];
        self.timeLabel.textAlignment = NSTextAlignmentRight;
        self.littleRightLine.backgroundColor = [UIColor getUIColorFromHexString:@"#FFFFFF" alpha:1];
    }
}

- (void) addMeeting {
    self.statusLine.backgroundColor = [UIColor getUIColorFromHexString:@"#008FFB" alpha:1];
    self.rightLine.backgroundColor = [UIColor getUIColorFromHexString:@"#6A6776" alpha:1];
    self.leftLine.backgroundColor = [UIColor getUIColorFromHexString:@"#6A6776" alpha:1];
}

- (void) showYelloy {
    if ([UIColor color:self.statusLine.backgroundColor isEqualToColor:[UIColor getUIColorFromHexString:@"#008FFB" alpha:1] withTolerance:0]) {
        self.nowLine.hidden = NO;
    }
}

- (void) nowLineShow {
    self.nowRedLine.hidden = NO;
}

- (void)updateClocks {
    NSDate *actualTime = [NSDate date];
    NSTimeInterval delay = [[actualTime nextMinute] timeIntervalSinceDate:actualTime];
    NSDateFormatter *clocksFormat = [NSDateFormatter new];
    clocksFormat.dateFormat = @"mm";
    if ([[clocksFormat stringFromDate:actualTime] integerValue] < 59) {
    switch ([[clocksFormat stringFromDate:actualTime] integerValue] ) {
        case 0:
            self.leftOutletForNowRedLine.constant = 0;
            break;
        case 3:
            self.leftOutletForNowRedLine.constant = 1;
            break;
        case 6:
            self.leftOutletForNowRedLine.constant = 2;
            break;
        case 9:
            self.leftOutletForNowRedLine.constant = 3;
            break;
        case 12:
            self.leftOutletForNowRedLine.constant = 4;
            break;
        case 15:
            self.leftOutletForNowRedLine.constant = 5;
            break;
        case 18:
            self.leftOutletForNowRedLine.constant = 6;
            break;
        case 21:
            self.leftOutletForNowRedLine.constant = 7;
            break;
        case 24:
            self.leftOutletForNowRedLine.constant = 8;
            break;
        case 27:
            self.leftOutletForNowRedLine.constant = 9;
            break;
        case 30:
            self.leftOutletForNowRedLine.constant = 10;
            break;
        case 33:
            self.leftOutletForNowRedLine.constant = 11;
            break;
        case 36:
            self.leftOutletForNowRedLine.constant = 12;
            break;
        case 39:
            self.leftOutletForNowRedLine.constant = 13;
            break;
        case 42:
            self.leftOutletForNowRedLine.constant = 14;
            break;
        case 45:
            self.leftOutletForNowRedLine.constant = 15;
            break;
        case 48:
            self.leftOutletForNowRedLine.constant = 16;
            break;
        case 51:
            self.leftOutletForNowRedLine.constant = 17;
            break;
        case 54:
            self.leftOutletForNowRedLine.constant = 18;
            break;
        case 57:
            self.leftOutletForNowRedLine.constant = 19;
            break;
    }
    __weak id weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf performSelector:@selector(updateClocks) withObject:nil afterDelay:delay];
    });
    }
}

- (void) pastTime {
    self.rightLine.backgroundColor = [UIColor getUIColorFromHexString:@"#39364D" alpha:1];
    self.leftLine.backgroundColor = [UIColor getUIColorFromHexString:@"#39364D" alpha:1];
    if ([UIColor color:self.statusLine.backgroundColor isEqualToColor:[UIColor getUIColorFromHexString:@"#FFFFFF" alpha:1] withTolerance:0]) {
        self.statusLine.hidden = YES;
    } else {
        self.statusLine.backgroundColor = [UIColor getUIColorFromHexString:@"#39364D" alpha:1];
    }
}

@end
