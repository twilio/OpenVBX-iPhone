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

#import "VBXTableStatusView.h"
#import "UIViewPositioningExtension.h"
#import "VBXConfiguration.h"

@implementation VBXTableStatusView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _imageView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)] autorelease];
        [self addSubview:_imageView];
         
        _titleLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 30)] autorelease];
        _titleLabel.font = [UIFont boldSystemFontOfSize:19.0];
        _titleLabel.textColor = ThemedColor(@"tableStatusTitleTextColor", ThemedColor(@"secondaryTextColor", [UIColor darkGrayColor]));
        _titleLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
        _titleLabel.numberOfLines = 1;
        _titleLabel.text = @"Title";
        _titleLabel.textAlignment = UITextAlignmentCenter;
        _titleLabel.backgroundColor = [UIColor clearColor];

        [self addSubview:_titleLabel];
        
        _descriptionLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 40)] autorelease];
        _descriptionLabel.font = [UIFont systemFontOfSize:14.0];
        _descriptionLabel.textColor = ThemedColor(@"tableStatusDescriptionTextColor", ThemedColor(@"tertiaryTextColor", [UIColor grayColor]));
        _descriptionLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
        _descriptionLabel.numberOfLines = 2;
        _descriptionLabel.text = @"You should explain what went wrong here.";
        _descriptionLabel.textAlignment = UITextAlignmentCenter;
        _descriptionLabel.backgroundColor = [UIColor clearColor];        
        [self addSubview:_descriptionLabel];

        self.backgroundColor = ThemedColor(@"tableStatusBackgroundColor",  ThemedColor(@"tableViewPlainBackgroundColor", [UIColor whiteColor]));
        
        _imageView.hidden = YES;
        _titleLabel.hidden = YES;
        _descriptionLabel.hidden = YES;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _imageView.top = 30;
    [_imageView centerHorizontallyInView:self];
    
    _titleLabel.top = _imageView.bottom + 20;
    [_titleLabel centerHorizontallyInView:self];
    
    _descriptionLabel.top = _titleLabel.bottom + 10;
    [_descriptionLabel centerHorizontallyInView:self];    
}

- (void)setImage:(UIImage *)image {
    _imageView.image = image;    
    _imageView.hidden = (image == nil);
}

- (void)setTitle:(NSString *)title {
    _titleLabel.text = title;
    _titleLabel.hidden = (title == nil || title.length == 0);
}

- (void)setDescription:(NSString *)description {
    _descriptionLabel.text = description;
    _descriptionLabel.hidden = (description == nil || description.length == 0);
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    // Take the size of our new parent.
    CGRect newFrame = newSuperview.frame;
    newFrame.origin.x = 0;
    newFrame.origin.y = 0;
    self.frame = newFrame;
    [self setNeedsLayout];
    
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
