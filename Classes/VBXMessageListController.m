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

#import "VBXMessageListController.h"
#import "VBXNavigationController.h"
#import "VBXAudioPlaybackController.h"
#import "VBXMessageDetailController.h"
#import "VBXDialerController.h"
#import "VBXFolderDetail.h"
#import "VBXSublist.h"
#import "VBXMessageSummary.h"
#import "VBXMessageListAccessor.h"
#import "VBXObjectBuilder.h"
#import "UIExtensions.h"
#import "NSExtensions.h"
#import "VBXMessageListCell.h"
#import "VBXTableView.h"
#import "VBXAudioControl.h"
#import "VBXStringPartLabel.h"
#import "VBXUserDefaultsKeys.h"
#import "UIViewPositioningExtension.h"
#import "NSExtensions.h"
#import "VBXGlobal.h"
#import "VBXMessageListAccessor.h"
#import "VBXConfiguration.h"
#import "VBXTableViewCell.h"
#import "VBXLoadMoreCell.h"

@interface VBXMessageListController () <VBXMessageListAccessorDelegate, VBXAudioControlDelegate, VBXAudioPlaybackControllerDelegate>

@property (nonatomic, retain) VBXAudioPlaybackController *playbackController;
@property (nonatomic, retain) NSIndexPath *selectedMessageIndexPath;
@property (nonatomic, retain) NSString *selectedMessageKey;
@property (nonatomic, retain) NSString *selectedMessageRecordingURL;
@property (nonatomic, retain) NSIndexPath *playbackControllerIndexPath;

@end


@implementation VBXMessageListController

@synthesize userDefaults = _userDefaults;
@synthesize playbackController = _playbackController;
@synthesize accessor = _accessor;;
@synthesize bundle = _bundle;
@synthesize builder = _builder;
@synthesize selectedMessageIndexPath = _selectedMessageIndexPath;
@synthesize selectedMessageKey = _selectedMessageKey;
@synthesize selectedMessageRecordingURL = _selectedMessageRecordingURL;
@synthesize playbackControllerIndexPath = _playbackControllerIndexPath;

@synthesize refreshButton = _refreshButton;
@synthesize dialerButton = _dialerButton;

- (void)dealloc {
    [_loadMoreView release];
    
    self.playbackController = nil;
    self.accessor = nil;
    self.bundle = nil;
    self.selectedMessageKey = nil;
    self.selectedMessageRecordingURL = nil;

    self.refreshButton = nil;
    self.dialerButton = nil;
    
    [super dealloc];
}

- (BOOL)shouldDisplayFolderNameInListItem {
    return [_accessor.model.name isEqualToString:@"Inbox"];
}

- (void)updateControlsWithStatusMessage:(NSString *)message {
    _refreshButton.enabled = YES;
    
    _statusLabel.parts = [NSArray arrayWithObjects:
                         [VBXStringPart partWithText:message font:[UIFont systemFontOfSize:13]],
                         nil];    
}

- (void)updateControls {
    [self updateControlsWithStatusMessage:nil];
}

- (void)showLoadingState {
    [super showLoadingState];
        
    _refreshButton.enabled = NO;
    _statusLabel.parts = [NSMutableArray array];    
}

- (void)showErrorState {
    [super showErrorState];
    _refreshButton.enabled = YES;
}

- (void)showEmptyState {
    [super showEmptyState];
    _refreshButton.enabled = YES;
}

