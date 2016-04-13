//
//  MRMeeting.m
//  MeetingRooms-iOS
//
//  Created by Danil on 06.04.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

#import "MRMeeting.h"
#import "MRUser.h"

@implementation MRMeeting

static double const kMiliSecInSecond = 1000.0;

- (instancetype) initMeetingWithJSON:(id)JSON {
    if (self = [super init]) {
        self.meetingOwner = [MRUser new];
        self.meetingOwner.userId = [JSON valueForKey:@"userId"];
        self.meetingOwner.email = [JSON valueForKey:@"userName"];
        self.meetingOwner.avatar = [NSURL URLWithString:[JSON valueForKey:@"avatar"]];
        self.meetingId = [JSON valueForKey:@"bookingId"];
        self.meetingInfo = [JSON valueForKey:@"message"];
        NSNumber *start = [JSON valueForKey:@"timeStart"];
        NSNumber *finish = [JSON valueForKey:@"timeEnd"];
        NSDate *startDate = [NSDate dateWithTimeIntervalSince1970:(start.doubleValue / kMiliSecInSecond)];
        NSDate *finishDate = [NSDate dateWithTimeIntervalSince1970:(finish.doubleValue / kMiliSecInSecond)];
        self.meetingStart = startDate;
        self.meetingFinish = finishDate;
    }
    return self;
}

@end
