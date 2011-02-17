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

#import "VBXMessageListCell.h"
#import "VBXMessageSummary.h"
#import "UIViewPositioningExtension.h"
#import "VBXObjectBuilder.h"
#import "VBXAudioPlaybackController.h"
#import "VBXAudioControl.h"
#import "VBXStringPartLabel.h"
#import "VBXMessageListController.h"
#import "VBXMaskedImageView.h"


@implementation VBXMessageListCell

@synthesize messageListController = _messageListController;
@synthesize messageSummary = _messageSummary;
@synthesize playerView = _playerView;
@synthesize audioControl = _audioControl;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        _titleLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        _titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
        _titleLabel.numberOfLines = 1;
        _titleLabel.lineBreakMode = UILineBreakModeTailTruncation | UILineBreakModeWordWrap;
        [self.contentView addSubview:_titleLabel];
        
        _timestampLabel = [[[VBXStringPartLabel alloc] initWithFrame:CGRectZero] autorelease];
        _timestampLabel.textAlignment = UITextAlignmentRight;
        [self.contentView addSubview:_timestampLabel];
                
        _bodyLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        _bodyLabel.font = [UIFont systemFontOfSize:13.0];
        _bodyLabel.numberOfLines = 2;
        _bodyLabel.lineBreakMode = UILineBreakModeTailTruncation | UILineBreakModeWordWrap;
        _bodyLabel.contentMode = UIViewContentModeBottomLeft;
        [self.contentView addSubview:_bodyLabel];
        
        _folderLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        _folderLabel.numberOfLines = 1;
        _folderLabel.text = @"FOLDER";
        _folderLabel.font = [UIFont boldSystemFontOfSize:12.0];
        [self.contentView addSubview:_folderLabel];
                
        _audioControl = [[[VBXAudioControl alloc] init] autorelease];
        [self.contentView addSubview:_audioControl];
        
        _deliveryMethodView = [[[VBXMaskedImageView alloc] initWithImage:[UIImage imageNamed:@"delivery-phone-icon.png"]] autorelease];
        [self.contentView addSubview:_deliveryMethodView];
                
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;        
        [self applyConfig];
    }
    return self;
}

- (void)dealloc {
    self.messageListController = nil;
    self.messageSummary = nil;
    [super dealloc];
}

- (void)adjustForSelectionOrHighlight {
    if (self.isSelected || self.isHighlighted) {
        UIColor *highlightedTextColor = ThemedColor(@"tableViewCellHighlightedTextColor", [UIColor whiteColor]);
        _timestampLabel.textColor = highlightedTextColor;
    } else {
        _timestampLabel.textColor = ThemedColor(@"messageListTimestampTextColor", RGBHEXCOLOR(0x2470d8));
    }    
}

- (void)applyConfig {
    [super applyConfig];
    
    UIColor *backgroundColor = nil;

    if (_messageSummary != nil && _messageSummary.unread) {
        backgroundColor = ThemedColor(@"messageListUnreadBackgroundColor", ThemedColor(@"tableViewCellBackgroundColor", [UIColor whiteColor]));
    } else {
        backgroundColor = ThemedColor(@"messageListReadBackgroundColor", RGBHEXCOLOR(0xf3f6fc));        
    }
    
    UIView *bgView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    bgView.backgroundColor = backgroundColor;
    [self setBackgroundView:bgView];
    
    UIColor *highlightedTextColor = ThemedColor(@"tableViewCellHighlightedTextColor", [UIColor whiteColor]);
    _titleLabel.highlightedTextColor = highlightedTextColor;
    _bodyLabel.highlightedTextColor = highlightedTextColor;
    _folderLabel.highlightedTextColor = highlightedTextColor;
    
    _titleLabel.textColor = ThemedColor(@"messageListCallerTextColor", ThemedColor(@"primaryTextColor", [UIColor blackColor]));
    _timestampLabel.textColor = ThemedColor(@"messageListTimestampTextColor", RGBHEXCOLOR(0x2470d8));
    _bodyLabel.textColor = ThemedColor(@"messageListBodyTextColor", ThemedColor(@"tertiaryTextColor", [UIColor grayColor]));
    _folderLabel.textColor = ThemedColor(@"messageListFolderTextColor", ThemedColor(@"secondaryTextColor", [UIColor darkGrayColor]));

    _titleLabel.opaque = YES;
    _bodyLabel.opaque = YES;
    _folderLabel.opaque = YES;
    _audioControl.opaque = YES;
    _deliveryMethodView.opaque = YES;
    _timestampLabel.opaque = YES;
    _audioControl.backgroundColor = backgroundColor;
    _titleLabel.backgroundColor = backgroundColor;
    _bodyLabel.backgroundColor = backgroundColor;
    _folderLabel.backgroundColor = backgroundColor;
    _deliveryMethodView.backgroundColor = backgroundColor;
    _timestampLabel.backgroundColor = backgroundColor;

    _deliveryMethodView.startColor = ThemedColor(@"messageListTypeIconColor", [UIColor lightGrayColor]);
    _deliveryMethodView.endColor = ThemedColor(@"messageListTypeIconColor", [UIColor lightGrayColor]);
    
    [self adjustForSelectionOrHighlight];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    [self adjustForSelectionOrHighlight];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];    
    [self adjustForSelectionOrHighlight];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    if (self.editing && !editing) {
        // When the user originally clicked edit, the play button disappeared
        // and the edit button faded in.  Now we do the reverse.  The edit button
        // fades away and the play button fades in.
        _audioControl.alpha = 0;
        
        [UIView beginAnimations:@"FadeInPlayButton" context:nil];
        [UIView setAnimationDuration:0.6];

        _audioControl.alpha = 1.0;
        
        [UIView commitAnimations];
    }
    
    [super setEditing:editing animated:animated];
}

