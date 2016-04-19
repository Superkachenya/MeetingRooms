//
//  UIView+MRErrorAlert.m
//  MapBookmarks-iOS
//
//  Created by Danil on 30.03.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

#import "UIViewController+MRErrorAlert.h"

@implementation UIViewController (MRErrorAlert)

- (void)createAlertForError:(NSError *)error {
    NSDictionary *dictError = [[NSDictionary alloc] initWithDictionary:error.userInfo];
    NSData *dataInfo = [[NSData alloc] initWithData:dictError[@"com.alamofire.serialization.response.error.data"]];
    NSDictionary *results = [NSJSONSerialization JSONObjectWithData:dataInfo options:NSJSONReadingMutableContainers error:nil];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error!"
                                                                   message:results ? results[@"details"] : error.localizedDescription
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:YES completion:nil];
    [self performSelector:@selector(closeAlert) withObject:nil afterDelay:2.0];
}

- (void)createAlertWithMessage:(NSString *)message {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Success!"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:YES completion:nil];
    [self performSelector:@selector(closeAlert) withObject:nil afterDelay:2.0];
}

- (void) closeAlert {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
