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

#import "VBXCallerIdController.h"
#import "VBXDialerAccessor.h"
#import "VBXOutgoingPhone.h"
#import "VBXUserDefaultsKeys.h"
#import "VBXConfiguration.h"
#import "VBXTableViewCell.h"

@interface VBXCallerIdController (Private) <UITableViewDelegate, UITableViewDataSource, VBXDialerAccessorDelegate>
@end

@implementation VBXCallerIdController

@synthesize userDefaults = _userDefaults;
@synthesize accessor = _accessor;

- (id)init {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        self.title = LocalizedString(@"Phone Numbers", @"Caller Id: Title for screen.");
    }
    return self;
}

- (void)loadView {
    [super loadView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self showLoadingState];
    
    _accessor.delegate = self;
    [_accessor loadCallerIDs];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];    
}

- (void)dealloc {
    _accessor.delegate = nil;
    self.accessor = nil;
    self.userDefaults = nil;
    [super dealloc];
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    if (_accessor.callerIDs != nil) {
        return _accessor.callerIDs.count;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VBXOutgoingPhone *phone = [_accessor.callerIDs objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [[[VBXTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil] autorelease];
    cell.textLabel.text = phone.phone;
    
    if ([[_userDefaults objectForKey:VBXUserDefaultsCallerId] isEqualToString:phone.phone]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];    
    
    [_userDefaults setObject:cell.textLabel.text forKey:VBXUserDefaultsCallerId];
    [_userDefaults synchronize];
    
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)accessorCallerIDsResponseArrived:(VBXDialerAccessor *)accessor fromCache:(BOOL)fromCache {
    [self showLoadedState];
    [self.tableView reloadData];
    
    if (fromCache) {
        self.title = LocalizedString(@"Refreshing...", @"Caller ID: Nav bar title when cached data has loaded but we're still updating from the network.");
    } else {
        self.title = LocalizedString(@"Phone Numbers", @"Caller Id: Title for screen.");
    }
}

- (void)accessor:(VBXDialerAccessor *)accessor failedToLoadCallerIDsWithError:(NSError *)error {
    [self showErrorState];
}

@end
