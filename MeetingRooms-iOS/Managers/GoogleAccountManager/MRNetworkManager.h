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

@end
