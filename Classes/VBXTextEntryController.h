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
#import "VBXViewController.h"

@interface VBXTextEntryController : UIViewController {
    id _target;
    SEL _action;
    NSString *_navTitle;
    NSString *_initialText;
    UINavigationBar *_navBar;
    UITextView *_textView;
}

@property (nonatomic, assign) id target;
@property (nonatomic, assign) SEL action;
@property (nonatomic, retain) NSString *navTitle;
@property (nonatomic, retain) NSString *initialText;
@property (nonatomic, retain) IBOutlet UINavigationBar *navBar;
@property (nonatomic, retain) IBOutlet UITextView *textView;

- (IBAction)save;
- (IBAction)cancel;

- (NSDictionary *)saveState;
- (void)restoreState:(NSDictionary *)state;

@end
