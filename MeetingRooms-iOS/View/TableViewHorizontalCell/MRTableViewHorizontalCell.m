///Users/chuchukalo_cr/Documents/Meetingrooms-iOS/MeetingRooms-iOS
//  MRTableViewHorizontalCell.m
//  MeetingRooms-iOS
//
//  Created by Sergey on 06.04.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

#import "MRTableViewHorizontalCell.h"
#import "UIColor+MRColorFromHEX.h"

@interface MRTableViewHorizontalCell()

@property (weak, nonatomic) IBOutlet UIView *rightLine;
@property (weak, nonatomic) IBOutlet UIView *leftLine;
@property (weak, nonatomic) IBOutlet UIView *littleLeftLine;
@property (weak, nonatomic) IBOutlet UIView *littleRightLine;
@property (weak, nonatomic) IBOutlet UIView *statusLine;
@property (weak, nonatomic) IBOutlet UIView *nowLine;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

@implementation MRTableViewHorizontalCell

- (void)prepareForReuse {
    [super prepareForReuse];
    self.statusLine.backgroundColor = [UIColor getUIColorFromHexString:@"#FFFFFF" alpha:1];
    self.rightLine.backgroundColor = [UIColor getUIColorFromHexString:@"#FFFFFF" alpha:1];
    self.leftLine.backgroundColor = [UIColor getUIColorFromHexString:@"#FFFFFF" alpha:1];
    self.statusLine.hidden = NO;
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
