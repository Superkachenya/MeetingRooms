//
//  MRMeeting.h
//  MeetingRooms-iOS
//
//  Created by Danil on 06.04.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

@import Foundation;
@class MRUser;

@interface MRMeeting : NSObject

@property (strong, nonatomic) MRUser *meetingOwner;
@property (strong, nonatomic) NSString *meetingInfo;
@property (strong, nonatomic) NSDate *meetingStart;
@property (strong, nonatomic) NSDate *meetingFinish;

- (instancetype) initMeetingWithJSON:(id)JSON;

@end
