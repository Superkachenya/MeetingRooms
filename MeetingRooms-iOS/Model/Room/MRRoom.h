//
//  MRRoom.h
//  MeetingRooms-iOS
//
//  Created by Danil on 06.04.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

@import Foundation;

@interface MRRoom : NSObject

@property (strong, nonatomic) NSNumber *roomId;
@property (strong, nonatomic) NSString *roomTitle;
@property (strong, nonatomic) NSString *roomDescription;
@property (strong, nonatomic) NSDate *nearestTime;
@property (strong, nonatomic, getter = isEmpty) NSNumber *empty;
@property (strong, nonatomic) NSArray *meetings;

- (instancetype)initRoomUsingJSON:(id)json;

@end
