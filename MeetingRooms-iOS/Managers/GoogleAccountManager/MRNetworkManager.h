//
//  MRGoogleAccountManager.h
//  MeetingRooms-iOS
//
//  Created by Danil on 06.04.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

@import Foundation;
@class MROwner;

typedef void(^MRCompletion)(id success, NSError *error);

@interface MRNetworkManager : NSObject

@property (strong, nonatomic) MROwner *owner;

+ (instancetype)sharedManager;

- (void)getAccessWithGoogleToken:(NSString *)token completionBlock:(MRCompletion)block;
- (void)getRoomsStatusWithCompletionBlock:(MRCompletion)block;
- (void)getRoomInfoById:(NSNumber *)roomId toDate:(NSDate *)date completion:(MRCompletion)block;
- (void)bookMeetingInRoom:(NSNumber *)roomId from:(NSNumber *)start to:(NSNumber *)finish withMessage:(NSString *)message completion:(MRCompletion)block;
- (void)getAllOwnersMeetingsForDate:(NSDate *)date offset:(NSUInteger)offset WithCompletionBlock:(MRCompletion)block;
- (void)getAllMeetingsForWeekSinceDate:(NSDate *)date completion:(MRCompletion)block;
- (void)deleteMeeting:(NSNumber *)meetingId completion:(MRCompletion)block;

@end
