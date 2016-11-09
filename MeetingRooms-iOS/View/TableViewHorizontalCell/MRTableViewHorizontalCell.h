//
//  MRTableViewHorizontalCell.h
//  MeetingRooms-iOS
//
//  Created by Sergey on 06.04.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

@import UIKit;
@interface MRTableViewHorizontalCell : UITableViewCell

- (void)showTimeLineWithCountOfLine:(NSUInteger)countOfTimeLine sizeOfViewIs:(NSUInteger)sizeOfHalfScreen atIndexCell:(NSUInteger)index;

- (void)showYellow;
- (void)pastTime;
- (void)addMeeting:(BOOL)myMeeting;
- (void)nowLineShow;
- (void)updateClocks;

@end
