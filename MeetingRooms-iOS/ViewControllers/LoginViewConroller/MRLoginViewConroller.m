//
//  MRLoginViewConroller.m
//  MeetingRooms-iOS
//
//  Created by Alex on 06.04.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

#import "MRLoginViewConroller.h"
#import <Google/SignIn.h>

@interface MRLoginViewConroller () <GIDSignInUIDelegate>

@end

@implementation MRLoginViewConroller

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNeedsStatusBarAppearanceUpdate];
    [GIDSignIn sharedInstance].uiDelegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - GoogleSignIn

- (IBAction)googleSignInDidTap:(id)sender {
    [[GIDSignIn sharedInstance] signIn];
}


#pragma mark - Navigation

- (IBAction)prepareForUnwindToLogIn:(UIStoryboardSegue *)segue {
    [[GIDSignIn sharedInstance] signOut];
}

#pragma mark - helpers

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
