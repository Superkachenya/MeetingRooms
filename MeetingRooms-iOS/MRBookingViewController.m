//
//  MRBookingViewController.m
//  MeetingRooms-iOS
//
//  Created by Danil on 13.04.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

#import "MRBookingViewController.h"
#import "PTEHorizontalTableView.h"
#import "MRTableViewHorizontalCell.h"
#import "UIColor+MRColorFromHEX.h"
#import "MRNetworkManager.h"
#import "MROwner.h"
#import "MRRoom.h"
#import "WYPopoverController.h"
#import "MRTimePickerViewController.h"
#import "FSCalendar.h"
#import "UIViewController+MRErrorAlert.h"
#import "NSDate+MRNextMinute.h"
#import "MRMeeting.h"

typedef NS_ENUM(NSUInteger, MRRedCircle) {
    MRFifteenMinutesRedCircle,
    MRThirtyMinutesRedCircle,
    MRFourtyFiveMinutesRedCircle,
    MRSixtyMinutesRedCircle
};

static NSTimeInterval const kFifteenMinutes    = 900.0;
static NSTimeInterval const kThirtyMinutes     = 1800.0;
static NSTimeInterval const kFourtyFiveMinutes = 2700.0;
static NSTimeInterval const kSixtyMinutes      = 3600.0;
static double const kmilisecInSecond = 1000.0;
static const double kCountOfTimeSigmente = 48;
static const double kWidthOfCell = 20;

@interface MRBookingViewController () <PTETableViewDelegate, WYPopoverControllerDelegate, FSCalendarDelegate, FSCalendarDataSource, UITextViewDelegate>

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
@property (weak, nonatomic) IBOutlet UILabel *messagePlaceholder;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet PTEHorizontalTableView *horizontalTableView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightOfTableView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (strong, nonatomic) NSString *quotationText;
@property (assign, nonatomic) CGFloat constraintsConstant;
@property (strong, nonatomic) MRNetworkManager *manager;
@property (strong, nonatomic) WYPopoverController *popover;
@property (strong, nonatomic) NSDateFormatter *timeFormatter;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSDate *calendarDate;
@property (strong, nonatomic) NSDate *timePickerTime;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *finishDate;
@property (strong, nonatomic) NSMutableDictionary* dictonaryOfMeeting;
@property (assign, nonatomic) long countOfCellOnView;
@property (strong, nonatomic) NSIndexPath* indexPathOfCentralCell;
@property (strong, nonatomic) NSIndexPath* indexPathOfLastShowCell;
@property (strong, nonatomic) MRMeeting* meetting;

@end

@implementation MRBookingViewController

#pragma mark - UIViewLifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.room.meetings = [NSMutableArray new];
    self.dictonaryOfMeeting = [NSMutableDictionary new];
    self.countOfCellOnView = ([self.horizontalTableView bounds].size.width / kWidthOfCell);
    self.heightOfTableView.constant = self.horizontalTableView.frame.size.width;
    self.tableView.frame = self.horizontalTableView.frame;
    self.tableView.contentSize = self.horizontalTableView.contentSize;

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
    self.textView.delegate = self;
    
    self.timeFormatter = [NSDateFormatter new];
    self.dateFormatter = [NSDateFormatter new];
    self.timeFormatter.dateFormat = @"HH:mm";
    self.dateFormatter.dateFormat = @"dd/MM/yy";
    self.timeButtonLabel.text = [self.timeFormatter stringFromDate:[NSDate date]];
    self.dateButtonLabel.text = [self.dateFormatter stringFromDate:[NSDate date]];
    [self selectTimeOnTimeLine];
    [self downloadAndUpdateDate];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
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
    [super viewDidDisappear:animated];
    
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

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(PTEHorizontalTableView *)horizontalTableView numberOfRowsInSection:(NSInteger)section {
    return kCountOfTimeSigmente + self.countOfCellOnView ;
}

- (CGFloat)tableView:(PTEHorizontalTableView *)horizontalTableView widthForCellAtIndexPath:(NSIndexPath *)indexPath {
    return kWidthOfCell;
}

