//
//  MRCustomScheduleCe/Users/goncharenkocr/Documents/MeetingBlueTeam-iOS/MeetingRooms-iOSll.m
//  MeetingRooms-iOS
//
//  Created by Alex on 4/16/16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

#import "MRCustomScheduleCell.h"
#import "MRMeeting.h"

@interface MRCustomScheduleCell ()

@property (weak, nonatomic) IBOutlet UILabel *roomIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *intervalLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;


@end

@implementation MRCustomScheduleCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.infoLabel setNeedsLayout];
    [self.infoLabel layoutIfNeeded];
}

- (void)configureCellWithMeeting:(MRMeeting *) meeting indexpath:(NSIndexPath *)indexPath {
    self.roomIDLabel.text = [meeting.meetingId stringValue];
    NSString *startDate = [self getDateAsString:meeting.meetingStart];
    NSString *finishDate = [self getDateAsString:meeting.meetingFinish];
    self.intervalLabel.text = [NSString stringWithFormat:@"%@ - %@", startDate, finishDate];
    self.infoLabel.text = meeting.meetingInfo;
}

- (NSString *)getDateAsString:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"Europe/Kiev"]];
    NSString *stringFromDate = [formatter stringFromDate:date];
    return stringFromDate;
}

@end
