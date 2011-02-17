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

#import "VBXSetServerController.h"
#import "VBXObjectBuilder.h"
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
#import "VBXViewCell.h"
#import "VBXURLLoader.h"
#import "VBXResourceLoader.h"
#import <Security/SecTrust.h>
#import "VBXGlobal.h"
#import "VBXConfiguration.h"
#import "VBXLoginController.h"
#import "VBXDialerController.h"
#import "VBXTrustHelper.h"
#import "NSExtensions.h"
#import "VBXVersion.h"

#define kAlertTagUntrustedCert 101
#define kAlertTagFailedToLoad 102
#define kAlertTagDenyWithGenericTrustError 103
#define kAlertTagDenyWithTrustedCertRequired 104
#define kAlertTagPromptWithUntrustedCert 105

@interface VBXSetServerController (Private) <UITextFieldDelegate, VBXConfigAccessorDelegate, UIAlertViewDelegate>

@end


@implementation VBXSetServerController

@synthesize userDefaults = _userDefaults;
@synthesize cookieStorage = _cookieStorage;
@synthesize credentialStorage = _credentialStorage;
@synthesize allCaches = _allCaches;

- (void)next {
    [_serverField.textField resignFirstResponder];

    self.navigationItem.rightBarButtonItem.enabled = NO;
        
    [self setPromptAndDimView:LocalizedString(@"Verifying OpenVBX Server...", @"Set Server: Navigation bar prompt shown when we're verifying the server.")];
        
    // By clearing this key, we're ensuring that the untrusted cert handler in TwilioAppDelegate
    // doesn't interfere with what we're doing here.
    [_userDefaults removeObjectForKey:VBXUserDefaultsBaseURL];
    [_userDefaults synchronize];
    
    // Add a trailing slash to the URL if it's not already present.
    NSString *serverURL = [_serverField.textField.text stringByTrimmingWhitespace];
    
    if ([serverURL length] > 0 && ![[serverURL substringFromIndex:serverURL.length - 1] isEqualToString:@"/"]) {
        serverURL = [serverURL stringByAppendingString:@"/"];
    }
    
    _serverField.textField.text = serverURL;
        
    _configAccessor = [[[VBXObjectBuilder sharedBuilder] configAccessorWithBaseURL:_serverField.textField.text] retain];    
    _configAccessor.delegate = self;
    [_configAccessor loadConfigUsingCache:NO];
}

- (id)init {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:LocalizedString(@"Next", @"Set Server: Button label for the next button in the upper right.")
                                                                                   style:UIBarButtonItemStyleDone
                                                                                  target:self
                                                                                  action:@selector(next)] autorelease];
        self.title = LocalizedString(@"Setup", @"Set Server: Title for screen.");        
    }
    return self;
}

- (void)dealloc {
    [_cellDataSource release];
    [_serverField release];
    
    [super dealloc];
}

- (void)loadView {
    [super loadView];

    UIView *logoView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 200)] autorelease];
    
    UIImageView *logo = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"openvbx-logo.png"]] autorelease];
    [logo centerHorizontallyInView:logoView];
    logo.top = 10;
    logo.backgroundColor = _tableView.backgroundColor;
    [logoView addSubview:logo];
    
    VBXViewCell *logoViewCell = [[[VBXViewCell alloc] initWithView:logoView reuseIdentifier:nil] autorelease];
    logoViewCell.showBackground = NO;
    logoViewCell.backgroundColor = _tableView.backgroundColor;
    logoViewCell.selectedBackgroundView.backgroundColor = logoView.backgroundColor;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *serverURL = [defaults objectForKey:VBXUserDefaultsBaseURL];    

    if (serverURL == nil) {
        serverURL = @"";
    }
    
    _serverField = [[[VBXTextFieldCell alloc] initWithReuseIdentifier:nil] autorelease];
    // Don't show a label
    _serverField.label.text = @"";    
    _serverField.textField.placeholder = @"https://";
    _serverField.textField.keyboardType = UIKeyboardTypeURL;
    _serverField.textField.returnKeyType = UIReturnKeyNext;    
    _serverField.textField.delegate = self;
    _serverField.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    _serverField.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _serverField.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _serverField.textField.text = serverURL;
    _serverField.helpLabel.text = LocalizedString(@"URL to your OpenVBX installation", @"Set Server: Help text for OpenVBX URL field");
    _serverField.textField.backgroundColor = ThemedColor(@"textFieldBackgroundColor", [UIColor whiteColor]);
    _serverField.backgroundColor = ThemedColor(@"textFieldBackgroundColor", [UIColor whiteColor]);
    _cellDataSource = [VBXSectionedCellDataSource dataSourceWithHeadersCellsAndFooters:
                       @"", // no header
                       logoViewCell,
                       @"", // no footer
                       // Server URL
                       @"Connect to your OpenVBX",
                       _serverField,
                       @"",
                       nil];
    
    [_cellDataSource retain];
    
    self.tableView.dataSource = _cellDataSource;
    self.tableView.delegate = _cellDataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _tableView.backgroundColor = ThemedColor(@"setupBackgroundColor", RGBHEXCOLOR(0xf7f7f7));
    if ([defaults boolForKey:VBXUserDefaultsAutoconfigure]) {
        [self next];
        [defaults setBool:NO forKey:VBXUserDefaultsAutoconfigure];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _tableView.backgroundColor = ThemedColor(@"setupBackgroundColor", RGBHEXCOLOR(0xf7f7f7));
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveAuthenticationChallenge:)
                                                 name:VBXURLLoaderDidReceiveAuthenticationChallenge object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:VBXURLLoaderDidReceiveAuthenticationChallenge object:nil];        
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self next];
    return NO;
}