- (UITableViewCell *)tableView:(PTEHorizontalTableView *)horizontalTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MRTableViewHorizontalCell * cell = [horizontalTableView.tableView dequeueReusableCellWithIdentifier:@"cell"];
    [cell showTimeLineWithCountOfLine:kCountOfTimeSigmente sizeOfViewIs:(self.countOfCellOnView/2)
                      onIndexPathCell:indexPath.row];
    long keyOfCell = (long)indexPath.row + self.countOfCellOnView/2;
    if (indexPath > self.indexPathOfLastShowCell) {
        keyOfCell = (long)indexPath.row - self.countOfCellOnView/2;
    }
    self.timeLabel.text = [NSDate abstractTimeToTimeAfterNow:keyOfCell inTimeLineSegment:kCountOfTimeSigmente/2];
    NSString* key = [NSString stringWithFormat:@"%ld",keyOfCell];
    self.meetting = [self.dictonaryOfMeeting objectForKey:key];
    self.timeLabel.text = [NSDate abstractTimeToTimeAfterNow:keyOfCell inTimeLineSegment:kCountOfTimeSigmente/2];
    if (![self.timeLabel.text isEqualToString:@"Past"]) {
        if (self.meetting) {
            if ([self.meetting.meetingOwner.email isEqualToString:[MRNetworkManager sharedManager].owner.email]) {
                [cell showYelloy];
            }
        }
    }
    if ([self.room.meetings count]) {
        for (long i = 0; i < [self.room.meetings count]; i++) {
            self.meetting = [MRMeeting new];
            self.meetting = self.room.meetings[i];
            NSNumber* startAbstractTime = [NSNumber numberWithLong:([[NSDate timeToAbstractTime:self.meetting.meetingStart
                                                                                        endTime:kCountOfTimeSigmente  +
                                                                      (self.countOfCellOnView/2)] longValue] +
                                                                    self.countOfCellOnView/2)];
            NSNumber* endAbstractTime = [NSNumber numberWithFloat:([[NSDate timeToAbstractTime:self.meetting.meetingFinish
                                                                                       endTime:kCountOfTimeSigmente  +
                                                                     (self.countOfCellOnView/2)] longValue] +
                                                                   self.countOfCellOnView/2)];
            if ((indexPath.row >= startAbstractTime.integerValue) && (indexPath.row < endAbstractTime.integerValue)) {
                if ([self.meetting.meetingOwner.email isEqualToString:[MRNetworkManager sharedManager].owner.email]) {
                    [cell addMeeting:YES];
                } else {
                    [cell addMeeting:NO];
                }
                NSString *key = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
                [self.dictonaryOfMeeting setObject:self.meetting forKey:key];
            }
        }
    }
    if (indexPath < self.indexPathOfCentralCell) {
        [cell pastTime];
    } else {
        if (indexPath == self.indexPathOfCentralCell) {
            [cell nowLineShow];
        }
    }
    self.indexPathOfLastShowCell = indexPath;
    return cell;
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

#pragma mark - UITextViewDelegate


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    return self.textView.text.length - range.length + text.length < 300;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (self.quotationText.length) {
        NSString *cutString = [self.quotationText substringWithRange:NSMakeRange(1, self.quotationText.length - 2)];
        self.textView.text = cutString;
    } else {
        self.textView.text = self.quotationText;
    }
}

- (void)textViewDidEndEditing:(UITextView *)theTextView {
    if (![self.textView hasText]) {
        self.messagePlaceholder.hidden = NO;
        self.quotationText = @"";
    } else {
        self.quotationText = [NSString stringWithFormat:@"\"%@\"",self.textView.text];
        self.textView.text = self.quotationText;
    }
}

- (void) textViewDidChange:(UITextView *)textView
{
    if (![self.textView hasText]) {
        self.messagePlaceholder.hidden = NO;
    } else {
        self.messagePlaceholder.hidden = YES;
    }
    CGPoint bottomOffset = CGPointMake(0, self.bottomConstraint.constant / 2);
    [self.scrollView setContentOffset:bottomOffset animated:NO];
}

#pragma mark - Handle Events

- (IBAction)timeButtonDidTap:(UIButton *)sender {
    MRTimePickerViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"IDTimePickerVC"];
    controller.modalInPopover = NO;
    controller.preferredContentSize = CGSizeMake(sender.bounds.size.width, self.view.bounds.size.height /3);
    controller.minDate = self.startDate ? self.startDate : [NSDate date];
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
    [self addTimeInterval:kFifteenMinutes];
}

- (IBAction)addThirtyMinutes:(id)sender {
    [self showInRedCircle:MRThirtyMinutesRedCircle];
    [self addTimeInterval:kThirtyMinutes];
}

