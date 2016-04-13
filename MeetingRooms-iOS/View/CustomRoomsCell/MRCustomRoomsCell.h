//
//  MRCustomRoomsCell.h
//  MeetingRooms-iOS
//
//  Created by Danil on 08.04.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

@import UIKit;
@class MRRoom;

@interface MRCustomRoomsCell : UITableViewCell

- (void)configureCellWithRoom:(MRRoom *)room;

@end