- (void)showLoadedState {
    [super showLoadedState];
    
    if ([self shouldDisplayFolderNameInListItem]) {
        self.tableView.rowHeight = 80;
    } else {
        self.tableView.rowHeight = 68;
    }    
    
    if (_accessor.model.messages.items.count < _accessor.model.messages.total) {
        _loadMoreView.titleLabel.text = LocalizedString(@"Load more messages...", @"Message List: Title of the Load More table cell");
        _loadMoreView.titleLabel.textColor = RGBHEXCOLOR(0x2470d8);
        _loadMoreView.descriptionLabel.text = [NSString stringWithFormat:LocalizedString(@"Showing %d of %d messages.", @"Message List: The second line of the Load More table cell"), _accessor.model.messages.items.count, _accessor.model.messages.total];
        [_loadMoreView.spinner stopAnimating];
    }
    
    [self updateControls];
       
    NSDate *lastUpdatedDate = [_accessor timestampOfCachedData];
    _statusLabel.parts = VBXStringPartsForUpdatedAtDate(lastUpdatedDate);    
}
- (void)showRefreshingState {
    [super showRefreshingState];

    _refreshButton.enabled = NO;
    _statusLabel.parts = [NSArray arrayWithObjects:
                         [VBXStringPart partWithText:LocalizedString(@"Updating...", @"Message List: Shows on the toolbar when refreshing the list of messages.") font:[UIFont boldSystemFontOfSize:13]],
                         nil];    
}

- (void)viewDidLoad {
    _statusLabel = [[[VBXStringPartLabel alloc] initWithFrame:CGRectMake(0, 0, 200, 18)] autorelease];
    _statusLabel.textAlignment = UITextAlignmentCenter;
    _statusLabel.textColor = [UIColor whiteColor];
    _statusLabel.shadowColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.8];
    _statusLabel.shadowOffset = CGSizeMake(0, -1);
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.toolbarItems = [NSArray arrayWithObjects:
                         _refreshButton, 
                         [UIBarButtonItem flexibleSpace],
        [UIBarButtonItem itemWithCustomView:_statusLabel], [UIBarButtonItem flexibleSpace], _dialerButton, nil];    
    
    _loadMoreView = [[VBXLoadMoreCell alloc] initWithReuseIdentifier:nil];
    
    _accessor.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_accessor.model) {
        [self showLoadedState];
    } else {
        [self showLoadingState];
        [_accessor loadUsingCache:YES];
    }
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    if (_selectedMessageWasArchivedFromDetailsPage) {
        _selectedMessageWasArchivedFromDetailsPage = NO;

        [_accessor removeMessageFromModelAtIndex:self.selectedMessageIndexPath.row + _accessor.model.messages.offset];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [_playbackController stop];
    [super viewWillDisappear:animated];
}

- (IBAction)loadMore {
    _loadMoreView.titleLabel.text = LocalizedString(@"Loading...", @"Message List: Text for full screen loading indicator, when there is no cache.");
    _loadMoreView.titleLabel.textColor = [UIColor darkGrayColor];
    [_loadMoreView.spinner startAnimating];
        
    [_accessor loadMore];
}

- (IBAction)refresh {
    
    if (_accessor.model.messages.total == 0) {
        [self showLoadingState];
    } else {
        [self showRefreshingState];
    }
    
    [_accessor loadUsingCache:NO];
    [_playbackController refresh];
}

- (IBAction)dialerPressed {
    [(VBXNavigationController *)self.navigationController showDialOrTextActionSheet];
}

- (void)showRefreshingAfterDelay {
    [self showRefreshingState];
}

- (void)accessorDidLoadData:(VBXMessageListAccessor *)accessor fromCache:(BOOL)fromCache {
    
    // If we're loading from cache, some messages may have been marked read since the
    // last time we fetched the authoritative copy from the server, so we always check
    // against the list of messages read since the last load.
    NSString *defaultKey = [NSString stringWithFormat:@"%@-%@", VBXUserDefaultsMessageKeysReadSinceLastLoad, accessor.folderKey];
    if (fromCache) {
        NSDictionary *dictionary = [[NSUserDefaults standardUserDefaults] dictionaryForKey:defaultKey];
        
        if (dictionary != nil) {
            for (VBXMessageSummary *message in accessor.model.messages.items) {
                if ([dictionary objectForKey:message.key] != nil) {
                    message.unread = NO;
                }
            }
        }
    } else {
        // When we load from the network, we can clear our local list of all read messages
        // since the server has the most up-to-date unread/read values.
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSDictionary dictionary] forKey:defaultKey];
        [defaults synchronize];
    }

    if (!fromCache) {
        // If this hits, then we've already loaded a fresh copy from the network and we don't need
        // to show the "Refreshing..." thing.
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showRefreshingAfterDelay) object:nil];
    }
    
    if (self.accessor.model.messages.total > 0) {
        [self showLoadedState];
    } else {
        [self showEmptyState];
    }
    
    if (fromCache) {
        // We don't show this immediately because we want the user to have a chance to see
        // the timestamp for the cached data.
        [self performSelector:@selector(showRefreshingAfterDelay) withObject:nil afterDelay:1.0];
    }

    [self.tableView reloadData];
}

