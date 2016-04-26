//
//  MRRoom.m
//  MeetingRooms-iOS
//
//  Created by Danil on 06.04.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

#import "MRRoom.h"

@implementation MRRoom

static double const kMiliSecInSecond = 1000.0;

- (instancetype)initRoomUsingJSON:(id)JSON {
    if (self = [super init]) {
        self.roomId = [JSON valueForKey:@"roomId"];
        self.roomTitle = [JSON valueForKey:@"roomTitle"];
        self.roomDescription = [JSON valueForKey:@"roomDescription"];
        NSNumber *response = [JSON valueForKey:@"nearestTime"];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:(response.doubleValue / kMiliSecInSecond)];
        self.nearestTime = date;
        self.empty = [JSON valueForKey:@"isEmpty"];
    }
    return self;
}

@end