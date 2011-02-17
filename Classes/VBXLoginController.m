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

#import "VBXLoginController.h"
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
#import "SFHFKeychainUtils.h"

@interface VBXLoginController (Private) <UIAlertViewDelegate>
@end


@implementation VBXLoginController

@synthesize userDefaults = _userDefaults;
@synthesize loader = _loader;
@synthesize credentialStorage = _credentialStorage;

- (void)clearCookies {
    NSString *baseURL = [_userDefaults stringForKey:VBXUserDefaultsBaseURL];
    
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [storage cookiesForURL:[NSURL URLWithString:baseURL]];
    
    for (NSHTTPCookie *cookie in cookies) {
        debug(@"Deleting cookie: %@", cookie);
        [storage deleteCookie:cookie];
    }
}

- (void)dimView {
    [self setOverlayView:[VBXDimOverlay overlay]];
}

- (void)login {
    [_emailField resignFirstResponder];
    [_passwordField resignFirstResponder];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.navigationItem.prompt = LocalizedString(@"Verifying e-mail and password...", @"Login: Navigation bar prompt shown while we're logging in.");
    [self performSelector:@selector(dimView) withObject:nil afterDelay:0.1];
    
    [self clearCookies];
    
    // Delete any credentials that might already be stored.  If we don't do this and we already have
    // stored credentials (because we've done a successful login before), then we'll just get logged
    // right in and we won't actually be testing anything.
    NSURL *url = [_userDefaults VBXURLForKey:VBXUserDefaultsBaseURL];
    for (NSURLProtectionSpace *space in [[_credentialStorage allCredentials] keyEnumerator]) {
        if ([space matchesURL:url]) {
            debug(@"Removing credentials for protection space: %@", space);
            [_credentialStorage removeCredentialsForProtectionSpace:space];
        }
    }
    
    _loader.target = self;
    _loader.answersAuthChallenges = YES;
    [_loader loadRequest:[VBXResourceRequest requestWithResource:@"messages/inbox"] usingCache:NO];
}

- (void)phoneNumberWasValidated:(UIViewController *)sender {
    [_userDefaults setBool:YES forKey:VBXUserDefaultsCompletedSetup];
    [_userDefaults synchronize];

    VBXAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate showMainFlow];    
}

- (void)loader:(VBXResourceLoader *)loader didLoadObject:(id)object fromCache:(BOOL)fromCache {
    [self clearOverlayView];
    self.navigationItem.rightBarButtonItem.enabled = YES;
    self.navigationItem.prompt = nil;
    
    NSString *serviceName = [_userDefaults stringForKey:VBXUserDefaultsBaseURL];
    NSString *email = [_emailField.textField.text stringByTrimmingWhitespace];
    NSString *password = [_passwordField.textField.text stringByTrimmingWhitespace];
    
    [_userDefaults setObject:email forKey:VBXUserDefaultsEmailAddress];
    [_userDefaults synchronize];
  
    NSError *error = nil;
    
    [SFHFKeychainUtils storeUsername:email andPassword:password forServiceName:serviceName updateExisting:YES error:&error];
    
    if (error != nil) {
        // If it errors out, we care, but not enough to stop them from progressing.
        debug(@"Failed to store the credentials: %@", error);
    }
    
    VBXSetNumberController *setNumberController = [[VBXObjectBuilder sharedBuilder] setNumberController];
    setNumberController.finishedTarget = self;
    setNumberController.finishedAction = @selector(phoneNumberWasValidated:);
    setNumberController.finishedButtonText = LocalizedString(@"Finish", @"Login: Button label to show in the top right of the SetNumber screen.");
    [self.navigationController pushViewController:setNumberController animated:YES];
}

- (void)loader:(VBXResourceLoader *)loader didFailWithError:(NSError *)error {
    debug(@"Got error result back %@", [error detailedDescription]);    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Login Failed", @"Login: Title for alert shown when login fails.")
                                                    message:LocalizedString(@"Your email address or password is invalid.", @"Login: body for alert shown when login fails.")
                                                   delegate:self 
                                          cancelButtonTitle:LocalizedString(@"OK", nil)
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}


- (id)init {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:LocalizedString(@"Login", @"Login: Button title in upper right")
                                                                                   style:UIBarButtonItemStyleDone
                                                                                  target:self
                                                                                  action:@selector(login)] autorelease];
        self.title = LocalizedString(@"Login", @"Login: Title for screen");
    }
    return self;
}

- (void)dealloc {
    [_loader cancelAllRequests];
    
    [_cellDataSource release];

    [_emailField release];
    [_passwordField release];
    
    [super dealloc];
}

- (void)loadView {
    [super loadView];
    
    _tableView.backgroundColor = ThemedColor(@"setupBackgroundColor", RGBHEXCOLOR(0xf7f7f7));
    _emailField = [[[VBXTextFieldCell alloc] initWithReuseIdentifier:nil] autorelease];
    _emailField.label.text = LocalizedString(@"E-Mail", @"Login: Label for email text field");
    _emailField.textField.placeholder = LocalizedString(@"yourname@acme.com", @"Login: placeholder text for email text field.");
    _emailField.textField.keyboardType = UIKeyboardTypeEmailAddress;
    _emailField.textField.returnKeyType = UIReturnKeyNext;    
    _emailField.textField.delegate = self;
    _emailField.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    _emailField.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _emailField.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _emailField.textField.text = [_userDefaults stringForKey:VBXUserDefaultsEmailAddress];

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
    
    _cellDataSource = [VBXSectionedCellDataSource dataSourceWithHeadersCellsAndFooters:
                      @"", // no header
                      _emailField,
                      _passwordField,
                      @"", // no footer
                      nil];
    [_cellDataSource retain];
    
    self.tableView.dataSource = _cellDataSource;
    self.tableView.delegate = _cellDataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveAuthenticationChallenge:)
                                                 name:VBXURLLoaderDidReceiveAuthenticationChallenge 
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:VBXURLLoaderDidReceiveAuthenticationChallenge 
                                                  object:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (_emailField.textField == textField) {
        [_passwordField.textField becomeFirstResponder];
    } else {
        [self login];
    }
    
    return NO;
}

- (void)didReceiveAuthenticationChallenge:(NSNotification *)notification {
    NSURLAuthenticationChallenge *challenge = [notification object];
    NSURLProtectionSpace *protectionSpace = [challenge protectionSpace];
    NSString *method = [protectionSpace authenticationMethod];
    
    if ([method isEqualToString:NSURLAuthenticationMethodDefault]) {
        if ([challenge previousFailureCount] > 0) {
            // If we've failed once already, then don't try again.
            [[challenge sender] cancelAuthenticationChallenge:challenge];
        } else {
            // Submit our credentials
            [[challenge sender] useCredential:[NSURLCredential credentialWithUser:[_emailField.textField.text stringByTrimmingWhitespace]
                                                                         password:[_passwordField.textField.text stringByTrimmingWhitespace]
                                                                      persistence:NSURLCredentialPersistenceNone]
                   forAuthenticationChallenge:challenge];            
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // We only get here if the login was invalid.
    [self clearOverlayView];
    self.navigationItem.rightBarButtonItem.enabled = YES;
    self.navigationItem.prompt = nil;  
}

@end
