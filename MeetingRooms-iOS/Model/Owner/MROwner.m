//
//  MROwner.m
//  MeetingRooms-iOS
//
//  Created by Danil on 12.04.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

#import "MROwner.h"

@implementation MROwner

- (instancetype) initWithJSON:(id)JSON {
    if (self = [super init]) {
        self.userId = [JSON valueForKey:@"id"];
        self.email = [JSON valueForKey:@"email"];
        self.avatar = [NSURL URLWithString:[JSON valueForKey:@"avatar"]];
        self.firstName = [JSON valueForKey:@"firstName"];
        self.lastName = [JSON valueForKey:@"lastName"];
        self.blocked = [JSON valueForKey:@"isBlocked"];
        self.accessToken = [JSON valueForKeyPath:@"session.accessToken"];
        self.refreshToken = [JSON valueForKeyPath:@"session.refreshToken"];
        self.expireAt = [JSON valueForKeyPath:@"session.expireAt"];
    }
    return self;
}

@end
