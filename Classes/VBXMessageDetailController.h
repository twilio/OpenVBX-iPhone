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
#import "VBXStatefulTableViewController.h"

@class VBXMessageDetailAccessor;
@class VBXDialerAccessor;
@class VBXAudioPlaybackController;
@class VBXObjectBuilder;
@class VBXSectionedCellDataSource;
@class VBXAudioControl;
@class VBXStringPartLabel;
@class VBXMessageListController;
@class VBXLoadMoreCell;

@interface VBXMessageDetailController : VBXStatefulTableViewController <UITableViewDelegate> {
    NSUserDefaults *_userDefaults;
    VBXMessageDetailAccessor *_accessor;
    VBXDialerAccessor *_dialerAccessor;
    VBXAudioPlaybackController *_playbackController;
    VBXMessageListController *_messageListController;
    VBXObjectBuilder *_builder;
    NSBundle *_bundle;
    NSString *_newNoteText;
    
    VBXSectionedCellDataSource *_dataSource;
    UIView *_loadingView;
    VBXStringPartLabel *_messageView;
    
    UIView *_headerView;
    UILabel *_callerLabel;
    UILabel *_destinationLabel;
    UILabel *_timeLabel;
    UIView *_audioControlsFrame;
    VBXAudioControl *_audioControl;
    UIButton *_actionButton;
    UIWebView *_webView;

    UITableViewCell *_addNoteCell;
    VBXLoadMoreCell *_loadMoreCell;

    UIBarButtonItem *_refreshButton;
    UIBarButtonItem *_replyButton;
    UIBarButtonItem *_dialerButton;
    UIBarButtonItem *_deleteButton;
        
    NSString *_phoneNumberClickedInMessage;
}

@property (nonatomic, retain) NSUserDefaults *userDefaults;
@property (nonatomic, retain) VBXMessageDetailAccessor *accessor;
@property (nonatomic, retain) VBXDialerAccessor *dialerAccessor;
@property (nonatomic, retain) VBXAudioPlaybackController *playbackController;
@property (nonatomic, retain) VBXMessageListController *messageListController;
@property (nonatomic, assign) VBXObjectBuilder *builder;
@property (nonatomic, retain) NSBundle *bundle;


@property (nonatomic, retain) IBOutlet UIView *headerView;
@property (nonatomic, retain) IBOutlet UILabel *callerLabel;
@property (nonatomic, retain) IBOutlet UILabel *destinationLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeLabel;
@property (nonatomic, retain) IBOutlet UIView *audioControlsFrame;

@property (nonatomic, retain) IBOutlet UITableViewCell *loadMoreCell;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *refreshButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *replyButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *dialerButton;

- (IBAction)refresh;
- (IBAction)loadMoreAnnotations;
- (IBAction)reply;

- (NSDictionary *)saveState;
- (void)restoreState:(NSDictionary *)state;

@end
