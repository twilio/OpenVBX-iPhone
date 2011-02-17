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

#import "VBXStatefulTableViewController.h"
#import "VBXActivityLabel.h"
#import "VBXTableStatusView.h"
#import "VBXConfiguration.h"

@implementation VBXStatefulTableViewController

- (UIView *)loadingView {    
    VBXActivityLabel *label = [[[VBXActivityLabel alloc] initWithText:LocalizedString(@"Loading...", @"StatefulTableViewController: Title shown for loading view.")] autorelease];
    return label;
}

- (UIView *)emptyView {
    VBXTableStatusView *statusView = [[[VBXTableStatusView alloc] initWithFrame:CGRectZero] autorelease];
    [statusView setTitle:LocalizedString(@"Empty", @"StatefulTableViewController: Title shown table is empty.")];
    [statusView setDescription:LocalizedString(@"There are no items to show here.", @"StatefulTableViewController: Description shown when table is empty.")];
    return statusView;
}

- (UIView *)errorView {
    VBXTableStatusView *statusView = [[[VBXTableStatusView alloc] initWithFrame:CGRectZero] autorelease];
    [statusView setTitle:LocalizedString(@"Error", @"StatefulTableViewController: Title shown when there is an error loading table content.")];
    [statusView setDescription:LocalizedString(@"Something went wrong!", @"StatefulTableViewController: Description shown when there is an error loading content.")];
    return statusView;
}

- (void)showErrorState {
    trace();    
    [self clearOverlayView];
    [self setOverlayView:[self errorView]];
}

- (void)showEmptyState {
    trace();    
    [self clearOverlayView];
    [self setOverlayView:[self emptyView]];    
}

- (void)showLoadedState {
    trace();
    [self clearOverlayView];
}

- (void)showRefreshingState {
    trace();
    [self clearOverlayView];
}

- (void)showLoadingState {
    trace();
    [self clearOverlayView];
    [self setOverlayView:[self loadingView]];    
}

@end
