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
#import "FSCalendar.h"

typedef NS_ENUM(NSUInteger, MRRedCircle) {
    MRFifteenMinutesRedCircle,
    MRThirtyMinutesRedCircle,
    MRFourtyFiveMinutesRedCircle,
    MRSixtyMinutesRedCircle
};

static NSTimeInterval const kFifteenMinutes    = 900.0f;
static NSTimeInterval const kThirtyMinutes     = 1800.0f;
static NSTimeInterval const kFourtyFiveMinutes = 2700.0f;
static NSTimeInterval const kSixtyMinutes      = 3600.0f;

@interface MRBookingViewController () <WYPopoverControllerDelegate, FSCalendarDelegate, FSCalendarDataSource>

@property (weak, nonatomic) IBOutlet UIButton *timePickerButton;
@property (weak, nonatomic) IBOutlet UIButton *datePickerButton;
@property (weak, nonatomic) IBOutlet UILabel *timeButtonLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateButtonLabel;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *timeCircles;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *redCircles;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *checkInTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *checkOutTimeLabel;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (assign, nonatomic) CGFloat constraintsConstant;
@property (strong, nonatomic) MRNetworkManager *manager;
@property (strong, nonatomic) WYPopoverController *popover;
@property (strong, nonatomic) NSDateFormatter *timeFormatter;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSDate *calendarDate;
@property (strong, nonatomic) NSDate *timePickerTime;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *finishDate;


@end

@implementation MRBookingViewController

#pragma mark - UIViewLifeCycle

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
    self.constraintsConstant = self.bottomConstraint.constant;
    
    self.timeFormatter = [NSDateFormatter new];
    self.dateFormatter = [NSDateFormatter new];
    self.timeFormatter.dateFormat = @"HH:mm";
    self.dateFormatter.dateFormat = @"dd/MM/yy";
    self.timeButtonLabel.text = [self.timeFormatter stringFromDate:[NSDate date]];
    self.dateButtonLabel.text = [self.dateFormatter stringFromDate:[NSDate date]];
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

#pragma mark - WYPopoverControllerDelegate

- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller {
    return YES;
}

- (void)popoverControllerDidDismissPopover:(WYPopoverController *)controller {
    self.popover.delegate = nil;
    self.popover = nil;
}

#pragma mark - FSCalendarDelegate

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date {
    self.calendarDate = date;
    self.startDate = [self createDateFromTime:self.timePickerTime andDate:self.calendarDate];
    self.dateButtonLabel.text = [self.dateFormatter stringFromDate:date];
    self.finishDate = [NSDate dateWithTimeInterval:kFifteenMinutes sinceDate:self.startDate];
    self.checkOutTimeLabel.text = [self.timeFormatter stringFromDate:self.finishDate];
    [self.popover dismissPopoverAnimated:YES];
}

#pragma mark - FSCalendarDataSource

- (NSDate *)minimumDateForCalendar:(FSCalendar *)calendar {
    return [NSDate date];
}

#pragma mark - Handle Events

- (IBAction)timeButtonDidTap:(UIButton *)sender {
    MRTimePickerViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"IDTimePickerVC"];
    controller.modalInPopover = NO;
    controller.preferredContentSize = CGSizeMake(sender.bounds.size.width, self.view.bounds.size.height /3);
    controller.changedTime = ^(NSDate *date){
        [self showInRedCircle:MRFifteenMinutesRedCircle];
        self.timePickerTime = date;
        self.startDate = [self createDateFromTime:self.timePickerTime andDate:self.calendarDate];
        self.finishDate = [NSDate dateWithTimeInterval:kFifteenMinutes sinceDate:self.startDate];
        self.timeButtonLabel.text = [self.timeFormatter stringFromDate:date];
        self.checkInTimeLabel.text = [self.timeFormatter stringFromDate:self.startDate];
        self.checkOutTimeLabel.text = [self.timeFormatter stringFromDate:self.finishDate];
    };
    self.popover = [[WYPopoverController alloc] initWithContentViewController:controller];
    self.popover.delegate = self;
    self.popover.wantsDefaultContentAppearance = NO;
    [self.popover presentPopoverFromRect:sender.bounds inView:sender permittedArrowDirections:WYPopoverArrowDirectionUp animated:YES];
}

