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

NSString *const baseURL = @"http://redmine.cleveroad.com:3501";

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
    [self.manager POST:tempString parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        self.owner = [[MROwner alloc] initWithJSON:responseObject];
        self.headerToken = [@"bearer " stringByAppendingString:self.owner.accessToken];
        [self.manager.requestSerializer setValue:self.headerToken forHTTPHeaderField:@"Authorization"];
        copyBlock(responseObject, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        copyBlock(nil, error);
    }];
}

- (void)getRoomsStatusWithCompletionBlock:(MRCompletion)block {
    MRCompletion copyBlock = [block copy];
    NSString *tempString = [baseURL stringByAppendingString:@"/api/v1/rooms"];
    [self.manager GET:tempString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            NSMutableArray *rooms = [NSMutableArray new];
            for (id room in responseObject) {
                MRRoom *tempRoom = [[MRRoom alloc] initRoomUsingJSON:room];
                [rooms addObject:tempRoom];
            }
            copyBlock([rooms copy], nil);
        } else {
            NSError *error = nil;
            copyBlock(nil, error);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        copyBlock(nil, error);
        
    }];
}

- (void)getRoomInfoById:(NSNumber *)roomId toDate:(NSDate *)date completion:(MRCompletion)block {
    NSString *tempString = [baseURL stringByAppendingString:@"/api/v1/rooms/"];
    if (!date) {
        tempString = [tempString stringByAppendingString:roomId.stringValue];
    } else {
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateFormat = @"YYYY-MM-dd";
        tempString = [NSString stringWithFormat:@"%@%@?date=%@",tempString,roomId.stringValue, [formatter stringFromDate:date]];
        NSLog(@"%@",tempString);
    }
    MRCompletion copyBlock = [block copy];
    [self.manager GET:tempString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            NSMutableArray *meetings = [NSMutableArray new];
            for (id booking in responseObject) {
                MRMeeting *newMeeting = [[MRMeeting alloc] initMeetingWithJSON:booking];
                [meetings addObject:newMeeting];
            }
            copyBlock([meetings copy], nil);
        } else {
            NSError *error = nil;
            copyBlock(nil, error);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        copyBlock(nil, error);
    }];
}
@end
