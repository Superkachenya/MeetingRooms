//
//  MRMeetingDetails.m
//  MeetingRooms-iOS
//
//  Created by Danil on 4/21/16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

#import "MRMeetingDetails.h"
#import "MRMeeting.h"
#import "MRRoom.h"
#import "NSString+MRQuotesString.h"
#import "UIViewController+MRErrorAlert.h"


@interface MRMeetingDetails ()
@property (weak, nonatomic) IBOutlet UILabel *roomLabel;
@property (weak, nonatomic) IBOutlet UILabel *startLabel;
@property (weak, nonatomic) IBOutlet UILabel *finishLabel;
@property (weak, nonatomic) IBOutlet UITextView *messageView;

@end

@implementation MRMeetingDetails

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSDateFormatter *clocksFormat = [NSDateFormatter new];
    clocksFormat.dateFormat = @"HH:mm";
    self.roomLabel.text = self.meeting.meetingRoom.roomTitle;
    self.startLabel.text = [clocksFormat stringFromDate:self.meeting.meetingStart];
    self.finishLabel.text = [clocksFormat stringFromDate:self.meeting.meetingFinish];
    self.messageView.text = [NSString embedStringinQuotes:self.meeting.meetingInfo];
}

- (IBAction)cancelButton:(id)sender {
    [self createAlertToConfirmDeleting];
}

@end
