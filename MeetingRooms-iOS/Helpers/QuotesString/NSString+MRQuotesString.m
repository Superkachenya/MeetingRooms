//
//  NSString+MRQuotesString.m
//  MeetingRooms-iOS
//
//  Created by Danil on 4/19/16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

#import "NSString+MRQuotesString.h"

@implementation NSString (MRQuotesString)

+ (NSString *)embedStringinQuotes:(NSString *)string {
    NSString *result = [NSString stringWithFormat:@"\"%@\"",string];
    return result;
}

@end
