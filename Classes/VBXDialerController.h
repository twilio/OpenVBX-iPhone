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

void DialerBuildImages();

@class VBXDialerAccessor;
@class CallerIdControl;
@class NumberAreaView;

@interface VBXDialerController : VBXViewController {
    NSUserDefaults *_userDefaults;
    VBXDialerAccessor *_accessor;
    NSMutableString *_phoneNumber;
    NSInteger _selectedCallerIDIndex;
    NSString *_callerIdNumber;

    CallerIdControl *_callerIdControl;
    NumberAreaView *_numberAreaView;
    
    UIView *_dialerView;
    
    BOOL _callIsBeingScheduled;
    NSString *_initialPhoneNumber;
    BOOL _callerIdPickerIsOpen;
}

@property (nonatomic, retain) NSUserDefaults *userDefaults;
@property (nonatomic, retain) VBXDialerAccessor *accessor;

- (id)initWithPhone:(NSString *)phone;

- (IBAction)numberPressed:(id)sender;
- (IBAction)deletePressed;
- (IBAction)callPressed;
- (IBAction)chooseContactPressed;

- (NSDictionary *)saveState;
- (void)restoreState:(NSDictionary *)state;

@end
