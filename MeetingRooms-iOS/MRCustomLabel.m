//
//  MRCustomLabel.m
//  MeetingRooms-iOS
//
//  Created by Alex on 4/17/16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

#import "MRCustomLabel.h"

@implementation MRCustomLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.numberOfLines == 0 && self.preferredMaxLayoutWidth != CGRectGetWidth(self.frame)) {
        self.preferredMaxLayoutWidth = self.frame.size.width;
        [self setNeedsUpdateConstraints];
    }
}

- (CGSize)intrinsicContentSize {
    CGSize s = [super intrinsicContentSize];
    
    if (self.numberOfLines == 0) {
        // found out that sometimes intrinsicContentSize is 1pt too short!
        s.height += 1;
    }
    
    return s;
}

@end
