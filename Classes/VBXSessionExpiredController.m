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

#import "VBXSessionExpiredController.h"
#import "VBXObjectBuilder.h"
#import "VBXUserDefaultsKeys.h"
#import "NSExtensions.h"
#import "VBXResourceLoader.h"
#import "VBXResourceRequest.h"
#import "VBXURLLoader.h"
#import "NSURLExtensions.h"
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
#import "VBXDimOverlay.h"
#import "VBXAppDelegate.h"
#import "VBXSetNumberController.h"
#import "VBXGlobal.h"
#import "VBXConfiguration.h"

@implementation VBXSessionExpiredController

@synthesize userDefaults = _userDefaults;
@synthesize delegate = _delegate;
@synthesize builder = _builder;
@synthesize userInfo = _userInfo;

- (void)notifyDelegateAfterDelay {
    NSString *email = [_userDefaults stringForKey:VBXUserDefaultsEmailAddress];
    NSString *password = [[[_passwordField textField] text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];    
    
    if (_delegate) {
        [_delegate sessionExpiredController:self loginWithEmail:email password:password];
    }
}
    

- (void)notifyDelegate {
    [_emailField.textField resignFirstResponder];
    [_passwordField.textField resignFirstResponder];
    
    [self performSelector:@selector(notifyDelegateAfterDelay) withObject:nil afterDelay:0.4];
}

- (id)init {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:LocalizedString(@"Login", @"Login: Button title in upper right")
                                                                                   style:UIBarButtonItemStyleDone
                                                                                  target:self
                                                                                  action:@selector(notifyDelegate)] autorelease];
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
        self.title = LocalizedString(@"Login", @"Session Expired: Title for screen");
        
        self.navigationItem.prompt = LocalizedString(@"Your session expired.  Please log back in.", @"Session Expired: Short explanation for why you need to log back in that appears in prompt.");
    }
    return self;
}

- (void)dealloc {
    [_cellDataSource release];
    
    [_emailField release];
    [_passwordField release];
    
    [super dealloc];
}

- (void)loadView {
    [super loadView];
    
    _emailField = [[[VBXTextFieldCell alloc] initWithReuseIdentifier:nil] autorelease];
    _emailField.label.text = LocalizedString(@"E-Mail", @"Login: Label for email text field");
    _emailField.textField.placeholder = LocalizedString(@"yourname@acme.com", @"Login: placeholder text for email text field.");
    _emailField.textField.keyboardType = UIKeyboardTypeEmailAddress;
    _emailField.textField.returnKeyType = UIReturnKeyNext;    
    _emailField.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    _emailField.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _emailField.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _emailField.textField.placeholder = [[NSUserDefaults standardUserDefaults] stringForKey:VBXUserDefaultsEmailAddress];
    _emailField.textField.enabled = NO;
    
    _passwordField = [[[VBXTextFieldCell alloc] initWithReuseIdentifier:nil] autorelease];
    _passwordField.label.text = LocalizedString(@"Password", @"Login: Label for password field.");
    _passwordField.textField.placeholder = @"";
    _passwordField.textField.keyboardType = UIKeyboardTypeEmailAddress;
    _passwordField.textField.returnKeyType = UIReturnKeyGo;
    _passwordField.textField.delegate = self;
    _passwordField.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    _passwordField.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _passwordField.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _passwordField.textField.secureTextEntry = YES;
    _passwordField.textField.text = @"";
    
    _logoutButton = [[[VBXButtonCell alloc] initwithText:LocalizedString(@"Use a different email address", @"Session Expired: Label for login w/ a different email button.") reuseIdentifier:nil] autorelease];    
    
    _cellDataSource = [VBXSectionedCellDataSource dataSourceWithHeadersCellsAndFooters:
                       
                       @"", // no header
                       _emailField,
                       _passwordField,
                       @"", // no footer
                       
                       @"", // no header
                       _logoutButton,
                       @"", // no fotter
                       
                       nil];
    [_cellDataSource retain];
    
    self.tableView.dataSource = _cellDataSource;
    self.tableView.delegate = _cellDataSource;
    _cellDataSource.proxyToDelegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
            
    [[_passwordField textField] becomeFirstResponder];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if (cell == _logoutButton) {
        [_passwordField.textField resignFirstResponder];
        
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *serverURL = [defaults objectForKey:VBXUserDefaultsBaseURL];
        
        VBXClearAllData();
        
        // Restore the original server URL - this way it's prefilled when they
        // see the Set Server screen.
        [defaults setObject:serverURL forKey:VBXUserDefaultsBaseURL];
        
        VBXAppDelegate *appDelegate = (VBXAppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate showSetupFlow];
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self notifyDelegate];
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [textField setText:newString];
    
    self.navigationItem.rightBarButtonItem.enabled = (newString.length > 0);

    return NO;
}

@end
