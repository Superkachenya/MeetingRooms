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
#import "MRUser.h"
#import "WYPopoverController.h"
#import "MRTimePickerViewController.h"
#import "FSCalendar.h"
#import "UIViewController+MRErrorAlert.h"
#import "NSDate+MRNextMinute.h"
#import "MRMeeting.h"
#import "NSString+MRQuotesString.h"

typedef NS_ENUM(NSUInteger, MRRedCircle) {
    MRFifteenMinutesRedCircle,
    MRThirtyMinutesRedCircle,
    MRFourtyFiveMinutesRedCircle,
    MRSixtyMinutesRedCircle
};

static NSInteger const kSunday = 1;
static NSUInteger const kMonday = 2;
static NSInteger const kSaturday = 7;
static NSTimeInterval const kFifteenMinutes    = 900.0;
static NSTimeInterval const kThirtyMinutes     = 1800.0;
static NSTimeInterval const kFourtyFiveMinutes = 2700.0;
static NSTimeInterval const kSixtyMinutes      = 3600.0;
static double const kmilisecInSecond           = 1000.0;
static double const kCountOfTimeSegment        = 48.0;
static double const kWidthOfCell               = 20.0;

@interface MRBookingViewController () <PTETableViewDelegate, WYPopoverControllerDelegate, FSCalendarDelegate, FSCalendarDataSource, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *timePickerButton;
@property (weak, nonatomic) IBOutlet UIButton *datePickerButton;
@property (weak, nonatomic) IBOutlet UILabel *timeButtonLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateButtonLabel;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *timeCircles;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *redCircles;
@property (weak, nonatomic) IBOutlet UIButton *fifteenButton;
@property (weak, nonatomic) IBOutlet UIButton *thirtyButton;
@property (weak, nonatomic) IBOutlet UIButton *fourtyFiveButton;
@property (weak, nonatomic) IBOutlet UIButton *sixtyButton;
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

@property (strong, nonatomic) NSString *sendMessage;
@property (assign, nonatomic) CGFloat constraintsConstant;
@property (strong, nonatomic) MRNetworkManager *manager;
@property (strong, nonatomic) WYPopoverController *popover;
@property (strong, nonatomic) NSDateFormatter *timeFormatter;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSDate *calendarDate;
@property (strong, nonatomic) NSDate *timePickerTime;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *finishDate;
@property (strong, nonatomic) NSMutableDictionary *dictonaryOfMeeting;
@property (assign, nonatomic) NSUInteger countOfHidenCellOnView;
@property (assign, nonatomic) NSUInteger indexOfCellWithNowLine;
@property (assign, nonatomic) NSUInteger indexOfLastShowCell;
@property (strong, nonatomic) MRMeeting *meetting;
@property (strong, nonatomic) MROwner *owner;

@end

@implementation MRBookingViewController

#pragma mark - UIViewLifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.owner = [MRNetworkManager sharedManager].owner;
    self.room.meetings = [NSMutableArray new];
    self.dictonaryOfMeeting = [NSMutableDictionary new];
    self.countOfHidenCellOnView = ([self.horizontalTableView bounds].size.width / kWidthOfCell) / 2;
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
        circle.backgroundColor = [UIColor getUIColorFromHexString:@"#302D44"];
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
    return kCountOfTimeSegment + (self.countOfHidenCellOnView * 2) ;
}

- (CGFloat)tableView:(PTEHorizontalTableView *)horizontalTableView widthForCellAtIndexPath:(NSIndexPath *)indexPath {
    return kWidthOfCell;
}

