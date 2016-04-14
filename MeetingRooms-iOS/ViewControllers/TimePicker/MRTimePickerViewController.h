//
//  MRTimePickerViewController.h
//  MeetingRooms-iOS
//
//  Created by Danil on 14.04.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

@import UIKit;

typedef void(^MRChangedDateValue)(NSDate *time);

@interface MRTimePickerViewController : UIViewController

@property (copy, nonatomic) MRChangedDateValue changedTime;

@end
