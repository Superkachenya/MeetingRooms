//
//  NSDate+MRNextMinute.m
//  MeetingRooms-iOS
//
//  Created by Danil on 12.04.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

#import "NSDate+MRNextMinute.h"

@implementation NSDate (MRNextMinute)

+ (NSUInteger)timeToAbstractTime:(NSDate *)time  visiblePath:(NSUInteger)visiblePath andHidenPath:(NSUInteger)hidenPath {
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"HH:mm"];
    NSString* timeString = [formatter stringFromDate:time];
    NSArray *components = [timeString componentsSeparatedByString: @":"];
    NSNumberFormatter *formater = [NSNumberFormatter new];
    formater.numberStyle = NSNumberFormatterDecimalStyle;
    NSUInteger hours = [formater numberFromString:components[0]].longValue;
    NSUInteger minute = [formater numberFromString:components[1]].longValue;
    NSUInteger abstractTime = 0;
    if ((hours >= 8 ) && (hours <= 20)) {
        abstractTime = ((hours  - 8) * 4);
        if (minute >= 45) {
            abstractTime = abstractTime  + 3;
        } else {
            if (minute >= 30) {
                abstractTime = abstractTime  + 2;
            } else {
                if (minute >= 15) {
                    abstractTime = abstractTime  + 1;
                }
            }
        }
    }
    if (abstractTime == 0) {
        if (hours > 20) {
            abstractTime = visiblePath;
        }
    }
    return abstractTime + hidenPath;
}
- (NSDate *)nextMinute {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *comps = [calendar components:(NSCalendarUnit) NSUIntegerMax fromDate:self];
    comps.minute += 1;
    comps.second = 0;
    
    return [calendar dateFromComponents:comps];
}

- (BOOL)isEqualToAnotherDay:(NSDate *)anotherDay {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *firstDay = [calendar components:NSCalendarUnitDay|NSCalendarUnitMonth fromDate:self];
    NSDateComponents *secondDay = [calendar components:NSCalendarUnitDay|NSCalendarUnitMonth fromDate:anotherDay];
    if (firstDay.day == secondDay.day && firstDay.month == secondDay.month) {
        return YES;
    }
    return NO;
}

@end