- (UITableViewCell *)tableView:(PTEHorizontalTableView *)horizontalTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MRTableViewHorizontalCell * cell = [horizontalTableView.tableView dequeueReusableCellWithIdentifier:@"cell"];
    [cell showTimeLineWithCountOfLine:kCountOfTimeSegment sizeOfViewIs:self.countOfHidenCellOnView atIndexCell:indexPath.row];
    MRMeeting* meeting = [self.dictonaryOfMeeting objectForKey:[NSString stringWithFormat:@"%ld",[NSNumber numberWithInteger:indexPath.row].longValue]];
    if (meeting) {
        if ([meeting.meetingOwner.email isEqualToString:[MRNetworkManager sharedManager].owner.email]) {
            [cell addMeeting:YES];
        } else {
            [cell addMeeting:NO];
        }
    }
    [self refleshTimeLabel:[self getCentralCellRowByIndexPath:[NSNumber numberWithInteger:indexPath.row].longValue]];
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"dd/MM/yy";
    NSString *selectedDate = [dateFormatter stringFromDate:self.calendarDate];
    NSString *currentDate = [dateFormatter stringFromDate:[NSDate  new]];
    if ([selectedDate isEqualToString:currentDate]) {
        if (indexPath.row < self.indexOfCellWithNowLine) {
            [cell pastTime];
        } else {
            if (indexPath.row == self.indexOfCellWithNowLine) {
                [cell updateClocks];
            }
        }
    }
    return cell;
}

#pragma mark - FSCalendarDelegate

- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date {
    NSCalendar *myCalendar = [NSCalendar currentCalendar];
    NSInteger weekday = [myCalendar component:NSCalendarUnitWeekday fromDate:date];
    if (weekday == kSunday || weekday == kSaturday) {
        return NO;
    }
    return YES;
}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date {
    self.calendarDate = date;
    self.startDate = [self createDateFromTime:self.timePickerTime andDate:self.calendarDate];
    self.dateButtonLabel.text = [self.dateFormatter stringFromDate:date];
    self.finishDate = [NSDate dateWithTimeInterval:kFifteenMinutes sinceDate:self.startDate];
    self.checkOutTimeLabel.text = [self.timeFormatter stringFromDate:self.finishDate];
    [self.popover dismissPopoverAnimated:YES];
    [self downloadAndUpdateDate];
    
}

#pragma mark - FSCalendarDataSource

- (NSDate *)minimumDateForCalendar:(FSCalendar *)calendar {
    return [NSDate date];
}

#pragma mark - UITextViewDelegate


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        [self dismissKeyboard:self];
        return NO;
    }
    return self.textView.text.length - range.length + text.length < 300;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    self.textView.text = self.sendMessage;
}

- (void)textViewDidEndEditing:(UITextView *)theTextView {
    if (![self.textView hasText]) {
        self.messagePlaceholder.hidden = NO;
        self.sendMessage = @"";
    } else {
        self.sendMessage = self.textView.text;
        self.textView.text = [NSString embedStringinQuotes:self.textView.text];
    }
}

- (void) textViewDidChange:(UITextView *)textView {
    if (![self.textView hasText]) {
        self.messagePlaceholder.hidden = NO;
    } else {
        self.messagePlaceholder.hidden = YES;
    }
}

#pragma mark - Handle Events

- (IBAction)timeButtonDidTap:(UIButton *)sender {
    [self dismissKeyboard:sender];
    MRTimePickerViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"IDTimePickerVC"];
    controller.modalInPopover = NO;
    controller.preferredContentSize = CGSizeMake(sender.bounds.size.width, self.view.bounds.size.height /3);
    controller.minDate = self.startDate ? self.startDate : [NSDate date];
    controller.changedTime = ^(NSDate *date){
        [self showInRedCircle:MRFifteenMinutesRedCircle];
        self.timePickerTime = date;
        self.startDate = [self createDateFromTime:self.timePickerTime andDate:self.calendarDate];
        self.timeButtonLabel.text = [self.timeFormatter stringFromDate:date];
        [self addFifteenMinutes:self];
        [self setDurationPossibleButtons];
    };
    self.popover = [[WYPopoverController alloc] initWithContentViewController:controller];
    self.popover.delegate = self;
    self.popover.wantsDefaultContentAppearance = NO;
    [self.popover presentPopoverFromRect:sender.bounds inView:sender permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];
}

