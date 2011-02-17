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

#import "VBXViewCell.h"
#import "UIViewPositioningExtension.h"

@implementation VBXViewCell

@synthesize view = _view;
@synthesize showBackground = _showBackground;
@synthesize contentInsets = _contentInsets;

- (id)initWithView:(UIView *)aView reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.view = aView;
        self.showBackground = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentInsets = UIEdgeInsetsZero;
    }
    return self;
}

- (void)setView:(UIView *)newView {
    if (_view != newView) {
        [_view removeFromSuperview];
        [_view release];
        _view = [newView retain];
        [self.contentView addSubview:_view];
        
        [self setNeedsLayout];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.view.left = _contentInsets.left;
    self.view.top = _contentInsets.top;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
}

- (void)setBackgroundView:(UIView *)backgroundView {
    if (_showBackground) {
        [super setBackgroundView:backgroundView];
    }    
}

- (void)dealloc {
    self.view = nil;
    [super dealloc];
}

- (CGFloat)heightForCell {
    return _view.height + _contentInsets.top + _contentInsets.bottom;
}

@end