- (void)accessor:(VBXMessageListAccessor *)a loadDidFailWithError:(NSError *)error {
    debug(@"%@", [error detailedDescription]);
    
    [self showErrorState];
    
    if ([error isTwilioErrorWithCode:VBXErrorNoNetwork] && _accessor.model) {
        // We failed to load for lack of a network connection, but we have data already from cache. Don't bug the user with a popup.
        [self updateControlsWithStatusMessage:LocalizedString(@"No network; loaded data from cache", @"Folder List: Message shown when failed to update but there is data in the cache.")];
        return;
    } else if ([error isTwilioErrorWithCode:VBXErrorLoginRequired]) {
        return;
    }

    [self updateControlsWithStatusMessage:LocalizedString(@"Error", @"Message List: Message shown in footer when there's an error loading the messages.")];
    [UIAlertView showAlertViewWithTitle:LocalizedString(@"Could not load messages.", @"Message List: Title for alert when cannot load messages and there is no cache.") forError:error];    
}

#pragma mark Table view methods

- (VBXMessageSummary *)summaryForIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = indexPath.row + _accessor.model.messages.offset;
    return [_accessor.model.messages objectAtIndex:index];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (_accessor.model.messages.hasMore ? 1 : 0) + _accessor.model.messages.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger numberOfRows = [tableView numberOfRowsInSection:indexPath.section];
    
    if (_accessor.model.messages.hasMore && ((indexPath.row + 1) == numberOfRows)) {
        // If there are more messages to load and it's the last row, then it wants the load more cell
        return _loadMoreView;
    } else {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
}

- (NSString *)cellIdentifier {
    return @"MessageListCell";
}

- (UITableViewCell *)cellWithReuseIdentifier:(NSString *)identifier {
    VBXMessageListCell *cell = [[[VBXMessageListCell alloc] initWithReuseIdentifier:identifier] autorelease];
    cell.messageListController = self;
    cell.audioControl.delegate = self;
    cell.audioControl.context = cell;
    return cell;
}

- (void)configureCell:(VBXMessageListCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    VBXMessageSummary *summary = [self summaryForIndexPath:indexPath];

    [cell showMessageSummary:summary showFolder:[self shouldDisplayFolderNameInListItem]];
        
    // This message was already playing, had been scrolled off screen, and has now
    // come back into view
    if ([indexPath isEqual:_playbackControllerIndexPath]) {
        [cell showPlayerView:_playbackController.view];
        [cell.audioControl showStopButton];
    }

    if (summary.archiving) {
        UIActivityIndicatorView *cellSpinny = [[[UIActivityIndicatorView alloc]
                                                initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
        [cellSpinny startAnimating];
        cell.accessoryView = cellSpinny;
    } else {
        cell.accessoryView = nil;
    }
}

- (void)toggleMediaRoute {
    if (self.navigationItem.rightBarButtonItem.style == UIBarButtonItemStyleBordered) {
        [_playbackController setOutputToSpeaker];
        self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStyleDone;
    } else {
        [_playbackController setOutputToEarpiece];
        self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStyleBordered;
    }
}

- (void)setupSpeakerToggleButton {
    UIBarButtonItemStyle style = 0;
    
    if ([_userDefaults boolForKey:VBXUserDefaultsSpeakerMode]) {
        style = UIBarButtonItemStyleDone;
    } else {
        style = UIBarButtonItemStyleBordered;
    }
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:LocalizedString(@"Speaker", @"Message List: Button to change to speaker mode.")
                                                                               style:style
                                                                              target:self
                                                                              action:@selector(toggleMediaRoute)] autorelease];    
}

