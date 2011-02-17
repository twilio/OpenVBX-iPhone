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

#import "VBXFolderListController.h"
#import "VBXFolderListAccessor.h"
#import "VBXFolderList.h"
#import "VBXFolderSummary.h"
#import "VBXMessageListController.h"
#import "VBXDialerController.h"
#import "VBXObjectBuilder.h"
#import "UIExtensions.h"
#import "NSExtensions.h"
#import "VBXFolderListCell.h"
#import "VBXStringPartLabel.h"
#import "VBXGlobal.h"
#import "VBXSendTextController.h"
#import "VBXNavigationController.h"
#import "VBXConfigAccessor.h"
#import "VBXConfiguration.h"
#import "VBXSettingsController.h"

@interface VBXFolderListController () <VBXFolderListAccessorDelegate, UIActionSheetDelegate>

@property (nonatomic, retain) NSString *selectedFolderKey;

@end


@implementation VBXFolderListController

@synthesize userDefaults = _userDefaults;
@synthesize accessor = _accessor;
@synthesize builder = _builder;
@synthesize selectedFolderKey = _selectedFolderKey;

@synthesize refreshButton = _refreshButton;
@synthesize dialerButton = _dialerButton;
@synthesize footerView = _footerView;
@synthesize footerLabel = _footerLabel;
@synthesize spinny = _spinny;

- (void)dealloc {
    [_statusLabel release];
    self.accessor.delegate = nil;
    self.accessor = nil;
    self.selectedFolderKey = nil;
    
    self.refreshButton = nil;
    self.dialerButton = nil;
    self.footerView = nil;
    self.footerLabel = nil;
    self.spinny = nil;

    [super dealloc];
}

- (void)showRefreshingState {
    [super showRefreshingState];
    
    _refreshButton.enabled = NO;
    _statusLabel.parts = [NSArray arrayWithObject:[VBXStringPart partWithText:LocalizedString(@"Refreshing...", @"Folder List: Message shown in toolbar when contents are refreshing.") font:[UIFont boldSystemFontOfSize:13.0]]];
}

- (void)updateControlsWithStatusMessage:(NSString *)message {
    _refreshButton.enabled = YES;
    _statusLabel.parts = [NSArray arrayWithObject:[VBXStringPart partWithText:message font:[UIFont boldSystemFontOfSize:13.0]]];
    _footerLabel.text = [NSString stringWithFormat:LocalizedString(@"%d folders", @"Folder List: Message shown in footer - is this even used!?"), [_accessor.model.folders count]];
    [_spinny stopAnimating];
}

- (void)updateControls {
    [self updateControlsWithStatusMessage:nil];
}

- (void)settingsPressed {
    UIViewController *controller = [_builder navControllerWrapping:[_builder settingsController]];
    [self presentModalViewController:controller animated:YES];
}

- (void)viewDidLoad {    
    _statusLabel = [[VBXStringPartLabel alloc] initWithFrame:CGRectMake(0, 0, 200, 18)];
    _statusLabel.textAlignment = UITextAlignmentCenter;
    _statusLabel.shadowOffset = CGSizeMake(0, -1);
    
    // Setting our footer view to an empty zero-size view prevents the UITableView from drawing
    // mor separator lines than we need.
    self.tableView.tableFooterView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    
    self.toolbarItems = [NSArray arrayWithObjects:
                         _refreshButton, 
                         [UIBarButtonItem flexibleSpace],
                         [UIBarButtonItem itemWithCustomView:_statusLabel], 
                         [UIBarButtonItem flexibleSpace], 
                         _dialerButton, 
                         nil];

    _accessor.delegate = self;
    
    [self applyConfig];
    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"gear.png"] style:UIBarButtonItemStylePlain target:self action:@selector(settingsPressed)] autorelease];
}

- (void)applyConfig {
    [super applyConfig];
    
    _statusLabel.textColor = ThemedColor(@"toolBarInfoTextColor", [UIColor whiteColor]);
    _statusLabel.shadowColor = ThemedColor(@"toolBarInfoTextShadowColor", [[UIColor darkGrayColor] colorWithAlphaComponent:0.8]);
    
    UIImage *titleImage = ThemedImage(@"folderListTitleImage", nil);
    
    if (titleImage) {
        self.title = nil;
        self.navigationItem.titleView = [[[UIImageView alloc] initWithImage:titleImage] autorelease];
    } else {
        NSString *title = [[VBXConfiguration sharedConfiguration] localizedStringForKey:@"folderListTitle" 
                                                                           defaultValue:@"Messages"];
        
        self.title = title;
    }
}

