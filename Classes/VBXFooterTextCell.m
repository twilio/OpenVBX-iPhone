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

#import "VBXFooterTextCell.h"
#import "UIViewPositioningExtension.h"

@implementation VBXFooterTextCell

@synthesize label = _label;
@synthesize contentInsets = _contentInsets;

- (id)initwithText:(NSString *)text reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        _contentInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        
        _label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        _label.text = text;
        _label.font = [UIFont systemFontOfSize:15.0];
        _label.numberOfLines = 0;
        _label.textAlignment = UITextAlignmentCenter;
        _label.shadowOffset = CGSizeMake(0, 1);
        _label.lineBreakMode = UILineBreakModeWordWrap;
        _label.backgroundColor = [UIColor clearColor];
        _label.width = 300;
        [_label sizeToFit];
        
        [self.contentView addSubview:_label];
        
        [self applyConfig];
        
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)setContentInsets:(UIEdgeInsets)insets {
    _contentInsets = insets;
    _label.width = 300 - (_contentInsets.left + _contentInsets.right);
    [_label sizeToFit];
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    _label.frame = CGRectMake(_contentInsets.left,
                              _contentInsets.top,
                              self.contentView.width - (_contentInsets.left + _contentInsets.right),
                              self.contentView.height - (_contentInsets.top + _contentInsets.bottom));
    
    [_label sizeToFit];

    [_label centerHorizontallyInView:self.contentView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    // This cell can never be selected
    [super setSelected:NO animated:animated];
}

- (void)setBackgroundView:(UIView *)view {
    // We don't ever want a background view.
}

- (CGFloat)heightForCell {
    self.height = 9999;
    [self setNeedsLayout];
    [self layoutIfNeeded];

    CGSize size = [_label.text sizeWithFont:[UIFont systemFontOfSize:15.0]
                          constrainedToSize:CGSizeMake(300 - (_contentInsets.left + _contentInsets.right), 9999)
                              lineBreakMode:UILineBreakModeWordWrap];
    
    return size.height + _contentInsets.top + _contentInsets.bottom;
}

- (void)applyConfig {
    [super applyConfig];
    
    _label.textColor = ThemedColor(@"tableViewFooterTextColor", RGBHEXCOLOR(0x4d576b));
    _label.shadowColor = ThemedColor(@"tableViewFooterTextShadowColor", RGBHEXCOLOR(0xf8f9fa));
}

@end

