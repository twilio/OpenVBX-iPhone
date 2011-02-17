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

#import "VBXTextFieldCell.h"
#import "UIViewPositioningExtension.h"

@implementation VBXTextFieldCell

@synthesize label = _label;
@synthesize textField = _textField;
@synthesize helpLabel = _helpLabel;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifer {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifer]) {
        _label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        _label.backgroundColor = [UIColor clearColor];
        _label.text = @"";
        _label.font = [UIFont boldSystemFontOfSize:17.0];
        _label.numberOfLines = 1;
        _label.lineBreakMode = UILineBreakModeTailTruncation;
        
        _helpLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        _helpLabel.backgroundColor = [UIColor clearColor];
        _helpLabel.textColor = [UIColor grayColor];
        _helpLabel.text = @"";
        _helpLabel.font = [UIFont italicSystemFontOfSize:13.0];
        _helpLabel.numberOfLines = 1;
        _helpLabel.lineBreakMode = UILineBreakModeTailTruncation;
        
        _textField = [[[UITextField alloc] initWithFrame:CGRectZero] autorelease];
        _textField.font = [UIFont systemFontOfSize:17.0];
        _textField.textAlignment = UITextAlignmentLeft;
        _textField.borderStyle = UITextBorderStyleNone;
        _textField.text = @"";
        
        [self.contentView addSubview:_label];
        [self.contentView addSubview:_textField];
        [self.contentView addSubview:_helpLabel];
        
        [self applyConfig];
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)applyConfig {
    [super applyConfig];
    
    _label.textColor = ThemedColor(@"tableViewCellTitleColor", [UIColor blackColor]);
    _textField.textColor = ThemedColor(@"tableViewCellValueColor", RGBHEXCOLOR(0x385487));
}

- (void)layoutSubviews {
    if (_helpLabel.text.length > 0) {
        _helpLabel.hidden = NO;
        [_helpLabel sizeToFit];

        _helpLabel.left = 20;
        _helpLabel.top = 52;
        
    } else {
        _helpLabel.hidden = YES;
    }
    
    if (_label.text.length > 0) {
        _label.hidden = NO;
        [_label sizeToFit];
        
        _label.left = 20;
        _label.top = 12;
        
        [_textField sizeToFit];
        _textField.left = MAX(110, _label.right + 10);
        _textField.top = 12;
        _textField.width = self.contentView.width - 10 - 10 - _textField.left;
        _textField.height = 21;
    } else {
        _label.hidden = YES;
        [_textField sizeToFit];

        _textField.left = 20;
        _textField.top = 12;
        _textField.width = self.contentView.width - 40;
        _textField.height = 21;        
    }    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    // We don't drop a selected background.
    if (selected) {
        [_textField becomeFirstResponder];
    }
    
    [super setSelected:NO animated:animated];
}

@end

