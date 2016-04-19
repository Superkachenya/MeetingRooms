//
//  NSDate+MRNextMinute.h
//  MeetingRooms-iOS
//
//  Created by Danil on 12.04.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

@import Foundation;
@interface NSDate (MRNextMinute)

- (NSDate *)nextMinute;

+ (NSNumber*) timeToAbstractTime:(NSDate *)time endTime:(long) endTime;
+ (NSString*) abstractTimeToTimeAfterNow:(long)abstractTime inTimeLineSegment:(double)CountOfTimeSigmente;

@end