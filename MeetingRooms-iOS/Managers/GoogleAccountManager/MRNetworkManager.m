//
//  MRGoogleAccountManager.m
//  MeetingRooms-iOS
//
//  Created by Danil on 06.04.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

#import "MRNetworkManager.h"
#import <AFNetworking/AFNetworking.h>
#import "MROwner.h"
#import "MRRoom.h"
#import "MRMeeting.h"
#import "SVProgressHUD.h"

NSString *const baseURL = @"http://redmine.cleveroad.com:3503";

@interface MRNetworkManager ()

@property (strong, nonatomic) AFHTTPSessionManager *manager;
@property (strong, nonatomic) NSString *headerToken;

@end

@implementation MRNetworkManager

+ (instancetype)sharedManager {
    static MRNetworkManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [MRNetworkManager new];
        sharedManager.manager = [AFHTTPSessionManager manager];
        sharedManager.manager.requestSerializer = [AFJSONRequestSerializer serializer];
    });
    return sharedManager;
}

- (void)getAccessWithGoogleToken:(NSString *)token completionBlock:(MRCompletion)block {
    MRCompletion copyBlock = [block copy];
    NSString *tempString = [baseURL stringByAppendingString:@"/api/v1/login"];
    NSDictionary *params = @{@"googleAccessToken": token};
    [SVProgressHUD show];
    [self.manager POST:tempString parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        self.owner = [[MROwner alloc] initWithJSON:responseObject];
        self.headerToken = [@"bearer " stringByAppendingString:self.owner.accessToken];
        [self.manager.requestSerializer setValue:self.headerToken forHTTPHeaderField:@"Authorization"];
        copyBlock(responseObject, nil);
        [SVProgressHUD dismiss];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        copyBlock(nil, error);
        [SVProgressHUD dismiss];
    }];
}

- (void)getRoomsStatusWithCompletionBlock:(MRCompletion)block {
    MRCompletion copyBlock = [block copy];
    NSString *tempString = [baseURL stringByAppendingString:@"/api/v1/rooms"];
    [SVProgressHUD show];
    [self.manager GET:tempString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            NSMutableArray *rooms = [NSMutableArray new];
            for (id room in responseObject) {
                MRRoom *tempRoom = [[MRRoom alloc] initRoomUsingJSON:room];
                [rooms addObject:tempRoom];
            }
            copyBlock([rooms copy], nil);
            [SVProgressHUD dismiss];
        } else {
            NSError *error = nil;
            copyBlock(nil, error);
            [SVProgressHUD dismiss];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        copyBlock(nil, error);
        [SVProgressHUD dismiss];
    }];
}

- (void)getRoomInfoById:(NSNumber *)roomId toDate:(NSDate *)date completion:(MRCompletion)block {
    MRCompletion copyBlock = [block copy];
    NSString *tempString = [baseURL stringByAppendingString:@"/api/v1/rooms/"];
    if (!date) {
        tempString = [tempString stringByAppendingString:roomId.stringValue];
    } else {
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateFormat = @"YYYY-MM-dd";
        tempString = [NSString stringWithFormat:@"%@%@?date=%@",tempString,roomId.stringValue, [formatter stringFromDate:date]];
    }
    [SVProgressHUD show];
    [self.manager GET:tempString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            NSMutableArray *meetings = [NSMutableArray new];
            for (id booking in responseObject) {
                MRMeeting *newMeeting = [[MRMeeting alloc] initMeetingForRoomWithJSON:booking];
                [meetings addObject:newMeeting];
            }
            copyBlock([meetings copy], nil);
            [SVProgressHUD dismiss];
        } else {
            NSError *error = nil;
            copyBlock(nil, error);
            [SVProgressHUD dismiss];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        copyBlock(nil, error);
        [SVProgressHUD dismiss];
    }];
}

- (void)bookMeetingInRoom:(NSNumber *)roomId from:(NSNumber *)start to:(NSNumber *)finish withMessage:(NSString *)message completion:(MRCompletion)block {
    MRCompletion copyBlock = [block copy];
    NSString *composeStr = [NSString stringWithFormat:@"/api/v1/rooms/%ld/bookings", (long)roomId.integerValue];
    NSString *tempString = [baseURL stringByAppendingString:composeStr];
    [SVProgressHUD show];
    [self.manager POST:tempString parameters:@{@"timeStart" : start,
                                               @"timeEnd" : finish,
                                               @"message" : message}
              progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                  NSString *success = [responseObject valueForKey:@"details"];
                  copyBlock(success, nil);
                  [SVProgressHUD dismiss];
              } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                  copyBlock(nil, error);
                  [SVProgressHUD dismiss];
              }];
}

- (void)getAllOwnersMeetingsForDate:(NSDate *)date offset:(NSUInteger)offset WithCompletionBlock:(MRCompletion)block {
    MRCompletion copyBlock = [block copy];
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"YYYY-MM-dd";
    NSString *dateString = [formatter stringFromDate:date];
    NSString *tempString = [NSString stringWithFormat:@"%@/api/v1/users/%ld/bookings?date=%@&limit=10&offset=%lu", baseURL, (long)self.owner.userId.integerValue, dateString, (long)offset];
    [self.manager GET:tempString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            NSDictionary *dict = [responseObject firstObject];
            NSArray *bookings = dict[@"bookings"];
            NSMutableArray *arrayOfMeetings = [NSMutableArray new];
            for (id meeting in bookings) {
                MRMeeting *newMeeting = [[MRMeeting alloc] initMeetingForUser:self.owner withJSON:meeting];
                [arrayOfMeetings addObject:newMeeting];
            }
            copyBlock(arrayOfMeetings, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        copyBlock(nil, error);
    }];
}

- (void)getAllMeetingsForWeekSinceDate:(NSDate *)date completion:(MRCompletion)block{
    MRCompletion copyBlock = [block copy];
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"YYYY-MM-dd";
    NSString *dateString = [formatter stringFromDate:date];
    NSString *tempString = [NSString stringWithFormat:@"%@/api/v1/users/%ld/bookings?date=%@&week=true", baseURL, (long)self.owner.userId.integerValue, dateString];
    [self.manager GET:tempString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSMutableArray *arrayOfCounts = [NSMutableArray new];
        if ([responseObject isKindOfClass:[NSArray class]]) {
            for (id count in responseObject) {
                NSNumber *todayCount = [count valueForKey:@"count"];
                [arrayOfCounts addObject:todayCount];
            }
            copyBlock([arrayOfCounts copy], nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        copyBlock(nil, error);
    }];

}

- (void)deleteMeeting:(NSNumber *)meetingId completion:(MRCompletion)block {
    MRCompletion copyBlock = [block copy];
    NSString *tempstring = [NSString stringWithFormat:@"%@/api/v1/bookings/%ld", baseURL, (long)meetingId.integerValue];
    [self.manager DELETE:tempstring parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *success = [responseObject valueForKey:@"details"];
        copyBlock(success, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        copyBlock(nil, error);
    }];
}
@end
