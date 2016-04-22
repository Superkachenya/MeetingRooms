//
//  NSDate+MRNextMinute.h
//  MeetingRooms-iOS
//
//  Created by Danil on 12.04.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

@import Foundation;
@interface NSDate (MRNextMinute)

+ (NSUInteger)timeToAbstractTime:(NSDate *)time  visiblePath:(NSUInteger)visiblePath andHidenPath:(NSUInteger)hidenPath;

- (NSDate *)nextMinute;
- (BOOL)isEqualToAnotherDay:(NSDate *)anotherDay;

@end