- (void)showPlayerForIndexPath:(NSIndexPath *)indexPath {        
    VBXMessageListCell *cell = (VBXMessageListCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    VBXMessageSummary *summary = [self summaryForIndexPath:indexPath];
    self.playbackController = [_builder audioPlaybackControllerForURL:summary.recordingURL];
    self.playbackController.playbackDelegate = self;
    self.playbackControllerIndexPath = indexPath;    
        
    [cell showPlayerView:_playbackController.view];
    [_playbackController viewWillAppear:NO];    
    [_playbackController viewDidAppear:NO];
    
    [_playbackController play];
    
    [self setupSpeakerToggleButton];
}

- (void)hidePlayerForIndexPath:(NSIndexPath *)indexPath {
    if (_playbackController != nil) {
        [_playbackController stop];
        self.playbackController = nil;
        self.playbackControllerIndexPath = nil;

        VBXMessageListCell *cell = (VBXMessageListCell *) [self.tableView cellForRowAtIndexPath:indexPath];
        [cell hidePlayerView];
        [cell.audioControl showPlayButton];
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
    }
}

- (void)playbackDidPlayOrResume:(VBXAudioPlaybackController *)controller {
    VBXMessageListCell *cell = (VBXMessageListCell *)[self.tableView cellForRowAtIndexPath:self.playbackControllerIndexPath];
    [cell.audioControl showStopButton];
}

- (void)playbackDidPauseOrFinish:(VBXAudioPlaybackController *)controller {
    VBXMessageListCell *cell = (VBXMessageListCell *)[self.tableView cellForRowAtIndexPath:self.playbackControllerIndexPath];
    [cell.audioControl showPlayButton];

    [self hidePlayerForIndexPath:self.playbackControllerIndexPath];
}

- (void)audioControlDidPressControl:(VBXAudioControl *)audioControl {
    VBXMessageListCell *cell = (VBXMessageListCell *)audioControl.context;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    if ([indexPath isEqual:self.playbackControllerIndexPath]) {
        
        if (self.playbackController.isPaused || !self.playbackController.isPlaying) {
            // They pressed play after having paused
            [self.playbackController play];
            [cell.audioControl showStopButton];
        } else {
            // They pressed pause
            [self.playbackController stop];
            [self hidePlayerForIndexPath:indexPath];
        }

    } else {
        // They chose to play a new message
        if (_playbackController != nil) {
            [self hidePlayerForIndexPath:self.playbackControllerIndexPath];
        }
        
        [self showPlayerForIndexPath:indexPath];
    }    
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];    
    [self.tableView setEditing:editing animated:animated];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_accessor.model.messages.hasMore && ((indexPath.row + 1) == [tableView numberOfRowsInSection:indexPath.section])) {
        return NO;
    } else if ([_playbackControllerIndexPath isEqual:indexPath]) {
        // When the player is up, the user will want to move the slider around without
        // having it be mistaken for a swipe.
        return NO;
    } else {
        return YES;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return LocalizedString(@"Archive", @"Message List: Label shown on the archive message button you see after you swipe.");
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_playbackControllerIndexPath != nil) {
        [self hidePlayerForIndexPath:indexPath];
    }
    
    if ([tableView cellForRowAtIndexPath:indexPath] == _loadMoreView) {
        [self loadMore];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else {
        VBXMessageSummary *summary = [self summaryForIndexPath:indexPath];
        
        // Make the message appear 'read' the next time the list is shown.
        summary.unread = NO;
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        
        // Mark the message as read in our local cache of all messages read since the last load.
        NSString *defaultKey = [NSString stringWithFormat:@"%@-%@", VBXUserDefaultsMessageKeysReadSinceLastLoad, self.accessor.folderKey];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *currentDictionary = [[NSUserDefaults standardUserDefaults] dictionaryForKey:defaultKey];
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        
        if (currentDictionary != nil) {
            [dictionary addEntriesFromDictionary:currentDictionary];
        }
        
        [dictionary setObject:@"" forKey:summary.key];
        
        [defaults setObject:dictionary forKey:defaultKey];
        [defaults synchronize];
        
        
        self.selectedMessageIndexPath = indexPath;
        self.selectedMessageKey = summary.key;
        self.selectedMessageRecordingURL = summary.recordingURL;
        VBXMessageDetailController *controller = [_builder messageDetailControllerForKey:_selectedMessageKey 
                                                                          contentURL:_selectedMessageRecordingURL
                                                                messageListController:self];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    //debug(@"%@, style=%d", indexPath, editingStyle);
    NSInteger index = indexPath.row + _accessor.model.messages.offset;
    [_accessor archiveMessageAtIndex:index];
    [self.tableView reloadData];
}

- (void)accessor:(VBXMessageListAccessor *)a didArchiveMessageAtIndex:(NSInteger)index {
    index -= _accessor.model.messages.offset;
    NSArray *indexPaths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]];
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationLeft];
    [self updateControls];
    
    if (a.model.messages.total == 0) {
        [self showEmptyState];
    }
}

