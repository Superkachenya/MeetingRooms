//
//  MRMeeting.h
//  MeetingRooms-iOS
//
//  Created by Danil on 06.04.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

@import Foundation;
@class MRUser;
@class MRRoom;

@interface MRMeeting : NSObject

@property (strong, nonatomic) NSNumber *meetingId;
@property (strong, nonatomic) MRUser *meetingOwner;
@property (strong, nonatomic) MRRoom *meetingRoom;
@property (strong, nonatomic) NSString *meetingInfo;
@property (strong, nonatomic) NSDate *meetingStart;
@property (strong, nonatomic) NSDate *meetingFinish;

- (instancetype) initMeetingForRoomWithJSON:(id)JSON;
- (instancetype)initMeetingForUser:(MRUser *)user withJSON:(id)JSON;

@end
