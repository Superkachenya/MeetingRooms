//
//  NSDate+MRNextMinute.m
//  MeetingRooms-iOS
//
//  Created by Danil on 12.04.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

#import "NSDate+MRNextMinute.h"

@implementation NSDate (MRNextMinute)

- (NSDate *)nextMinute {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *comps = [calendar components:(NSCalendarUnit) NSUIntegerMax fromDate:self];
    comps.minute += 1;
    comps.second = 0;
    
    return [calendar dateFromComponents:comps];
}

@end