- (void)accessor:(VBXConfigAccessor *)accessor didLoadConfigDictionary:(NSDictionary *)dictionary hadTrustedCertificate:(BOOL)hadTrustedCertificate {
    
    // If we encountered an invalid certificate in loading this config info _AND_ the
    // server has specified that they'll only operate in secure mode, we show an error
    // that says the user cannot connect to this server.
    BOOL onlyAllowValidCertificates = [[dictionary objectForKey:@"config"] boolForKey:@"requireTrustedCertificate"];
    
    if (onlyAllowValidCertificates && !hadTrustedCertificate) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Security Error", @"Set Server: Title for alert shown when certificate is invalid and server has said to not use invalid certificates.")
                                                        message:LocalizedString(@"The server you're trying to connect has specified that it should only operate with valid SSL certificates, but it's presenting an invalid certificate.  Please contact your OpenVBX service provider.", @"Set Server: Body for alert shown when certificate is invalid and server has said to not use invalid certificates.")
                                                       delegate:nil
                                              cancelButtonTitle:LocalizedString(@"OK", nil)
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
        
        [self unsetPromptAndUndim];
        self.navigationItem.rightBarButtonItem.enabled = YES;
        
    } else {
		if(![[dictionary stringForKey:@"version"] length]) {
			[NSException raise:NSGenericException format:@"Server version not returned, this is bad"];
		}
		
		VBXVersion *version = [VBXVersion fromString:[dictionary stringForKey:@"version"]];
		VBXVersionComparison cmp = [version compareVersion:@"0.90"];
		
		if( (cmp & MAJOR_EQUAL && cmp & MINOR_LESSER) || cmp & MAJOR_LESSER ) {
			// If the server is running a version earlier than 0.90 OpenVBX, lets warn the user.
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"OpenVBX Server is too old", @"Set Server: Title for alert shown when version is too old for client.") 
														message:LocalizedString(@"The version of OpenVBX you're running is older than the required version, please visit http://openvbx.org and upgrade to the latest version.", @"Set Server: Body for alert show when version is too old for client.") 
													   delegate:nil 
											  cancelButtonTitle:LocalizedString(@"OK", nil)
											  otherButtonTitles:nil];
		
			[alert show];
			[alert release];
		}
        // Things worked out!
        [[VBXConfiguration sharedConfiguration] loadConfigFromDictionary:dictionary 
                                                            serverURL:_serverField.textField.text 
                                                hadTrustedCertificate:hadTrustedCertificate];
        
        [_userDefaults setObject:_serverField.textField.text forKey:VBXUserDefaultsBaseURL];
        [_userDefaults synchronize];
        
        DialerBuildImages();
        
        [self unsetPromptAndUndim];
        self.navigationItem.rightBarButtonItem.enabled = YES;
        
        [self.navigationController pushViewController:[[VBXObjectBuilder sharedBuilder] loginController] animated:YES];            
    }
    
}

- (void)accessor:(VBXConfigAccessor *)accessor loadFailedWithError:(NSError *)error {
    UIAlertView *alert = nil;
    if ([error code] == 1) {
        alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Error", @"Set Server: Title for alert with error code 1")
                                           message:[error localizedDescription]
                                          delegate:self
                                 cancelButtonTitle:LocalizedString(@"OK", nil)
                                 otherButtonTitles:nil];
        alert.tag = kAlertTagFailedToLoad;
        [alert show];
        [alert release];
        return;
    }
    
    alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Error", @"Set Server: Title for alert shown when server verification fails.")
                                                    message:LocalizedString(@"The URL provided doesn't seem to point to an OpenVBX installation.", @"Set Server: Body for alert shown when server verification fails.")
                                                   delegate:self
                                          cancelButtonTitle:LocalizedString(@"OK", nil)
                                          otherButtonTitles:nil];
    alert.tag = kAlertTagFailedToLoad;
    [alert show];
    [alert release];
}

