//
//  UIViewController+MBErrorAlert.h
//  MapBookmarks-iOS
//
//  Created by Danil on 30.03.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

@import UIKit.UIAlertController;

@interface UIViewController (MRErrorAlert)

- (void)createAlertForError:(NSError *)error;
- (void)createAlertWithMessage:(NSString *)message;

@end