- (void)layoutSubviews {
    [super layoutSubviews];
        
    const NSInteger accessoryLeftX = self.contentView.width - 20;
    const NSInteger padding = 5;
    const NSInteger messageStartX = (_messageListController.editing ? 5 : 37);    
    
    _timestampLabel.width = 100;
    _timestampLabel.right = accessoryLeftX - padding;
    _timestampLabel.height = 20;
    
    _titleLabel.left = messageStartX; 
    _titleLabel.top = padding;
    _titleLabel.height = 20;
    
    _folderLabel.left = messageStartX;
    _folderLabel.top = _titleLabel.bottom + 1;
    _folderLabel.height = 15;
    _folderLabel.width = _timestampLabel.right - messageStartX;
    
    if (_folderLabel.text == nil) {
        _folderLabel.height = 0;
    }

    _titleLabel.width = 115;

    _deliveryMethodView.left = _titleLabel.right;
    _deliveryMethodView.bottom = _titleLabel.bottom + -2;

    _timestampLabel.bottom = _titleLabel.bottom;
    
    _bodyLabel.left = messageStartX;
    _bodyLabel.top = _folderLabel.bottom;
    _bodyLabel.width = _timestampLabel.right - messageStartX;    
    _bodyLabel.height = self.contentView.height - padding - _bodyLabel.top;
    _bodyLabel.height = [_bodyLabel.text sizeWithFont:_bodyLabel.font 
                                    constrainedToSize:_bodyLabel.frame.size 
                                        lineBreakMode:_bodyLabel.lineBreakMode].height;
    
    if (self.editing || _messageSummary.isSms) {
        _audioControl.hidden = YES;
    } else {
        _audioControl.hidden = NO;
        _audioControl.left = round((messageStartX / 2) - (_audioControl.width / 2));
        _audioControl.top = round((self.contentView.height / 2) - (_audioControl.height / 2));        
    }
    
    if (_playerView != nil) {
        _playerView.left = _bodyLabel.left;
        _playerView.top = _bodyLabel.top + 5;
        _playerView.width = _timestampLabel.right - messageStartX;
        _playerView.height = self.contentView.height - padding - _bodyLabel.top;
        
        _bodyLabel.hidden = YES;        
    } else {
        _bodyLabel.hidden = NO;
    }
    

}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.playerView removeFromSuperview];
    self.playerView = nil;
}

- (void)showMessageSummary:(VBXMessageSummary *)messageSummary showFolder:(BOOL)showFolder {
    self.messageSummary = messageSummary;
        
    _titleLabel.text = messageSummary.caller;
    
    if (showFolder) {
        _folderLabel.text = [messageSummary.folder uppercaseString];
    } else {
        _folderLabel.text = nil;
    }

    if (messageSummary.shortSummary == nil || messageSummary.shortSummary.length == 0) {
        _bodyLabel.text = @"No transcription available.";
        _bodyLabel.font = [UIFont italicSystemFontOfSize:_bodyLabel.font.pointSize];
    } else {
        _bodyLabel.text = messageSummary.shortSummary;
        _bodyLabel.font = [UIFont systemFontOfSize:_bodyLabel.font.pointSize];        
    }

    NSString *timeString = messageSummary.relativeReceivedTime;
    
    if ([timeString hasSuffix:@"PM"] || [timeString hasSuffix:@"AM"]) {
        NSString *base = [timeString substringToIndex:(timeString.length - 2)];        
        NSString *suffix = [timeString substringFromIndex:(timeString.length - 2)];

        _timestampLabel.parts = [NSArray arrayWithObjects:
                                [VBXStringPart partWithText:base font:[UIFont boldSystemFontOfSize:14]],
                                [VBXStringPart partWithText:suffix font:[UIFont systemFontOfSize:12]],
                                nil];
    } else {
        _timestampLabel.parts = [NSArray arrayWithObject:[VBXStringPart partWithText:timeString font:[UIFont systemFontOfSize:14]]];
    }
    
    if (messageSummary.isSms) {        
        _deliveryMethodView.image = [UIImage imageNamed:@"delivery-sms-icon.png"];
    } else {
        _deliveryMethodView.image = [UIImage imageNamed:@"delivery-phone-icon.png"];
    }
    [_deliveryMethodView sizeToFit];
    [_deliveryMethodView setNeedsDisplay];


    if (messageSummary.isSms) {
        // It's an SMS
        _audioControl.hidden = YES;
    } else {
        // It's a voicemail
        _audioControl.hidden = NO;
        
        [_audioControl showPlayButton];
    }    

    [_playerView removeFromSuperview];
    self.playerView = nil;
    
    [self applyConfig];
    [self setNeedsLayout];
}

- (void)showPlayerView:(UIView *)playerView {
    self.playerView = playerView;
    [self.contentView addSubview:self.playerView];
    [self setNeedsLayout];
}

- (void)hidePlayerView {
    [self.playerView removeFromSuperview];
    self.playerView = nil;
    [self setNeedsLayout];
}

@end
