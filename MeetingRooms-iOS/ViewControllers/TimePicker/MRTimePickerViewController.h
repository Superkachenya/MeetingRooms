//
//  MRTimePickerViewController.h
//  MeetingRooms-iOS
//
//  Created by Danil on 14.04.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

@import UIKit;

typedef void(^MRChangedTimeValue)(NSDate *time);

@interface MRTimePickerViewController : UIViewController

@property (copy, nonatomic) MRChangedTimeValue changedTime;

@end