- (IBAction)dateButtonDidTap:(UIButton *)sender {
    [self dismissKeyboard:sender];
    [self showInRedCircle:MRFifteenMinutesRedCircle];
    UIViewController *controller = [[UIViewController alloc] init];
    controller.modalInPopover = NO;
    controller.preferredContentSize = CGSizeMake(280.0, self.view.frame.size.height/2);
    FSCalendar *calendarView = [[FSCalendar alloc] initWithFrame:CGRectMake(0, 0, 280.0, self.view.bounds.size.height /2)];
    calendarView.delegate = self;
    calendarView.dataSource = self;
    calendarView.appearance.titleWeekendColor = [UIColor grayColor];
    calendarView.firstWeekday = kMonday;
    controller.view = calendarView;
    self.popover = [[WYPopoverController alloc] initWithContentViewController:controller];
    self.popover.delegate = self;
    self.popover.wantsDefaultContentAppearance = NO;
    [self.popover presentPopoverFromRect:sender.bounds inView:sender permittedArrowDirections:WYPopoverArrowDirectionAny animated:YES];
}

- (IBAction)addFifteenMinutes:(id)sender {
    [self dismissKeyboard:sender];
    [self showInRedCircle:MRFifteenMinutesRedCircle];
    [self addTimeInterval:kFifteenMinutes];
}

- (IBAction)addThirtyMinutes:(id)sender {
    [self dismissKeyboard:sender];
    [self showInRedCircle:MRThirtyMinutesRedCircle];
    [self addTimeInterval:kThirtyMinutes];
}

- (IBAction)addFourtyFiveMinutes:(id)sender {
    [self dismissKeyboard:sender];
    [self showInRedCircle:MRFourtyFiveMinutesRedCircle];
    [self addTimeInterval:kFourtyFiveMinutes];
}

- (IBAction)addSixtyMinutes:(id)sender {
    [self dismissKeyboard:sender];
    [self showInRedCircle:MRSixtyMinutesRedCircle];
    [self addTimeInterval:kSixtyMinutes];
}

