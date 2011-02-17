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

#import "VBXTableViewController.h"
#import "VBXTableView.h"
#import "VBXTableViewCell.h"
#import "VBXGlobal.h"
#import "VBXConfiguration.h"
#import "UIExtensions.h"

@implementation VBXTableViewController

@synthesize tableView = _tableView;
@synthesize autoRefocusOnSelectedCell = _autoRefocusOnSelectedCell;

- (id)initWithStyle:(UITableViewStyle)style {
    if (self = [super init]) {
        _tableStyle = style;
        _autoRefocusOnSelectedCell = YES;
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)applyConfig {
    [super applyConfig];
    
}

- (void)loadView {
    [super loadView];
    
    self.tableView = [[[VBXTableView alloc] initWithFrame:VBXNavigationFrame() style:_tableStyle] autorelease];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.view = self.tableView;
    
    [self applyConfig];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    [super keyboardWillShow:notification];

    if (_autoRefocusOnSelectedCell) {
        // If the user just clicked a textfield, then we want to make sure that's in view after the resize.
        UIView *firstResponder = [self.view.window findFirstResponder];
        
        if (firstResponder != nil) {
            // Figure out which cell this is.
            UITableViewCell *cell = nil;
            UIView *currentView = firstResponder;
            
            // Walk up the hierarchy until we find our table cell
            for (;;) {
                if ([currentView isKindOfClass:[UITableViewCell class]]) {
                    cell = (UITableViewCell *)currentView;
                    break;
                } else if (currentView.superview != nil) {
                    currentView = currentView.superview;
                } else {
                    // We've gone as far as we can go
                    break;
                }
            }
            
            if (cell != nil) {
                NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
                [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            }
        }
    }
}

- (NSString *)cellIdentifier {
    return @"CellIdentifier";
}

- (UITableViewCell *)cellWithReuseIdentifier:(NSString *)identifier {
    return [[[VBXTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
}

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // no-op; subclasses can override
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {    
    NSString *identifier = [self cellIdentifier];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) cell = [self cellWithReuseIdentifier:identifier];
    [self configureCell:cell forRowAtIndexPath:indexPath];
    return cell;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    return 0;
}

@end
