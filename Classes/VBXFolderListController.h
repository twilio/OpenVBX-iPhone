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

@class VBXFolderListAccessor;
@class VBXObjectBuilder;
@class VBXStringPartLabel;

@interface VBXFolderListController : VBXStatefulTableViewController {
    NSUserDefaults *_userDefaults;
    VBXFolderListAccessor *_accessor;
    VBXObjectBuilder *_builder;
    NSString *_selectedFolderKey;
    
    UIBarButtonItem *_refreshButton;
    UIBarButtonItem *_dialerButton;
    UIView *_footerView;
    UILabel *_footerLabel;
    UIActivityIndicatorView *_spinny;
    VBXStringPartLabel *_statusLabel;
}

@property (nonatomic, retain) NSUserDefaults *userDefaults;
@property (nonatomic, retain) VBXFolderListAccessor *accessor;
@property (nonatomic, assign) VBXObjectBuilder *builder;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *refreshButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *dialerButton;
@property (nonatomic, retain) IBOutlet UIView *footerView;
@property (nonatomic, retain) IBOutlet UILabel *footerLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinny;

- (IBAction)refresh;
- (IBAction)dialerPressed;

- (NSDictionary *)saveState;
- (void)restoreState:(NSDictionary *)state;

@end
