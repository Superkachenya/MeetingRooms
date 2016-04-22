//
//  MRCustomScheduleCe/Users/goncharenkocr/Documents/MeetingBlueTeam-iOS/MeetingRooms-iOSll.m
//  MeetingRooms-iOS
//
//  Created by Alex on 4/16/16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

#import "MRCustomScheduleCell.h"
#import "MRMeeting.h"
#import "MRRoom.h"
#import "UIColor+MRColorFromHEX.h"
#import "NSString+MRQuotesString.h"

@interface MRCustomScheduleCell ()

@property (weak, nonatomic) IBOutlet UILabel *roomIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *intervalLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@end

@implementation MRCustomScheduleCell

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.infoLabel setNeedsLayout];
    [self.infoLabel layoutIfNeeded];
}

- (void)configureCellWithMeeting:(MRMeeting *)meeting atIndexPath:(NSIndexPath *)indexPath {
    NSComparisonResult result = [meeting.meetingFinish compare:[NSDate date]];
    if (result == NSOrderedAscending) {
        self.roomIDLabel.textColor = [UIColor getUIColorFromHexString:@"#4E4B62"];
        self.intervalLabel.textColor = [UIColor getUIColorFromHexString:@"#4E4B62"];
        self.infoLabel.textColor = [UIColor getUIColorFromHexString:@"#4E4B62"];
    }
    self.roomIDLabel.text = [NSString stringWithFormat:@"%ld. %@", (long)indexPath.row + 1, meeting.meetingRoom.roomTitle];
    NSString *startDate = [self getDateAsString:meeting.meetingStart];
    NSString *finishDate = [self getDateAsString:meeting.meetingFinish];
    self.intervalLabel.text = [NSString stringWithFormat:@"%@-%@", startDate, finishDate];
    self.infoLabel.text = [NSString embedStringinQuotes:meeting.meetingInfo];
}

- (NSString *)getDateAsString:(NSDate *)date {
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"HH:mm"];
    NSString *stringFromDate = [formatter stringFromDate:date];
    return stringFromDate;
}

@end
