//
//  MRTableViewCustomCell.m
//  MeetingRooms-iOS
//
//  Created by Alex on 08.04.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

#import "MRTableViewCustomCell.h"
#import "MRMeeting.h"
#import "MRUser.h"
#import "UIColor+MRColorFromHEX.h"

@interface MRTableViewCustomCell ()

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *creatorAvatarImage;
@property (weak, nonatomic) IBOutlet UILabel *titleMeetingLabel;
@property (weak, nonatomic) IBOutlet UIView *indicatorView;
@property (weak, nonatomic) IBOutlet UILabel *timeIntervalLabel;

@end

@implementation MRTableViewCustomCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
}

- (void)configureCellAtIndexPath:(NSIndexPath *)indexpath withHour:(NSString *)hour {
    self.dateLabel.text = hour;
    NSLog(@"dateLabel - %@", self.dateLabel.text);
    self.creatorAvatarImage.hidden = YES;
    self.titleMeetingLabel.hidden = YES;
    self.indicatorView.hidden = YES;
    self.timeIntervalLabel.hidden = YES;
    
}

- (void)configureCellWithMeeting:(MRMeeting *)meeting {
    self.creatorAvatarImage.hidden = NO;
    self.titleMeetingLabel.hidden = NO;
    self.indicatorView.hidden = NO;
    self.timeIntervalLabel.hidden = NO;
    self.titleMeetingLabel.text = meeting.meetingInfo;
    self.indicatorView.backgroundColor = [UIColor getUIColorFromHexString:@"#F8E71C" alpha:1];
   // self.timeIntervalLabel.text = [NSString stringWithFormat:@"%@ - %@", meeting.meetingStart.description,
                                                                         //meeting.meetingFinish.description];
    self.timeIntervalLabel.text = [NSString stringWithFormat:@"11 - 12"];
    self.titleMeetingLabel.text = @"information";
}

@end
