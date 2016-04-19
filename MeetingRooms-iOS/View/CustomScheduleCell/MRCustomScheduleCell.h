//
//  MRCustomScheduleCell.h
//  MeetingRooms-iOS
//
//  Created by Alex on 4/16/16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRMeeting;

@interface MRCustomScheduleCell : UITableViewCell

- (void)configureCellWithMeeting:(MRMeeting *) meeting indexpath:(NSIndexPath *)indexPath;

@end
