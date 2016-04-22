//
//  UIView+MRErrorAlert.m
//  MapBookmarks-iOS
//
//  Created by Danil on 30.03.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

#import "UIViewController+MRErrorAlert.h"
#import <Google/SignIn.h>

static NSUInteger const kForbidden = 403;

@implementation UIViewController (MRErrorAlert)

- (void)createAlertForError:(NSError *)error {
    NSDictionary *dictError = [[NSDictionary alloc] initWithDictionary:error.userInfo];
    NSData *dataInfo = [[NSData alloc] initWithData:dictError[@"com.alamofire.serialization.response.error.data"]];
    NSDictionary *results = [NSJSONSerialization JSONObjectWithData:dataInfo options:NSJSONReadingMutableContainers error:nil];
    NSString *message = nil;
    if (results) {
        NSNumber *errorCode = results[@"error"];
        message = results[@"details"];
        if ([errorCode isEqualToNumber:@(kForbidden)]) {
            [[GIDSignIn sharedInstance] signOut];
        }
    } else {
        message = error.localizedDescription;
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error!"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:YES completion:nil];
    [self performSelector:@selector(closeAlert) withObject:nil afterDelay:1.5];
}

- (void)createAlertWithMessage:(NSString *)message {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Success!"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:YES completion:nil];
    [self performSelector:@selector(closeAlert) withObject:nil afterDelay:1.5];
}

- (void)createAlertToConfirmDeleting {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Are you sure"
                                                                   message:@"You want to cancel this meeting?"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *noButton = [UIAlertAction actionWithTitle:@"No"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                                     }];
    UIAlertAction *yesButton = [UIAlertAction actionWithTitle:@"Yes"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         [self performSegueWithIdentifier:@"unwindToSheduleVC" sender:self];
                                                     }];
    [alert addAction:noButton];
    [alert addAction:yesButton];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void) closeAlert {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
