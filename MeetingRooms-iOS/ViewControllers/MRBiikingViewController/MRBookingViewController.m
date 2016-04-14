//
//  MRBookingViewController.m
//  MeetingRooms-iOS
//
//  Created by Danil on 13.04.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

#import "MRBookingViewController.h"
#import "UIColor+MRColorFromHEX.h"
#import "MRNetworkManager.h"
#import "MROwner.h"
#import "MRRoom.h"

@interface MRBookingViewController ()

@property (weak, nonatomic) IBOutlet UIButton *timePickerButton;
@property (weak, nonatomic) IBOutlet UIButton *datePickerButton;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *timeCircles;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (strong, nonatomic) MRNetworkManager *manager;

@end

@implementation MRBookingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.timePickerButton.layer.borderWidth = 1.0;
    self.timePickerButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.datePickerButton.layer.borderWidth = 1.0;
    self.datePickerButton.layer.borderColor = [UIColor whiteColor].CGColor;
    
    for (UIView *circle in self.timeCircles) {
    circle.layer.borderWidth = 1.0;
    circle.layer.borderColor = [UIColor grayColor].CGColor;
    circle.backgroundColor = [UIColor getUIColorFromHexString:@"#302D44" alpha:1.0];
    circle.layer.cornerRadius = circle.frame.size.width / 2;
    }
    self.manager = [MRNetworkManager sharedManager];
    self.nameLabel.text = self.manager.owner.firstName;
    self.navigationItem.title = self.room.roomTitle;
}

@end
