//
//  NSDate+MRNextMinute.m
//  MeetingRooms-iOS
//
//  Created by Danil on 12.04.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

#import "NSDate+MRNextMinute.h"

@implementation NSDate (MRNextMinute)

+ (NSString *)abstractTimeToTimeAfterNow:(NSInteger)abstractTime inTimeLineSegment:(double)countOfTimeSegment {
    NSString *leftTimeIfStr = nil;
    NSNumber *hours = [NSNumber numberWithFloat:((abstractTime + (countOfTimeSegment)) / 4) - 1];
    NSNumber *minute = [NSNumber numberWithLong:(((abstractTime % 4) - 2) * 15)];
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"HH:mm"];
    NSString *curentTimeString = [formatter stringFromDate:currentDate];
    NSArray *components = [curentTimeString componentsSeparatedByString: @":"];
    if ([components[0] intValue] > hours.intValue) {
        leftTimeIfStr = @"Past";
    } else {
        if (([components[0] intValue] == hours.intValue) && ([components[1] intValue] > minute.intValue)) {
            leftTimeIfStr = @"Past";
        } else {
            if (([components[0] intValue] == hours.intValue) && ([components[1] intValue] > (minute.intValue+15))) {
                leftTimeIfStr = @"Now";
            } else {
                if (([components[0] intValue] == hours.intValue) && ([components[1] intValue] <= (minute.intValue+15))) {
                    NSInteger minutes = minute.intValue - [components[1] intValue];
                    leftTimeIfStr = [NSString stringWithFormat:@"In %ld minutes",(long)minutes];
                }
            }
        }
    }
    if ([components[0] intValue] < hours.intValue) {
        if ([components[1] intValue] > [minute intValue]) {
            NSInteger hour = hours.intValue - 1 - [components[0] intValue];
            if (hour == 0) {
                NSInteger minutes = minute.intValue + 60 - [components[1] intValue];
                leftTimeIfStr = [NSString stringWithFormat:@"In %ld minutes",(long)minutes];
            } else {
                leftTimeIfStr = [NSString stringWithFormat:@"In %ld hours and %d minutes",(long)hour, (minute.intValue + 60 - [components[1] intValue])];
            }
        } else if ([components[1] intValue] == minute.intValue) {
            leftTimeIfStr = [NSString stringWithFormat:@"In %d hours",(hours.intValue - [components[0] intValue])];
        } else {
            leftTimeIfStr = [NSString stringWithFormat:@"In %d hours and %d minutes",(hours.intValue - [components[0] intValue]),(minute.intValue - [components[1] intValue])];
        }
    }
    return leftTimeIfStr;
}

+ (NSNumber *)timeToAbstractTime:(NSDate *)time endTime:(NSInteger)endTime {
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"HH:mm"];
    NSString *timeString = [formatter stringFromDate:time];
    NSArray *components = [timeString componentsSeparatedByString: @":"];
    NSNumberFormatter *formater = [[NSNumberFormatter alloc] init];
    formater.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *hours = [formater numberFromString:components[0]];
    NSNumber *minute = [formater numberFromString:components[1]];
    NSNumber *abstractTime = [NSNumber new];
    if ((hours >= [NSNumber numberWithInt:8]) && (hours <= [NSNumber numberWithInt:20])) {
        abstractTime = [NSNumber numberWithFloat:(([hours floatValue] - 8) * 4)];
        if (minute >= [NSNumber numberWithInt:45]) {
            abstractTime = [NSNumber numberWithFloat:([abstractTime floatValue] + 3)];
        } else {
            if (minute >= [NSNumber numberWithInt:30]) {
                abstractTime = [NSNumber numberWithFloat:([abstractTime floatValue] + 2)];
            } else {
                if (minute >= [NSNumber numberWithInt:15]) {
                    abstractTime = [NSNumber numberWithFloat:([abstractTime floatValue] + 1)];
                }
            }
        }
    }
    if (!abstractTime) {
        if (hours < [NSNumber numberWithInt:8]) {
            abstractTime = [NSNumber numberWithFloat:(0)];
        } else {
            abstractTime = [NSNumber numberWithFloat:endTime];
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