- (IBAction)addFourtyFiveMinutes:(id)sender {
    [self showInRedCircle:MRFourtyFiveMinutesRedCircle];
    [self addTimeInterval:kFourtyFiveMinutes];
}

- (IBAction)addSixtyMinutes:(id)sender {
    [self showInRedCircle:MRSixtyMinutesRedCircle];
    [self addTimeInterval:kSixtyMinutes];
}

- (IBAction)bookButtonDidPress:(id)sender {
    if (![self.textView hasText] || !self.startDate || !self.finishDate) {
        self.errorLabel.hidden = NO;
    } else {
        self.errorLabel.hidden = YES;
        NSNumber *start = [self convertDateToMiliseconds:self.startDate];
        NSNumber *finish = [self convertDateToMiliseconds:self.finishDate];
        [self.manager bookMeetingInRoom:self.room.roomId from:start to:finish withMessage:self.quotationText completion:^(id success, NSError *error) {
            if (error) {
                [self createAlertForError:error];
            } else {
                [self createAlertWithMessage:success];
            }
        }];
    }
    [self dismissKeyboard:self];
}
- (IBAction)cancelButtonDidPress:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - HandleKeyboardAppearance

- (void)keyboardWasShown:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    self.bottomConstraint.constant = kbSize.height + self.constraintsConstant;
    CGPoint bottomOffset = CGPointMake(0, self.bottomConstraint.constant / 2);
    [self.scrollView setContentOffset:bottomOffset animated:YES];
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {
    self.bottomConstraint.constant = self.constraintsConstant;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}

-(IBAction)dismissKeyboard:(id)sender {
    [self.textView resignFirstResponder];
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

- (void) viewUpdate {
    NSDate *currentDate = [NSDate date];
    NSNumber* abstractTime = [NSDate timeToAbstractTime:currentDate endTime:kCountOfTimeSigmente  +
                              (self.countOfCellOnView/2)];
    abstractTime = [NSNumber numberWithFloat:([abstractTime floatValue] + self.countOfCellOnView/2)];
    self.indexPathOfCentralCell = [NSIndexPath indexPathForRow:abstractTime.integerValue inSection:0];
    [self downloadAndUpdateDate];
}

- (void) downloadAndUpdateDate {
    [[MRNetworkManager sharedManager] getRoomInfoById:self.room.roomId toDate:nil completion:^(id success, NSError *error) {
        if (error) {
            [self createAlertForError:error];
        } else {
            self.room.meetings = [success copy];
            [self.tableView reloadData];
        }
    }];
}

- (void) selectTimeOnTimeLine {
    NSDate *currentDate = [NSDate date];
    NSNumber* abstractTime = [NSDate timeToAbstractTime:currentDate endTime:kCountOfTimeSigmente  +
                              (self.countOfCellOnView/2)];
    NSIndexPath* ip = [NSIndexPath indexPathForRow:abstractTime.integerValue inSection:0];
    abstractTime = [NSNumber numberWithFloat:([abstractTime floatValue] + self.countOfCellOnView/2)];
    self.indexPathOfCentralCell = [NSIndexPath indexPathForRow:abstractTime.integerValue inSection:0];
    [self.tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (NSNumber *)convertDateToMiliseconds:(NSDate *)date {
    NSTimeInterval miliseconds = [date timeIntervalSince1970] * kmilisecInSecond;
    NSNumber *result = @(miliseconds);
    return result;
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
    NSDateComponents *timeComponents = [calendar components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:time];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear fromDate:date];
    resultComponents.hour = timeComponents.hour;
    resultComponents.minute = timeComponents.minute;
    resultComponents.day = dateComponents.day;
    resultComponents.month = dateComponents.month;
    resultComponents.year = dateComponents.year;
    NSDate *result = [calendar dateFromComponents:resultComponents];
    return result;
}

- (void)addTimeInterval:(NSTimeInterval)interval {
    if (self.startDate) {
        self.finishDate = [NSDate dateWithTimeInterval:interval sinceDate:self.startDate];
        self.checkOutTimeLabel.text = [self.timeFormatter stringFromDate:self.finishDate];
    } else {
        self.startDate = [NSDate date];
        self.finishDate = [NSDate dateWithTimeInterval:interval sinceDate:self.startDate];
        self.checkInTimeLabel.text = [self.timeFormatter stringFromDate:self.startDate];
        self.checkOutTimeLabel.text = [self.timeFormatter stringFromDate:self.finishDate];
    }
    
}

@end
