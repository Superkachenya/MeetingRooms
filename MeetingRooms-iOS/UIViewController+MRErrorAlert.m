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
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error!"
                                                                   message:error.localizedDescription
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok"
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * _Nonnull action) {
                                                   [self dismissViewControllerAnimated:YES completion:nil];
                                               }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)createAlertWithMessage:(NSString *)message {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Success!"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:YES completion:nil];
    [self performSelector:@selector(closeAlert) withObject:nil afterDelay:1.0];
}

- (void) closeAlert {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
