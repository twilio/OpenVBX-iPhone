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

#import <UIKit/UIKit.h>
#import "VBXTableViewCell.h"

@class VBXMessageSummary;
@class VBXAudioControl;
@class VBXStringPartLabel;
@class VBXMessageListController;
@class VBXMaskedImageView;

@interface VBXMessageListCell : VBXTableViewCell {
    VBXMessageListController *_messageListController;
    VBXMessageSummary *_messageSummary;
    
    UIView *_container;
    UILabel *_titleLabel;
    VBXStringPartLabel *_timestampLabel;
    UILabel *_bodyLabel;
    UILabel *_folderLabel;
    
    VBXMaskedImageView *_deliveryMethodView;
    
    UIView *_playerView;
    
    VBXAudioControl *_audioControl;
}

@property (nonatomic, retain) VBXMessageListController *messageListController;
@property (nonatomic, retain) VBXMessageSummary *messageSummary;
@property (nonatomic, retain) UIView *playerView;
@property (nonatomic, readonly) VBXAudioControl *audioControl;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

- (void)showMessageSummary:(VBXMessageSummary *)messageSummary showFolder:(BOOL)showFolder;

- (void)showPlayerView:(UIView *)playerView;
- (void)hidePlayerView;

@end

