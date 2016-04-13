//
//  UIColor+MRColorFromHEX.h
//  MeetingRooms-iOS
//
//  Created by Danil on 08.04.16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

@import UIKit.UIColor;

@interface UIColor (MRColorFromHEX)

+ (UIColor *)getUIColorFromHexString:(NSString *)hexStr alpha:(CGFloat)alpha;
+ (BOOL)color:(UIColor *)color1 isEqualToColor:(UIColor *)color2 withTolerance:(CGFloat)tolerance;

@end
