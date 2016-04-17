//
//  MRTableViewCustomCell.m
//  MeetingRooms-iOS
//
//  Created by Alex on 08.04.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

#import "MRTableViewCustomCell.h"
#import "MRMeeting.h"
#import "MRUser.h"
#import "UIColor+MRColorFromHEX.h"
#import "UIImageView+AFNetworking.h"

@interface MRTableViewCustomCell ()

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *creatorAvatarImage;
@property (weak, nonatomic) IBOutlet UILabel *titleMeetingLabel;
@property (weak, nonatomic) IBOutlet UIView *indicatorView;
@property (weak, nonatomic) IBOutlet UILabel *timeIntervalLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *intervalViewSpace;

@end

@implementation MRTableViewCustomCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
}

- (void)configureCellAtIndexPath:(NSIndexPath *)indexpath withHour:(NSString *)hour {
    self.dateLabel.text = hour;
    NSLog(@"dateLabel - %@", self.dateLabel.text);
    
}

- (void)configureCellWithMeeting:(MRMeeting *)meeting {
    NSArray *components = [meeting.meetingOwner.email componentsSeparatedByString: @"@"];
    self.titleMeetingLabel.text = components[0];
    NSString *startDate = [self getDateAsString:meeting.meetingStart];
    NSString *finishDate = [self getDateAsString:meeting.meetingFinish];
    self.timeIntervalLabel.text = [NSString stringWithFormat:@"%@ - %@", startDate, finishDate];
    [self.creatorAvatarImage setImageWithURL:meeting.meetingOwner.avatar];
    CALayer * layer = [self.creatorAvatarImage layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:self.creatorAvatarImage.frame.size.width / 2];
    NSTimeInterval distanceBetweenDates = [meeting.meetingFinish timeIntervalSinceDate:meeting.meetingStart];
    double secondsInAnHour = 60;
    NSInteger minutesBetweenDates = distanceBetweenDates / secondsInAnHour;
    switch (minutesBetweenDates) {
        case 15:
            self.intervalViewSpace.constant = 8;
            break;
        case 30:
            self.intervalViewSpace.constant = 18;
            break;
        case 45:
            self.intervalViewSpace.constant = 28;
            break;
        default:
            break;
    }
}

- (NSString *)getDateAsString:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"Europe/Kiev"]];
    NSString *stringFromDate = [formatter stringFromDate:date];
    return stringFromDate;
}

@end
