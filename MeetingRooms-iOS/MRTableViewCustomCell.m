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
#import "MROwner.h"
#import "UIColor+MRColorFromHEX.h"
#import "UIImageView+AFNetworking.h"
#import "MRNetworkManager.h"

@interface MRTableViewCustomCell ()

@property (weak, nonatomic) IBOutlet UIImageView *creatorAvatarImage;
@property (weak, nonatomic) IBOutlet UILabel *titleMeetingLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeIntervalLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *intervalViewSpace;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *timePoints;

@end

@implementation MRTableViewCustomCell

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.timeIntervalLabel.textColor = [UIColor whiteColor];
    self.titleMeetingLabel.textColor = [UIColor whiteColor];
    for (UIView *point in self.timePoints) {
        point.backgroundColor = [UIColor getUIColorFromHexString:@"#008FFB"];
    }
}

- (void)configureCellWithMeeting:(MRMeeting *)meeting {
    if ([meeting.meetingOwner.email isEqualToString:[MRNetworkManager sharedManager].owner.email]) {
        self.timeIntervalLabel.textColor = [UIColor getUIColorFromHexString:@"#F8E71C"];
        self.titleMeetingLabel.textColor = [UIColor getUIColorFromHexString:@"#F8E71C"];
        for (UIView *point in self.timePoints) {
            point.backgroundColor = [UIColor getUIColorFromHexString:@"#F8E71C"];
        }
    }
    NSArray *components = [meeting.meetingOwner.email componentsSeparatedByString:@"@"];
    self.titleMeetingLabel.text = [components firstObject];
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
    NSComparisonResult result = [meeting.meetingFinish compare:[NSDate date]];
    if (result == NSOrderedAscending) {
        self.timeIntervalLabel.textColor = [UIColor getUIColorFromHexString:@"#4E4B62"];
        self.titleMeetingLabel.textColor = [UIColor getUIColorFromHexString:@"#4E4B62"];
        for (UIView *point in self.timePoints) {
            point.backgroundColor = [UIColor getUIColorFromHexString:@"#4E4B62"];
        }
    }
}

- (NSString *)getDateAsString:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    NSString *stringFromDate = [formatter stringFromDate:date];
    return stringFromDate;
}

@end
