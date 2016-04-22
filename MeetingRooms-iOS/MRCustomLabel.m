//
//  MRCustomLabel.m
//  MeetingRooms-iOS
//
//  Created by Alex on 4/17/16.
//  Copyright © 2016 Cleveroad. All rights reserved.
//

#import "MRCustomLabel.h"

@implementation MRCustomLabel

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.numberOfLines == 0 && self.preferredMaxLayoutWidth != CGRectGetWidth(self.frame)) {
        self.preferredMaxLayoutWidth = self.frame.size.width;
        [self setNeedsUpdateConstraints];
    }
}

- (CGSize)intrinsicContentSize {
    CGSize sizeContent = [super intrinsicContentSize];
    
    if (self.numberOfLines == 0) {
        sizeContent.height += 1;
    }
    return sizeContent;
}

@end
