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
@property (weak, nonatomic) IBOutlet UIImageView *nowRedLine;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftOutletForNowRedLine;

@property (strong, nonatomic) NSDate *nextMinute;

@end

@implementation MRTableViewHorizontalCell

- (void)prepareForReuse {
    [super prepareForReuse];
    self.statusLine.backgroundColor = [UIColor whiteColor];
    self.rightLine.backgroundColor = [UIColor whiteColor];
    self.leftLine.backgroundColor = [UIColor whiteColor];
    self.statusLine.hidden = NO;
    self.nowRedLine.hidden = YES;
}

- (void)showTimeLineWithCountOfLine:(NSUInteger)countOfTimeLine sizeOfViewIs:(NSUInteger)sizeOfHalfScreen atIndexCell:(NSUInteger)index {
    if ((index + 1 > sizeOfHalfScreen) && (index < (countOfTimeLine + sizeOfHalfScreen))) {
        self.rightLine.hidden = NO;
        self.leftLine.hidden = NO;
        self.littleLeftLine.hidden = NO;
        self.littleRightLine.hidden = NO;
        self.timeLabel.hidden = NO;
        [self showTimeLine:index + 1];
    } else {
        self.statusLine.hidden = YES;
        self.rightLine.hidden = YES;
        self.leftLine.hidden = YES;
        self.littleLeftLine.hidden = YES;
        self.littleRightLine.hidden = YES;
        self.nowLine.hidden = YES;
        self.timeLabel.hidden = YES;
        if (index + 1 == sizeOfHalfScreen) {
            self.timeLabel.hidden = NO;
            self.timeLabel.text = @"8:";
            self.timeLabel.textAlignment = NSTextAlignmentRight;
            self.littleLeftLine.backgroundColor = [UIColor whiteColor];
        } else if (index  == countOfTimeLine + sizeOfHalfScreen) {
            self.timeLabel.hidden = NO;
            self.timeLabel.text = @"00";
            self.timeLabel.textAlignment = NSTextAlignmentLeft;
            self.littleRightLine.backgroundColor = [UIColor whiteColor];
        }
    }
}

- (void)showTimeLine:(NSUInteger)number {
    switch ((number % 4)) {
        case 0:
            self.timeLabel.text = @"00";
            self.timeLabel.textAlignment = NSTextAlignmentLeft;
            self.littleLeftLine.backgroundColor = [UIColor whiteColor];
            self.littleRightLine.backgroundColor = [UIColor getUIColorFromHexString:@"#6A6776"];
            break;
        case 1:
            self.timeLabel.hidden = YES;
            self.littleLeftLine.backgroundColor = [UIColor getUIColorFromHexString:@"#6A6776"];
            self.littleRightLine.backgroundColor = [UIColor getUIColorFromHexString:@"#6A6776"];
            break;
        case 2:
            self.timeLabel.hidden = YES;
            self.littleLeftLine.backgroundColor = [UIColor getUIColorFromHexString:@"#6A6776"];
            self.littleRightLine.backgroundColor = [UIColor getUIColorFromHexString:@"#6A6776"];
            break;
        case 3:
            self.timeLabel.text = [NSString stringWithFormat:@"%ld:",((long)(number / 4) + 5)];
            self.timeLabel.textAlignment = NSTextAlignmentRight;
            self.littleLeftLine.backgroundColor = [UIColor getUIColorFromHexString:@"#6A6776"];
            self.littleRightLine.backgroundColor = [UIColor whiteColor];
            break;
        default:
            break;
    }
}

- (void)addMeeting:(BOOL) myMeeting {
    if (!myMeeting) {
        self.statusLine.backgroundColor = [UIColor getUIColorFromHexString:@"#008FFB"];
    } else {
        self.statusLine.backgroundColor = [UIColor getUIColorFromHexString:@"#F8E71C"];
    }
    self.rightLine.backgroundColor = [UIColor getUIColorFromHexString:@"#6A6776"];
    self.leftLine.backgroundColor = [UIColor getUIColorFromHexString:@"#6A6776"];
}

- (void)showYellow {
    if ([UIColor color:self.statusLine.backgroundColor isEqualToColor:[UIColor getUIColorFromHexString:@"#F8E71C"] withTolerance:0]) {
        self.nowLine.hidden = NO;
    }
}

- (void)nowLineShow {
    self.nowRedLine.hidden = NO;
}

- (void)updateClocks {
    self.nowRedLine.hidden = NO;
    NSDate *actualTime = [NSDate date];
    NSTimeInterval delay = [[actualTime nextMinute] timeIntervalSinceDate:actualTime];
    NSDateFormatter *clocksFormat = [NSDateFormatter new];
    clocksFormat.dateFormat = @"mm";
    int timeInInt = [[clocksFormat stringFromDate:actualTime] intValue];
    for (int i = 0; i < 15; i++) {
        if ((timeInInt == i) || (timeInInt == i + 15) || (timeInInt == i + 30) || (timeInInt == i + 45)) {
            self.leftOutletForNowRedLine.constant = i * 0.75;
        }
        __weak id weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf performSelector:@selector(updateClocks) withObject:nil afterDelay:delay];
        });
    }
}

- (void) pastTime {
    self.rightLine.backgroundColor = [UIColor getUIColorFromHexString:@"#39364D"];
    self.leftLine.backgroundColor = [UIColor getUIColorFromHexString:@"#39364D"];
    if ([UIColor color:self.statusLine.backgroundColor isEqualToColor:[UIColor whiteColor] withTolerance:0]) {
        self.statusLine.hidden = YES;
    } else {
        self.statusLine.backgroundColor = [UIColor getUIColorFromHexString:@"#39364D"];
    }
}

@end
