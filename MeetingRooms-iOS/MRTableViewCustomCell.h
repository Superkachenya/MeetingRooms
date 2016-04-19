//
//  MRTableViewCustomCell.h
//  MeetingRooms-iOS
//
//  Created by Alex on 08.04.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MRMeeting;

@interface MRTableViewCustomCell : UITableViewCell

- (void)configureCellAtIndexPath:(NSIndexPath *)indexpath withHour:(NSString *)hour;
- (void)configureCellWithMeeting:(MRMeeting *)meeting;

@end