- (void)accessor:(VBXMessageListAccessor *)accessor archiveDidFailWithError:(NSError *)error {
    debug(@"%@", [error detailedDescription]);
    [UIAlertView showAlertViewWithTitle:LocalizedString(@"Error", nil) forError:error];
    [self.tableView reloadData];
}

- (void)didArchiveSelectedMessage {
    _selectedMessageWasArchivedFromDetailsPage = YES;
}

#pragma mark State save and restore

- (NSDictionary *)saveState {
    NSMutableDictionary *state = [NSMutableDictionary dictionary];
    [state setObject:self.navigationItem.title forKey:@"navigationItem.title"];
    if ([self.navigationController topViewController] != self) {
        [state setObject:_selectedMessageKey forKey:@"selectedMessageKey"];
        [state setObject:_selectedMessageRecordingURL forKey:@"selectedMessageRecordingURL"];
    } else {
        VBXNavigationController *navController = (VBXNavigationController *)self.navigationController;
        
        [state setBool:navController.dialerIsShown forKey:@"dialerIsShown"];
        [state setBool:navController.sendTextIsShown forKey:@"sendTextIsShown"];
        
        if (navController.dialerIsShown) {
            [state setObject:[navController.dialerController saveState] forKey:@"dialerState"];
        } else if (navController.sendTextIsShown) {
            [state setObject:[navController.sendTextController saveState] forKey:@"sendTextState"];
        }
    }
    
    return state;
}

- (void)restoreState:(NSDictionary *)state {
    if (!state) return;
    self.navigationItem.title = [state stringForKey:@"navigationItem.title"];
    self.selectedMessageKey = [state stringForKey:@"selectedMessageKey"];
    self.selectedMessageRecordingURL = [state stringForKey:@"selectedMessageRecordingURL"];
    if (_selectedMessageKey) {
        VBXMessageDetailController *controller = [_builder messageDetailControllerForKey:_selectedMessageKey 
                                                                              contentURL:_selectedMessageRecordingURL 
                                                                   messageListController:self];
        [self.navigationController pushViewController:controller animated:NO];
    }
    
    if ([state boolForKey:@"dialerIsShown"]) {
        VBXNavigationController *navController = (VBXNavigationController *)self.navigationController;
        [navController showDialerWithState:[state objectForKey:@"dialerState"] animated:NO];
    } else if ([state boolForKey:@"sendTextIsShown"]) {
        VBXNavigationController *navController = (VBXNavigationController *)self.navigationController;
        [navController showSendTextWithState:[state objectForKey:@"sendTextState"] animated:NO];
    }
	
}

@end
