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

#import "VBXButtonCell.h"
#import "UIViewPositioningExtension.h"

@implementation VBXButtonCell

@synthesize buttonLabel = _buttonLabel;

- (id)initwithText:(NSString *)text reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        _buttonLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        _buttonLabel.text = text;
        _buttonLabel.font = [UIFont boldSystemFontOfSize:15.0];
        _buttonLabel.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:_buttonLabel];
        [self applyConfig];
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)layoutSubviews {
    CGSize size = self.contentView.frame.size;
    
    [_buttonLabel sizeToFit];
    _buttonLabel.left = round(size.width / 2 - _buttonLabel.width / 2);
    _buttonLabel.top = round(size.height / 2 - _buttonLabel.height / 2);
}

- (void)applyConfig {
    [super applyConfig];
    _buttonLabel.textColor = self.textLabel.textColor;
}

@end