- (IBAction)dateButtonDidTap:(UIButton *)sender {
    [self showInRedCircle:MRFifteenMinutesRedCircle];
    UIViewController *controller = [[UIViewController alloc] init];
    controller.modalInPopover = NO;
    controller.preferredContentSize = CGSizeMake(280.0, self.view.frame.size.height/2);
    FSCalendar *calendarView = [[FSCalendar alloc] initWithFrame:CGRectMake(0, 0, 280.0, self.view.bounds.size.height /2)];
    calendarView.delegate = self;
    calendarView.dataSource = self;
    controller.view = calendarView;
    self.popover = [[WYPopoverController alloc] initWithContentViewController:controller];
    self.popover.delegate = self;
    self.popover.wantsDefaultContentAppearance = NO;
    [self.popover presentPopoverFromRect:sender.bounds inView:sender permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];
}

- (IBAction)addFifteenMinutes:(id)sender {
    [self showInRedCircle:MRFifteenMinutesRedCircle];
    self.finishDate = [NSDate dateWithTimeInterval:kFifteenMinutes sinceDate:self.startDate];
    self.checkOutTimeLabel.text = [self.timeFormatter stringFromDate:self.finishDate];
}

- (IBAction)addThirtyMinutes:(id)sender {
    [self showInRedCircle:MRThirtyMinutesRedCircle];
    self.finishDate = [NSDate dateWithTimeInterval:kThirtyMinutes sinceDate:self.startDate];
    self.checkOutTimeLabel.text = [self.timeFormatter stringFromDate:self.finishDate];
}

- (IBAction)addFourtyFiveMinutes:(id)sender {
    [self showInRedCircle:MRFourtyFiveMinutesRedCircle];
    self.finishDate = [NSDate dateWithTimeInterval:kFourtyFiveMinutes sinceDate:self.startDate];
    self.checkOutTimeLabel.text = [self.timeFormatter stringFromDate:self.finishDate];
}

- (IBAction)addSixtyMinutes:(id)sender {
    [self showInRedCircle:MRSixtyMinutesRedCircle];
    self.finishDate = [NSDate dateWithTimeInterval:kSixtyMinutes sinceDate:self.startDate];
    self.checkOutTimeLabel.text = [self.timeFormatter stringFromDate:self.finishDate];
}
- (IBAction)bookButtonDidPress:(id)sender {
    NSLog(@"%@\n%@", self.startDate, self.finishDate);
    [self dismissKeyboard:self];
}
- (IBAction)cancelButtonDidPress:(id)sender {
}

#pragma mark - Helpers

- (void)showInRedCircle:(MRRedCircle)circle {
    for (UIImageView *redCircle in self.redCircles) {
        if ([redCircle isEqual:self.redCircles[circle]]) {
            redCircle.hidden = NO;
        } else {
            redCircle.hidden = YES;
        }
    }
}

- (NSDate *)createDateFromTime:(NSDate *)time andDate:(NSDate *)date {
    if (!date) {
        date = [NSDate date];
    }
    if (!time) {
        time = [NSDate date];
    }
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *resultComponents = [NSDateComponents new];
    NSDateComponents *timeComponents = [NSDateComponents new];
    NSDateComponents *dateComponents = [NSDateComponents new];
    timeComponents = [calendar components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:time];
    dateComponents = [calendar components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear fromDate:date];
    resultComponents.hour = timeComponents.hour;
    resultComponents.minute = timeComponents.minute;
    resultComponents.day = dateComponents.day;
    resultComponents.month = dateComponents.month;
    resultComponents.year = dateComponents.year;
    NSDate *result = [calendar dateFromComponents:resultComponents];
    return result;
}

#pragma mark - HandleKeyboardAppearance

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)keyboardWasShown:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:0.3 animations:^{
        self.bottomConstraint.constant = kbSize.height + self.constraintsConstant;
        CGPoint bottomOffset = CGPointMake(0, kbSize.height / 2);
        [self.scrollView setContentOffset:bottomOffset animated:YES];
    }];
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {
    self.bottomConstraint.constant = self.constraintsConstant;
}

-(IBAction)dismissKeyboard:(id)sender {
    [self.textView resignFirstResponder];
}

@end