- (void)didReceiveAuthenticationChallenge:(NSNotification *)notification {
    NSURLAuthenticationChallenge *challenge = [notification object];
    NSURLProtectionSpace *protectionSpace = [challenge protectionSpace];
    
    if ([[protectionSpace authenticationMethod] isEqualToString:NSURLAuthenticationMethodServerTrust]) {                
        SecTrustResultType type = 0;    
        OSStatus status = SecTrustEvaluate(protectionSpace.serverTrust, &type);
        
        BOOL requireTrustedCertificateForURL = [VBXTrustHelper serverURLRequiresTrustedCertificate:[_serverField.textField.text stringByTrimmingWhitespace]];
        
        SetupTrustAction action = [VBXTrustHelper actionForSetupTrustIssueWithOSStatus:status 
                                                                 secTrustResultType:type 
                                                       requireTrustedCertForThisURL:requireTrustedCertificateForURL];

        if (SetupTrustActionDenyWithGenericError == action) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Error", @"Set Server: Title for alert shown when server has weird cert issue but we don't know what it is (non recoverable).")
                                                            message:LocalizedString(@"The certificate for this OpenVBX installation is invalid.", @"Set Server: Body for alert shown when server has untrusted cert and it's not recoverable.")
                                                           delegate:self 
                                                  cancelButtonTitle:LocalizedString(@"OK", nil)
                                                  otherButtonTitles:nil];
            alert.tag = kAlertTagDenyWithGenericTrustError;
            [alert show];
            [alert release];
        } else if (SetupTrustActionDenyWithTrustedCertRequiredAlert == action) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Trusted Certificate Required" 
                                                            message:@"Blah"
                                                           delegate:nil 
                                                  cancelButtonTitle:@"OK" 
                                                  otherButtonTitles:nil];
            alert.tag = kAlertTagDenyWithTrustedCertRequired;
        } else if (SetupTrustActionPromptWithUntrustedCertAlert == action) {
            _challenge = [challenge retain];
            _protectionSpace = [protectionSpace retain];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Accept Certificate?", @"Set Server: Title for alert shown when server has untrusted certificate.")
                                                            message:LocalizedString(@"The certificate for this OpenVBX installation is invalid.  Tap Accept to connect to this server anyway.  If unsure, contact your OpenVBX service provider.", @"Set Server: Body for alert shown when server has untrusted cert.")
                                                           delegate:self 
                                                  cancelButtonTitle:LocalizedString(@"No", @"Set Server: Button title for No option in alert, asking the user if they want to accept the cert.")
                                                  otherButtonTitles:LocalizedString(@"Accept", @"Set Server: Button title for Yes option in alert, asking the user if they want to accept the cert."), nil];
            alert.tag = kAlertTagPromptWithUntrustedCert;
            [alert show];
            [alert release];
            
        } else if (SetupTrustActionAllow == action) {
            [VBXTrustHelper acceptCertificateAndRecordCertificateInfoWithChallenge:challenge serverTrust:protectionSpace.serverTrust];
        } else {
            // This should never happen...
            assert(0);
        }
    } else {
        // Just cancel it - we must have gotten a basic auth response or something when trying to fetch
        // the config, which isn't cool...
        [[challenge sender] cancelAuthenticationChallenge:challenge];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ((alertView.tag == kAlertTagDenyWithGenericTrustError) ||
        (alertView.tag == kAlertTagDenyWithTrustedCertRequired))
    {
        // Do not accept the cert
        [_configAccessor.loader cancelAllRequests];
        
        [self unsetPromptAndUndim];
        self.navigationItem.rightBarButtonItem.enabled = YES;    
    } else if (alertView.tag == kAlertTagPromptWithUntrustedCert) {
        if (buttonIndex == 0) {
            // Do not accept the cert
            [_configAccessor.loader cancelAllRequests];
            
            [self unsetPromptAndUndim];
            self.navigationItem.rightBarButtonItem.enabled = YES;
        } else {                                                
            // Accept the cert!
            [VBXTrustHelper acceptCertificateAndRecordCertificateInfoWithChallenge:_challenge serverTrust:_protectionSpace.serverTrust];
            
            [_challenge release];
            _challenge = nil;
            [_protectionSpace release];
            _protectionSpace = nil;
        }
    } else if (alertView.tag == kAlertTagFailedToLoad) {
        [self unsetPromptAndUndim];
        self.navigationItem.rightBarButtonItem.enabled = YES;    
    }
}

@end
