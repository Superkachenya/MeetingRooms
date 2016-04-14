//
//  MRRoomsViewController.m
//  MeetingRooms-iOS
//
//  Created by Danil on 08.04.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

#import "MRRoomsViewController.h"
#import "MRCustomRoomsCell.h"
#import "MRRoom.h"
#import <Google/SignIn.h>
#import "NSDate+MRNextMinute.h"
#import "MRNetworkManager.h"
#import "UIViewController+MRErrorAlert.h"
#import "MRRoomWithHorizontalScrollViewController.h"


@interface MRRoomsViewController () <UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (strong, nonatomic) NSArray *testieRooms;

@end

@implementation MRRoomsViewController

#pragma mark - UIViewLifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.testieRooms = [NSArray new];
    
    [self updateClocks];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    [self updateRoomsStatus];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.testieRooms.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MRCustomRoomsCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    MRRoom *currentRoom = self.testieRooms[indexPath.row];
    [cell configureCellWithRoom:currentRoom];
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toRoomDetails"]) {
        MRRoomWithHorizontalScrollViewController *details = segue.destinationViewController;
        NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
        details.room = self.testieRooms[indexPath.row];
    }
}

- (IBAction)prepareForUnwindToRooms:(UIStoryboardSegue *)segue {
    
}

#pragma mark - Helpers

- (void)updateClocks {
    NSDate *actualTime = [NSDate date];
    NSTimeInterval delay = [[actualTime nextMinute] timeIntervalSinceDate:actualTime];
    NSDateFormatter *clocksFormat = [NSDateFormatter new];
    clocksFormat.dateFormat = @"HH:mm";
    NSDateFormatter *dateFormat = [NSDateFormatter new];
    dateFormat.dateFormat = @"MMMM d";
    self.timeLabel.text = [clocksFormat stringFromDate:actualTime];
    self.dateLabel.text = [dateFormat stringFromDate:actualTime];
    __weak id weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf performSelector:@selector(updateClocks) withObject:nil afterDelay:delay];
    });
}

- (void)updateRoomsStatus {
    [[MRNetworkManager sharedManager] getRoomsStatusWithCompletionBlock:^(id success, NSError *error) {
        if (error) {
            [self createAlertForError:error];
        } else {
            self.testieRooms = success;
            [self.tableView reloadData];
        }
    }];
}
@end
