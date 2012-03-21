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
 * <cdl@asgaard.org> modified "my number" length on 20Apr2012.  See comments
 * on line 155.  Made to reflect ITU recommendations on phone
 * number length.
 *
 **/

#import "VBXSetNumberController.h"
#import "VBXAppDelegate.h"
#import "VBXUserDefaultsKeys.h"
#import "VBXObjectBuilder.h"
#import "NSExtensions.h"
#import "VBXConfigAccessor.h"
#import "VBXTextFieldCell.h"
#import "VBXButtonCell.h"
#import "VBXFooterTextCell.h"
#import "VBXDataSource.h"
#import "VBXSectionedDataSource.h"
#import "VBXUserDefaultsKeys.h"
#import "VBXTableView.h"
#import "UIViewPositioningExtension.h"
#import "VBXActivityLabel.h"
#import "VBXGlobal.h"
#import "VBXConfiguration.h"

#define kAlertTagFailedToValidate 101

@interface VBXSetNumberController (Private) <UITextFieldDelegate>
@end


@implementation VBXSetNumberController

@synthesize userDefaults = _userDefaults;
@synthesize finishedTarget = _finishedTarget;
@synthesize finishedAction = _finishedAction;
@dynamic finishedButtonText;

- (void)finish {
    
    NSString *phoneNumber = VBXStripNonDigitsFromString(_numberField.textField.text);
    
    if (phoneNumber.length == 10 || [[phoneNumber substringToIndex:1] isEqualToString:@"+"]) {
        [_userDefaults setObject:phoneNumber forKey:VBXUserDefaultsCallbackPhone];
        [_userDefaults synchronize];
        
        [_finishedTarget performSelector:_finishedAction withObject:self];        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Incorrect Phone Number", @"Set Number: Title for alert when number fails to validate.")
                                                        message:LocalizedString(@"A 10-digit phone number is required to continue.", @"Set Number: Body for alert when number fails to validate.")
                                                       delegate:nil
                                              cancelButtonTitle:LocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

- (id)init {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"_i get set later_"
                                                                                   style:UIBarButtonItemStyleDone
                                                                                  target:self
                                                                                  action:@selector(finish)] autorelease];
        self.title = LocalizedString(@"Your Number", @"Set Number: Title for screen");
    }
    return self;
}

- (void)setFinishedButtonText:(NSString *)text {
    self.navigationItem.rightBarButtonItem.title = text;
}

- (void)setFinishedTarget:(id)finishedTarget {
    _finishedTarget = finishedTarget;
}

- (void)setFinishedAction:(SEL)finishedAction {
    _finishedAction = finishedAction;
}

- (void)dealloc {
    [_cellDataSource release];
    self.finishedTarget = nil;
    self.finishedAction = nil;
    
    [super dealloc];
}

- (void)loadView {
    [super loadView];
    
    _numberField = [[[VBXTextFieldCell alloc] initWithReuseIdentifier:nil] autorelease];
    _numberField.label.text = LocalizedString(@"Your Phone", @"Set Number: Label for table cell that contains phone number");
    _numberField.textField.placeholder = LocalizedString(@"555-555-5555", @"Set Number: Placeholder text for phone number.");
    _numberField.textField.keyboardType = UIKeyboardTypePhonePad;
    _numberField.textField.returnKeyType = UIReturnKeyDone;
    _numberField.textField.delegate = self;
    _numberField.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    _numberField.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _numberField.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    NSString *phoneNumber = nil;
    
    if ([_userDefaults stringForKey:VBXUserDefaultsCallbackPhone] != nil) {
        phoneNumber = [_userDefaults stringForKey:VBXUserDefaultsCallbackPhone];
    } else {
        phoneNumber = [_userDefaults stringForKey:@"SBFormattedPhoneNumber"];
    }
    
    phoneNumber = VBXFormatPhoneNumber(VBXStripNonDigitsFromString(phoneNumber));
    _numberField.textField.text = phoneNumber;
    
    _cellDataSource = [VBXSectionedCellDataSource dataSourceWithHeadersCellsAndFooters:
                      @"", // no header
                      _numberField,
                      LocalizedString(@"When you place phone calls using OpenVBX, you'll be called at this number to complete the connection.", @"Set Number: Sub text that explains why we need their phone number."),
                      nil];
    [_cellDataSource retain];
    
    self.tableView.dataSource = _cellDataSource;
    self.tableView.delegate = _cellDataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [_numberField.textField becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self finish];
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newString = VBXFormatPhoneNumber([textField.text stringByReplacingCharactersInRange:range withString:string]);
/*
 * Changed streng lentgh to 20 to match ITU recommendations on phone numbering length.
 * ITU recommends no phone number to be longer than 15 digits.
 * Adding international dialing codes (00, 011, +, 0014, etc.) we bump it to 20.
 * The 10 digit length used previously was not sufficient for many countries other
 * the NANP.
 * <cdl@asgaard.org>, 20Apr2012
 */
    if (VBXStripNonDigitsFromString(newString).length <= 20) {
        [textField setText:newString];
    }

    return NO;
}

@end
