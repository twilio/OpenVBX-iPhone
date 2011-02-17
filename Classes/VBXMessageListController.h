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

@class VBXAudioPlaybackController;
@class VBXMessageListAccessor;
@class VBXObjectBuilder;
@class VBXStringPartLabel;
@class VBXLoadMoreCell;

@interface VBXMessageListController : VBXStatefulTableViewController {
    NSUserDefaults *_userDefaults;
    VBXAudioPlaybackController *_playbackController;
    VBXMessageListAccessor *_accessor;    
    NSBundle *_bundle;
    VBXObjectBuilder *_builder;
    NSIndexPath *_selectedMessageIndexPath;
    NSString *_selectedMessageKey;
    NSString *_selectedMessageRecordingURL;
    NSIndexPath *_playbackControllerIndexPath;

    UIBarButtonItem *_refreshButton;
    UIBarButtonItem *_dialerButton;
    VBXLoadMoreCell *_loadMoreView;
    VBXStringPartLabel *_statusLabel;
    
    BOOL _selectedMessageWasArchivedFromDetailsPage;
}

@property (nonatomic, retain) NSUserDefaults *userDefaults;
@property (nonatomic, retain) VBXMessageListAccessor *accessor;
@property (nonatomic, retain) NSBundle *bundle;
@property (nonatomic, assign) VBXObjectBuilder *builder;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *refreshButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *dialerButton;

- (IBAction)loadMore;
- (IBAction)refresh;
- (IBAction)dialerPressed;

/**
 * Called by the MessageDetailController when we've archived a message
 * from the details page.
 */
- (void)didArchiveSelectedMessage;

- (NSDictionary *)saveState;
- (void)restoreState:(NSDictionary *)state;

@end
