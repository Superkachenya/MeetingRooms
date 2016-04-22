//
//  NSDate+MRNextMinute.m
//  MeetingRooms-iOS
//
//  Created by Danil on 12.04.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

#import "NSDate+MRNextMinute.h"

@implementation NSDate (MRNextMinute)

+ (NSString *)abstractTimeToTimeAfterNow:(NSUInteger)abstractTime inTimeLineSegment:(NSUInteger)CountOfTimeSegment {
    NSString *leftTimeIfStr = nil;
    NSNumber *hours = [NSNumber numberWithFloat:((abstractTime + (CountOfTimeSegment)) / 4) - 1];
    NSNumber *minute = [NSNumber numberWithLong:(((abstractTime % 4) - 2) * 15)];
    NSDate *curentDate = [NSDate new];
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"HH:mm"];
    NSString *curentTimeString = [formatter stringFromDate:curentDate];
    NSArray *components = [curentTimeString componentsSeparatedByString: @":"];
    NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *curentHours = [numberFormatter numberFromString:components[0]];
    NSNumber *curentMinute = [numberFormatter numberFromString:components[1]];
    NSInteger time = (hours.integerValue * 60) + minute.integerValue;
    NSInteger curentTime = (curentHours.integerValue * 60) + curentMinute.integerValue;
    if (curentTime > time) {
        leftTimeIfStr = @"Past";
    } else {
        if (curentTime + 15 >= time) {
            leftTimeIfStr = @"Now";
        } else {
            if ((time - curentTime) < 60) {
                leftTimeIfStr = [NSString stringWithFormat:@"In %ld minute", (long)(time - curentTime)];
            } else {
                leftTimeIfStr = [NSString stringWithFormat:@"In %ld hours and %ld minute", (long)(time - curentTime) / 60, (long)(time - curentTime) % 60];
            }
        }
    }
    return leftTimeIfStr;
}

+ (NSNumber *)timeToAbstractTime:(NSDate *)time endTime:(NSUInteger) endTime {
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"HH:mm"];
    NSString *timeString = [formatter stringFromDate:time];
    NSArray *components = [timeString componentsSeparatedByString: @":"];
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *hours = [numberFormatter numberFromString:components[0]];
    NSNumber *minute = [numberFormatter numberFromString:components[1]];
    NSNumber *abstractTime = [NSNumber new];
    if ((hours >= [NSNumber numberWithInteger:8]) && (hours <= [NSNumber numberWithInteger:20])) {
        abstractTime = [NSNumber numberWithInteger:(hours.integerValue - 8) * 4];
        if (minute >= [NSNumber numberWithInteger:45]) {
            abstractTime = [NSNumber numberWithFloat:abstractTime.integerValue + 3];
        } else {
            if (minute >= [NSNumber numberWithInteger:30]) {
                abstractTime = [NSNumber numberWithInteger:abstractTime.integerValue + 2];
            } else {
                if (minute >= [NSNumber numberWithInteger:15]) {
                    abstractTime = [NSNumber numberWithInteger:abstractTime.integerValue + 1];
                }
            }
        }
    }
    if (!abstractTime) {
        if (hours < [NSNumber numberWithInteger:8]) {
            abstractTime = [NSNumber numberWithInteger:0];
        } else {
            abstractTime = [NSNumber numberWithInteger:endTime];
        }
    }
    return abstractTime;
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
