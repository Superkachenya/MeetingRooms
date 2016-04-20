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
@property (weak, nonatomic) IBOutlet UIView *indicatorView;
@property (weak, nonatomic) IBOutlet UILabel *timeIntervalLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *intervalViewSpace;
@property (weak, nonatomic) IBOutlet UIView *frameOfPicture;
@property (weak, nonatomic) IBOutlet UIView *p1;
@property (weak, nonatomic) IBOutlet UIView *p2;
@property (weak, nonatomic) IBOutlet UIView *p3;
@property (weak, nonatomic) IBOutlet UIView *p4;

@end

@implementation MRTableViewCustomCell

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.timeIntervalLabel.textColor = [UIColor whiteColor];
    self.titleMeetingLabel.textColor = [UIColor whiteColor];
    self.indicatorView.backgroundColor = [UIColor getUIColorFromHexString:@"#008FFB"];
    self.frameOfPicture.backgroundColor = [UIColor getUIColorFromHexString:@"#008FFB"];
    self.p1.backgroundColor = [UIColor getUIColorFromHexString:@"#008FFB"];
    self.p2.backgroundColor = [UIColor getUIColorFromHexString:@"#008FFB"];
    self.p3.backgroundColor = [UIColor getUIColorFromHexString:@"#008FFB"];
    self.p4.backgroundColor = [UIColor getUIColorFromHexString:@"#008FFB"];
    
}

- (void)configureCellWithMeeting:(MRMeeting *)meeting {
    if ([meeting.meetingOwner.email isEqualToString:[MRNetworkManager sharedManager].owner.email]) {
        self.timeIntervalLabel.textColor = [UIColor getUIColorFromHexString:@"#F8E71C"];
        self.indicatorView.backgroundColor = [UIColor getUIColorFromHexString:@"#F8E71C"];
        self.titleMeetingLabel.textColor = [UIColor getUIColorFromHexString:@"#F8E71C"];
        self.frameOfPicture.backgroundColor = [UIColor getUIColorFromHexString:@"#F8E71C"];
        self.p1.backgroundColor = [UIColor getUIColorFromHexString:@"#F8E71C"];
        self.p2.backgroundColor = [UIColor getUIColorFromHexString:@"#F8E71C"];
        self.p3.backgroundColor = [UIColor getUIColorFromHexString:@"#F8E71C"];
        self.p4.backgroundColor = [UIColor getUIColorFromHexString:@"#F8E71C"];
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
    NSString *curentTimeString = [self getDateAsString:[NSDate new]];
    NSArray *componentsTime = [curentTimeString componentsSeparatedByString: @":"];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *curentHours = [formatter numberFromString:componentsTime[0]];
    NSNumber *curentMinute = [formatter numberFromString:componentsTime[1]];
    int currentTime = ([curentHours intValue] * 60) + [curentMinute intValue];
    componentsTime = [startDate componentsSeparatedByString: @":"];
    NSNumber *hours = [formatter numberFromString:componentsTime[0]];
    NSNumber *minute = [formatter numberFromString:componentsTime[1]];
    int time = ([hours intValue] * 60) + [minute intValue];
    if (time < currentTime) {
        self.timeIntervalLabel.textColor = [UIColor getUIColorFromHexString:@"#39364D"];
        self.indicatorView.backgroundColor = [UIColor getUIColorFromHexString:@"#39364D"];
        self.titleMeetingLabel.textColor = [UIColor getUIColorFromHexString:@"#39364D"];
        self.frameOfPicture.backgroundColor = [UIColor getUIColorFromHexString:@"#39364D"];
        self.p1.backgroundColor = [UIColor getUIColorFromHexString:@"#39364D"];
        self.p2.backgroundColor = [UIColor getUIColorFromHexString:@"#39364D"];
        self.p3.backgroundColor = [UIColor getUIColorFromHexString:@"#39364D"];
        self.p4.backgroundColor = [UIColor getUIColorFromHexString:@"#39364D"];
    }
}

- (NSString *)getDateAsString:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    NSString *stringFromDate = [formatter stringFromDate:date];
    return stringFromDate;
}

@end
