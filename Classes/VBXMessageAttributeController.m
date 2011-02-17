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

#import "VBXMessageAttributeController.h"
#import "VBXMessageAttribute.h"
#import "VBXMessageAttributeAccessor.h"
#import "UIExtensions.h"
#import "NSExtensions.h"
#import "VBXGlobal.h"
#import "VBXConfiguration.h"
#import "VBXTableViewCell.h"

@interface VBXMessageAttributeController () <VBXMessageAttributeAccessorDelegate>

@end


@implementation VBXMessageAttributeController

@synthesize attribute = _attribute;
@synthesize accessor = _accessor;

- (void)dealloc {
    [_attribute release];
    [_accessor release];
    [super dealloc];
}

- (void)viewDidLoad {
}

#pragma mark Table view methods

- (UITableViewCellStyle)cellStyle {
    return _attribute.hasDetail? UITableViewCellStyleSubtitle : UITableViewCellStyleDefault;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_attribute.options count];
}

- (UIView *)spinny {
    UIActivityIndicatorView *spinny = [[[UIActivityIndicatorView alloc]
        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    [spinny startAnimating];
    return spinny;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[VBXTableViewCell alloc] initWithStyle:[self cellStyle] reuseIdentifier:CellIdentifier] autorelease];
    }

    id value = [_attribute.options objectAtIndex:indexPath.row];
    cell.textLabel.text = [_attribute titleForValue:value];
    cell.detailTextLabel.text = [_attribute detailForValue:value];
    
    if (cell.detailTextLabel.text.length > 0) {
    	// Tweak the font down a little - makes it look a little nicer.
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16];        
    }

    cell.accessoryView = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
    if (_attribute.pendingValue) {
        if ([value isEqual:_attribute.pendingValue]) cell.accessoryView = [self spinny];
    } else {
        if ([value isEqual:_attribute.value]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == _attribute.selectedIndex) return;
    
    _accessor.delegate = self;
    [_accessor setValue:[_attribute.options objectAtIndex:indexPath.row]];
    [tableView reloadData];
    
    [self setPromptAndDimView:LocalizedString(@"Saving...", @"Message Attribute: Navigation bar prompt shown while attribute is saving")];
    [self.navigationItem setHidesBackButton:YES animated:YES];
}

- (void)accessorDidSetValue:(VBXMessageAttributeAccessor *)accessor {
    [self unsetPromptAndUndim];
    [self.navigationItem setHidesBackButton:NO animated:YES];
    
    [self.tableView reloadData];
}

- (void)accessor:(VBXMessageAttributeAccessor *)accessor setValueDidFailWithError:(NSError *)error {
    [self unsetPromptAndUndim];
    [self.navigationItem setHidesBackButton:NO animated:YES];
    
    debug(@"%@", [error detailedDescription]);
    [UIAlertView showAlertViewWithTitle:LocalizedString(@"Couldn't update message", @"Message Attribute: Shown when the attribute fails to save.") forError:error];
    [self.tableView reloadData];
}

@end
