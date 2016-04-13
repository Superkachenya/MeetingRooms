//
//  MROwner.h
//  MeetingRooms-iOS
//
//  Created by Danil on 12.04.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

#import "MRUser.h"

@interface MROwner : MRUser

@property (strong, nonatomic) NSString *accessToken;
@property (strong, nonatomic) NSString *refreshToken;
@property (strong, nonatomic, getter=isBlocked) NSNumber *blocked;
@property (strong, nonatomic, getter=isExpireAt) NSNumber *expireAt;
@property (strong, nonatomic) NSArray *userMeetings;

- (instancetype) initWithJSON:(id)JSON;

@end
