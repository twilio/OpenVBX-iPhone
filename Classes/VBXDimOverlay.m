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

#import "VBXDimOverlay.h"
#import "VBXConfiguration.h"

@implementation VBXDimOverlay

+ (VBXDimOverlay *)overlay {
    return [[[VBXDimOverlay alloc] initWithFrame:CGRectZero] autorelease];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = ThemedColor(@"dimOverlayBackgroundColor", [UIColor colorWithWhite:0 alpha:0.4]);
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    // Take the size of our new paren
    self.frame = newSuperview.bounds;
    
    // Don't let our parent take our touch events.  E.g. This is helpful
    // when we're overlayed on top of a UITableView
    _parentHadUserInteractionEnabled = newSuperview.userInteractionEnabled;
    newSuperview.userInteractionEnabled = NO;
    
    self.alpha = 0.0;
}

- (void)didMoveToSuperview {
    [UIView beginAnimations:@"FadeIn" context:nil];
    [UIView setAnimationDuration:0.5];
    
    self.alpha = 1.0;
    
    [UIView commitAnimations];
}

- (void)removeFromSuperview {
    self.superview.userInteractionEnabled = _parentHadUserInteractionEnabled;
    [super removeFromSuperview];
}

- (void)dealloc {
    [super dealloc];
}


@end
