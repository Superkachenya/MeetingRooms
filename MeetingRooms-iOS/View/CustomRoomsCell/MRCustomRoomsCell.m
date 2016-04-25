//
//  MRCustomRoomsCell.m
//  MeetingRooms-iOS
//
//  Created by Danil on 08.04.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

#import "MRCustomRoomsCell.h"
#import "MRRoom.h"
#import "UIColor+MRColorFromHEX.h"

NSString *const kBooked = @"Booked";
NSString *const kFree = @"FreeNow";

@interface MRCustomRoomsCell ()

@property (weak, nonatomic) IBOutlet UILabel *roomTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *roomDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *roomStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *nearestTimeLabel;

@end

@implementation MRCustomRoomsCell

- (void)configureCellWithRoom:(MRRoom *)room {
    self.roomTitleLabel.text = room.roomTitle;
    self.roomDescriptionLabel.text = room.roomDescription;
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"HH:mm";
    NSComparisonResult result = [room.nearestTime compare:[NSDate date]];
    if (result == NSOrderedAscending) {
        self.nearestTimeLabel.text = @"Free Today";
    } else {
    self.nearestTimeLabel.text = [@"till " stringByAppendingString:[formatter stringFromDate:room.nearestTime]];
    }
    if (room.isEmpty.boolValue) {
        self.roomStatusLabel.textColor = [UIColor getUIColorFromHexString:@"#008ffb"];
        self.roomStatusLabel.text = kFree;
    } else {
        self.roomStatusLabel.textColor = [UIColor getUIColorFromHexString:@"#302d44"];
        self.roomStatusLabel.text = kBooked;
    }
}

@end
