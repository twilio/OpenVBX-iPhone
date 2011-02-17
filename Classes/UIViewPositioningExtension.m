/**
 * "The contents of this file are subject to the Mozilla Public License
 *  Version 1.1 (the "License"); you may not use this file except in
 *  compliance with the License. You may obtain a copy of the License at
 *  http://www.mozilla.org/MPL/
 
 *  Software distributed under the License is distributed on an "AS IS"
 *  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 *  License for the specific language governing rights and limitations
 *  under the License.
 
 *  The Original Code is OpenVBX, released February 18, 2011.
 
 *  The Initial Developer of the Original Code is Twilio Inc.
 *  Portions created by Twilio Inc. are Copyright (C) 2010.
 *  All Rights Reserved.
 
 * Contributor(s):
 **/

#import "UIViewPositioningExtension.h"


@implementation UIView (Positioning)

- (CGFloat)left {
    return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)left {
    CGRect newFrame = self.frame;
    newFrame.origin.x = left;
    self.frame = newFrame;
}

- (CGFloat)top {
    return self.frame.origin.y;
}

- (void)setTop:(CGFloat)top {
    CGRect newFrame = self.frame;
    newFrame.origin.y = top;
    self.frame = newFrame;
}

- (CGFloat)right {
    CGRect frame = self.frame;    
    return frame.origin.x + frame.size.width;
}

- (void)setRight:(CGFloat)right {
    CGRect newFrame = self.frame;
    newFrame.origin.x = right - newFrame.size.width;
    self.frame = newFrame;
}

- (CGFloat)bottom {
    CGRect frame = self.frame;
    return frame.origin.y + frame.size.height;
}

- (void)setBottom:(CGFloat)bottom {
    CGRect newFrame = self.frame;
    newFrame.origin.y = bottom - newFrame.size.height;
    self.frame = newFrame;
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height {
    CGRect newFrame = self.frame;
    newFrame.size.height = height;
    self.frame = newFrame;
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width {
    CGRect newFrame = self.frame;
    newFrame.size.width = width;
    self.frame = newFrame;
}

- (CGSize)size {
    return self.frame.size;
}

- (void)setSize:(CGSize)size {
    CGRect newFrame = self.frame;
    newFrame.size.width = size.width;
    newFrame.size.height = size.height;
    self.frame = newFrame;
}

- (CGFloat)centerX {
    CGRect frame = self.frame;
    return frame.origin.x + (frame.size.width / 2);
}

- (void)setCenterX:(CGFloat)centerX {
    CGRect newFrame = self.frame;
    newFrame.origin.x = round(centerX - (newFrame.size.width / 2));
    self.frame = newFrame;
}

- (CGFloat)centerY {
    CGRect frame = self.frame;
    return frame.origin.y + (frame.size.height / 2);
}

- (void)setCenterY:(CGFloat)centerY {
    CGRect newFrame = self.frame;
    newFrame.origin.y = round(centerY - (newFrame.size.height / 2));
    self.frame = newFrame;
}

- (void)centerHorizontallyInView:(UIView *)view {
    self.left = round((view.width / 2) - (self.width / 2));
}

- (void)centerVerticallyInView:(UIView *)view {
    self.top = round((view.height / 2) - (self.height / 2));
}

@end
