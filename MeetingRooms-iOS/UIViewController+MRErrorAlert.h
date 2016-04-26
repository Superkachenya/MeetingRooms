//
//  UIViewController+MBErrorAlert.h
//  MapBookmarks-iOS
//
//  Created by Danil on 30.03.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

@import UIKit.UIAlertController;


typedef void(^MRCompletionAlert)();

@interface UIViewController (MRErrorAlert)

- (void)createAlertForError:(NSError *)error;
- (void)createAlertWithMessage:(NSString *)message completion:(MRCompletionAlert)block;
- (void)createAlertToConfirmDeleting:(MRCompletionAlert)block;
@end