- (void)showLoadedState {
    [super showLoadedState];
    [self updateControls];
    
    NSDate *lastUpdatedDate = [_accessor timestampOfCachedData];    
    _statusLabel.parts = VBXStringPartsForUpdatedAtDate(lastUpdatedDate);
}

- (void)showLoadingState {
    [super showLoadingState];
    
    _refreshButton.enabled = NO;
    _statusLabel.parts = [NSArray arrayWithObjects:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
    if (_accessor.model) {
        [self showLoadedState];
    } else {
        [self showLoadingState];        
        [_accessor loadUsingCache:YES];
    }    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (IBAction)refresh {
    [self showRefreshingState];
    [_accessor loadUsingCache:NO];
}

- (IBAction)dialerPressed {
    [(VBXNavigationController *)self.navigationController showDialOrTextActionSheet];
}

- (void)showRefreshingAfterDelay {
    [self showRefreshingState];
}

- (void)accessorDidLoadData:(VBXFolderListAccessor *)a fromCache:(BOOL)fromCache {        

    if (!fromCache) {
        // If this hits, then we've already loaded a fresh copy from the network and we don't need
        // to show the "Refreshing..." thing.
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showRefreshingAfterDelay) object:nil];
    }
    
    [self updateControls];    
    
    if (a.model.folders.count == 0) {
        [self showEmptyState];
    } else {
        [self showLoadedState];
        [self.tableView reloadData];
    }

    if (fromCache) {
        // We don't show this immediately because we want the user to have a chance to see
        // the timestamp for the cached data.
        [self performSelector:@selector(showRefreshingAfterDelay) withObject:nil afterDelay:1.0];
    }
}

- (void)accessor:(VBXFolderListAccessor *)a loadDidFailWithError:(NSError *)error {
    debug(@"%@", [error detailedDescription]);
    
    [self showErrorState];
    
    if ([error isTwilioErrorWithCode:VBXErrorNoNetwork] && _accessor.model) {
        // We failed to load for lack of a network connection, but we have data already from cache. Don't bug the user with a popup.
        [self updateControlsWithStatusMessage:LocalizedString(@"No network; loaded data from cache", @"Folder List: Message shown when failed to update but there is data in the cache.")];
        return;
    }
    
    [self updateControlsWithStatusMessage:LocalizedString(@"Error", @"Folder List: Message shown in footer when there's an error loading the folders.")];
    if ([error isTwilioErrorWithCode:VBXErrorLoginRequired]) return;
    [UIAlertView showAlertViewWithTitle:LocalizedString(@"Could not load folders", @"Folder List: Title for alert when cannot load folders and there is no cache.") forError:error];
}

#pragma mark Table view methods

- (VBXFolderSummary *)folderForIndexPath:(NSIndexPath *)indexPath {
    return [_accessor.model.folders objectAtIndex:indexPath.row];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_accessor.model.folders count];
}

- (UITableViewCell *)cellWithReuseIdentifier:(NSString *)identifier {
    VBXFolderListCell *cell = [[[VBXFolderListCell alloc] initWithReuseIdentifier:identifier] autorelease];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)configureCell:(VBXFolderListCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    VBXFolderSummary *folder = [self folderForIndexPath:indexPath];
    [cell showFolderSummary:folder];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    VBXFolderSummary *folder = [self folderForIndexPath:indexPath];
    self.selectedFolderKey = folder.key;
    VBXMessageListController *controller = [_builder messageListControllerForFolderKey:_selectedFolderKey];
    controller.navigationItem.title = folder.name;
    [self.navigationController pushViewController:controller animated:YES];
}

- (NSDictionary *)saveState {
    NSMutableDictionary *state = [NSMutableDictionary dictionary];
    if ([self.navigationController topViewController] != self) {
        [state setObject:_selectedFolderKey forKey:@"selectedFolderKey"];
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
    self.selectedFolderKey = [state stringForKey:@"selectedFolderKey"];
    if (_selectedFolderKey) {
        VBXMessageListController *controller = [_builder messageListControllerForFolderKey:_selectedFolderKey];
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
