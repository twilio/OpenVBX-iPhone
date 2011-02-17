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

#import "VBXActivityLabel.h"
#import "UIViewPositioningExtension.h"
#import "VBXConfiguration.h"

@implementation VBXActivityLabel

@synthesize label = _label;

- (id)initWithText:(NSString *)text {
    if (self = [super initWithFrame:CGRectZero]) {
        _label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        _label.text = text;
        _label.font = [UIFont systemFontOfSize:15.0];
        _label.textColor = ThemedColor(@"activityLabelTextColor", ThemedColor(@"secondaryTextColor", [UIColor darkGrayColor]));
        _label.backgroundColor = [UIColor clearColor];
        [_label sizeToFit];
        
        _activityIndicatorView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
        [_activityIndicatorView startAnimating];
        [_activityIndicatorView sizeToFit];
        
        [self addSubview:_label];
        [self addSubview:_activityIndicatorView];
        
        self.backgroundColor = ThemedColor(@"activityLabelBackgroundColor", ThemedColor(@"tableViewPlainBackgroundColor", [UIColor whiteColor]));
        // Swallow all touch events
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)layoutSubviews {
    const CGFloat spacing = 4;
    
    CGFloat totalWidth = _label.width + spacing + _activityIndicatorView.width;
    
    _activityIndicatorView.left = round((self.width / 2) - (totalWidth / 2));
    _activityIndicatorView.top = round((self.height / 2) - (_activityIndicatorView.height / 2));
                            
    _label.left = _activityIndicatorView.right + spacing;
    _label.top = round((self.height / 2) - (_label.height / 2));
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    // Take the size of our new parent.
    CGRect newFrame = newSuperview.frame;
    newFrame.origin.x = 0;
    newFrame.origin.y = 0;
    self.frame = newFrame;
 
    // Don't let our parent take our touch events.  E.g. This is helpful
    // when we're overlayed on top of a UITableView
    _parentHadUserInteractionEnabled = newSuperview.userInteractionEnabled;
    newSuperview.userInteractionEnabled = NO;
}

- (void)removeFromSuperview {
    self.superview.userInteractionEnabled = _parentHadUserInteractionEnabled;
    [super removeFromSuperview];
}

@end
