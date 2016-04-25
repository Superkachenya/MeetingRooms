//
//  UIViewController+MBErrorAlert.h
//  MapBookmarks-iOS
//
//  Created by Danil on 30.03.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

@import UIKit.UIAlertController;

typedef void(^MRConfirmDelete)();
typedef void(^MRCompletionSuccess)();

@interface UIViewController (MRErrorAlert)

- (void)createAlertForError:(NSError *)error;
- (void)createAlertWithMessage:(NSString *)message completion:(MRCompletionSuccess)block;
- (void)createAlertToConfirmDeleting:(MRConfirmDelete)block;
@end
