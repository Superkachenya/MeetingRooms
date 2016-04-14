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
#import "WYPopoverController.h"
#import "MRTimePickerViewController.h"
#import "MRDatePickerViewController.h"

@interface MRBookingViewController () <WYPopoverControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *timePickerButton;
@property (weak, nonatomic) IBOutlet UIButton *datePickerButton;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *timeCircles;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *checkInTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *checkOutTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeButtonLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateButtonLabel;

@property (strong, nonatomic) MRNetworkManager *manager;
@property (strong, nonatomic) NSDateFormatter *timeFormatter;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) WYPopoverController *popover;


@end

@implementation MRBookingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = self.room.roomTitle;
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
    
    self.timeFormatter = [NSDateFormatter new];
    self.dateFormatter = [NSDateFormatter new];
    self.timeFormatter.dateFormat = @"HH:mm";
    self.dateFormatter.dateFormat = @"dd/MM/yy";
    self.timeButtonLabel.text = [self.timeFormatter stringFromDate:[NSDate date]];
    self.dateButtonLabel.text = [self.dateFormatter stringFromDate:[NSDate date]];

}

#pragma mark - WYPopoverControllerDelegate

- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller {
    return YES;
}

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)controller {
    self.popover.delegate = nil;
    self.popover = nil;
}

- (IBAction)timeButtonDidTap:(UIButton *)sender {
    MRTimePickerViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"IDTimePickerVC"];
    controller.modalInPopover = NO;
    controller.preferredContentSize = CGSizeMake(sender.bounds.size.width, self.view.bounds.size.height /3);
    controller.changedTime = ^(NSDate *date){
        self.timeButtonLabel.text = [self.timeFormatter stringFromDate:date];
        self.checkInTimeLabel.text = [self.timeFormatter stringFromDate:date];
    };
    self.popover = [[WYPopoverController alloc] initWithContentViewController:controller];
    self.popover.delegate = self;
    self.popover.wantsDefaultContentAppearance = NO;
    [self.popover presentPopoverFromRect:sender.bounds inView:sender permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];
}

- (IBAction)dateButtonDidTap:(UIButton *)sender {
    MRDatePickerViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"IDDatePickerVC"];
    controller.modalInPopover = NO;
    controller.preferredContentSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height /3);
    controller.changedDate = ^(NSDate *date){
        self.dateButtonLabel.text = [self.dateFormatter stringFromDate:date];
    };
    self.popover = [[WYPopoverController alloc] initWithContentViewController:controller];
    self.popover.delegate = self;
    self.popover.wantsDefaultContentAppearance = NO;
    [self.popover presentPopoverFromRect:sender.bounds inView:sender permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];
}

@end