- (IBAction)bookButtonDidPress:(id)sender {
    if (![self.textView hasText] || !self.startDate || !self.finishDate) {
        self.errorLabel.hidden = NO;
    } else {
        if (!self.sendMessage) {
            self.sendMessage = self.textView.text;
        }
        self.errorLabel.hidden = YES;
        NSNumber *start = [self convertDateToMiliseconds:self.startDate];
        NSNumber *finish = [self convertDateToMiliseconds:self.finishDate];
        [self.manager bookMeetingInRoom:self.room.roomId from:start to:finish withMessage:self.sendMessage completion:^(id success, NSError *error) {
            if (error) {
                [self createAlertForError:error];
            } else {
                [self createAlertWithMessage:success completion:^{
                    [self performSegueWithIdentifier:@"toSheduleFromBooking" sender:self];
                }];
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
    self.bottomConstraint.constant = kbSize.height;
    CGPoint bottomOffset;
    if (self.preferredInterfaceOrientationForPresentation == UIInterfaceOrientationPortrait) {
        bottomOffset = CGPointMake(0.0, self.view.frame.origin.y * 2);
    } else {
        bottomOffset = CGPointMake(0.0, self.view.frame.origin.y * 10);
    }
    [self.scrollView setContentOffset:bottomOffset animated:YES];
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {
    self.bottomConstraint.constant = self.constraintsConstant;
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)dismissKeyboard:(id)sender {
    [self.textView resignFirstResponder];
}

#pragma mark - Helpers

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

- (void)showInRedCircle:(MRRedCircle)circle {
    for (UIImageView *redCircle in self.redCircles) {
        if ([redCircle isEqual:self.redCircles[circle]]) {
            redCircle.hidden = NO;
        } else {
            redCircle.hidden = YES;
        }
    }
}

- (void)setDurationPossibleButtons {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitHour|NSCalendarUnitMinute fromDate:self.startDate];
    if (components.hour == 19 && components.minute == 45) {
        self.sixtyButton.enabled = NO;
        self.fourtyFiveButton.enabled = NO;
        self.thirtyButton.enabled = NO;
        self.fifteenButton.enabled = YES;
    } else if (components.hour == 19 && components.minute == 30){
        self.sixtyButton.enabled = NO;
        self.fourtyFiveButton.enabled = NO;
        self.thirtyButton.enabled = YES;
        self.fifteenButton.enabled = YES;
    } else if (components.hour == 19 && components.minute == 15){
        self.sixtyButton.enabled = NO;
        self.fourtyFiveButton.enabled = YES;
        self.thirtyButton.enabled = YES;
        self.fifteenButton.enabled = YES;
    } else {
        self.sixtyButton.enabled = YES;
        self.fourtyFiveButton.enabled = YES;
        self.thirtyButton.enabled = YES;
        self.fifteenButton.enabled = YES;
    }
}

#pragma mark - HorizontalScrollScreenHelpers

- (void) viewUpdate {
    NSUInteger abstractTime = [NSDate timeToAbstractTime:[NSDate date] visiblePath:kCountOfTimeSegment andHidenPath:self.countOfHidenCellOnView];
    self.indexOfCellWithNowLine = [NSIndexPath indexPathForRow:abstractTime inSection:0].row;
    [self downloadAndUpdateDate];
}

- (void)downloadAndUpdateDate {
    if (!self.calendarDate) {
        self.calendarDate = [NSDate date];
    }
    self.room.meetings = nil;
    [[MRNetworkManager sharedManager] getRoomInfoById:self.room.roomId toDate:self.calendarDate completion:^(id success, NSError *error) {
        if (error) {
            [self createAlertForError:error];
        } else {
            self.room.meetings = success;
            [self createDictionaryWithMeeting];
            [self.tableView reloadData];
        }
    }];
}

- (void) selectTimeOnTimeLine {
    NSUInteger abstractTime = [NSDate timeToAbstractTime:[NSDate date] visiblePath:kCountOfTimeSegment andHidenPath:self.countOfHidenCellOnView];
    NSIndexPath* ip = [NSIndexPath indexPathForRow:abstractTime - self.countOfHidenCellOnView inSection:0];
    [self.tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:YES];
    self.indexOfCellWithNowLine = [NSIndexPath indexPathForRow:abstractTime inSection:0].row;
}

- (void)addTimeInterval:(NSTimeInterval)interval {
    if (!self.startDate) {
        self.startDate = [NSDate date];
    }
    self.checkInTimeLabel.text = [self.timeFormatter stringFromDate:self.startDate];
    self.finishDate = [NSDate dateWithTimeInterval:interval sinceDate:self.startDate];
    self.checkOutTimeLabel.text = [self.timeFormatter stringFromDate:self.finishDate];
}

- (NSUInteger) getCentralCellRowByIndexPath:(long)index {
    NSUInteger keyOfCell = index + self.countOfHidenCellOnView;
    if (index > self.indexOfLastShowCell) {
        keyOfCell = index - self.countOfHidenCellOnView;
    }
    self.indexOfLastShowCell = index;
    return keyOfCell;
}

- (void)refleshTimeLabel:(long) abstractTime {
    MRMeeting* meetting = [self.dictonaryOfMeeting objectForKey:[NSString stringWithFormat:@"%ld",abstractTime]];
    if (!meetting) {
        self.timeLabel.text = @"Free now!";
    } else {
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"HH:mm";
        self.timeLabel.text = [NSString stringWithFormat:@"%@ - %@",[dateFormatter stringFromDate:meetting.meetingStart],[dateFormatter stringFromDate:meetting.meetingFinish]];
    }
}

- (void) createDictionaryWithMeeting {
    self.dictonaryOfMeeting = [NSMutableDictionary new];
    if ([self.room.meetings count]) {
        MRMeeting* meetting = nil;
        for (NSUInteger i = 0; i < [self.room.meetings count]; i++) {
            meetting = self.room.meetings[i];
            NSUInteger startAbstractTime = [NSDate timeToAbstractTime:meetting.meetingStart visiblePath:kCountOfTimeSegment andHidenPath:self.countOfHidenCellOnView];
            NSUInteger endAbstractTime = [NSDate timeToAbstractTime:meetting.meetingFinish visiblePath:kCountOfTimeSegment andHidenPath:self.countOfHidenCellOnView];
            for (NSUInteger i = startAbstractTime; i < endAbstractTime; i++) {
                [self.dictonaryOfMeeting setObject:meetting forKey:[NSString stringWithFormat:@"%ld",(unsigned long)i]];
            }
        }
    }
}
@end
