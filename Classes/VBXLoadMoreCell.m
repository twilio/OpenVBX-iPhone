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

#import "VBXLoadMoreCell.h"
#import "UIViewPositioningExtension.h"

@implementation VBXLoadMoreCell

@synthesize titleLabel = _titleLabel;
@synthesize descriptionLabel = _descriptionLabel;
@synthesize spinner = _spinner;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        _titleLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        _titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
        _titleLabel.text = LocalizedString(@"Load more...", @"Load More Cell: Default text");
        _titleLabel.numberOfLines = 1;
        _titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
        _titleLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_titleLabel];
        
        _descriptionLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        _descriptionLabel.font = [UIFont systemFontOfSize:13.0];
        _descriptionLabel.text = @"";
        _descriptionLabel.numberOfLines = 1;
        _descriptionLabel.lineBreakMode = UILineBreakModeTailTruncation;
        _descriptionLabel.backgroundColor = [UIColor clearColor];        
        [self.contentView addSubview:_descriptionLabel];
        
        _spinner = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
        _spinner.hidesWhenStopped = YES;
        [self.contentView addSubview:_spinner];        
        
        self.accessoryType = UITableViewCellAccessoryNone;
        [self applyConfig];
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)applyConfig {
    [super applyConfig];
    
    if (self.isSelected || self.isHighlighted) {
        _titleLabel.textColor = ThemedColor(@"tableViewCellHighlightedTextColor", [UIColor whiteColor]);
        _descriptionLabel.textColor = ThemedColor(@"tableViewCellHighlightedTextColor", [UIColor whiteColor]);
    } else {
        _titleLabel.textColor = ThemedColor(@"loadMoreTitleTextColor", RGBHEXCOLOR(0x2470d8));
        _descriptionLabel.textColor = ThemedColor(@"loadMoreDescriptionTextColor", ThemedColor(@"secondaryTextColor", [UIColor grayColor]));
    }    
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    [self applyConfig];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [self applyConfig];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_titleLabel sizeToFit];
    [_descriptionLabel sizeToFit];
    
    CGFloat totalHeight = 0;
    
    if (_descriptionLabel.text.length == 0) {
        totalHeight = _titleLabel.height;
        _descriptionLabel.hidden = YES;
    } else {
        totalHeight = (_titleLabel.height + 3 + _descriptionLabel.height);
        _descriptionLabel.hidden = NO;        
    }
    
    _titleLabel.left = 35;
    _titleLabel.top = round((self.height / 2) - (totalHeight / 2));
    _titleLabel.width = (self.width - _titleLabel.left);

    if (!_descriptionLabel.hidden) {
        _descriptionLabel.left = _titleLabel.left;
        _descriptionLabel.top = _titleLabel.bottom + 3;
        _descriptionLabel.width = (self.width - _descriptionLabel.left);    
    }
    
    _spinner.right = _titleLabel.left - 5;
    _spinner.top = round((self.height / 2) - (_spinner.height / 2));
}

@end
