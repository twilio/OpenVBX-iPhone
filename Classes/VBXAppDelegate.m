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

#import <AVFoundation/AVFoundation.h>

#import "VBXAppDelegate.h"
#import "VBXObjectBuilder.h"
#import "VBXNavigationController.h"
#import "VBXDialerAccessor.h"
#import "VBXConfigAccessor.h"
#import "VBXResourceLoader.h"
#import "VBXURLLoader.h"
#import "VBXUserDefaultsKeys.h"
#import "UIExtensions.h"
#import "NSURLExtensions.h"
#import "NSExtensions.h"
#import "VBXConfiguration.h"
#import "VBXTrustHelper.h"
#import "VBXSecurityAlertController.h"
#import "VBXSessionExpiredController.h"
#import "VBXFolderListController.h"
#import "VBXAppURL.h"
#import "SFHFKeychainUtils.h"

#define kAlertTagPromptWithUntrustedCertificateHasChangedAlert 101
#define kAlertTagPromptWithCertificateIsNowUntrustedAlert 102

@interface VBXAppDelegate () <VBXConfigurable, UIAlertViewDelegate, VBXConfigAccessorDelegate, VBXSecurityAlertControllerDelegate, VBXSessionExpiredControllerDelegate>

@property (nonatomic, retain) VBXObjectBuilder *builder;

- (void)finishedProcessingAuthenticationChallenge;
- (void)processAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;

@end


@implementation VBXAppDelegate

@synthesize window = _window;
@synthesize mainNavigationController = _mainNavigationController;
@synthesize setupNavigationController = _setupNavigationController;
@synthesize builder = _builder;

- (id)init {
    if (self = [super init]) {
        _authenticationChallenges = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

- (void)dealloc {
    [_authenticationChallenges release];
    [_configAccessor release];
    [[VBXConfiguration sharedConfiguration] removeConfigObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_window release];
    [_mainNavigationController release];
    [_setupNavigationController release];
    [_builder release];
    [super dealloc];
}

#pragma mark App init

- (void)configureAudioSession {
    NSError *error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    if (error) {
        debug(@"error: %@", [error detailedDescription]);
        [UIAlertView showAlertViewWithTitle:@"Problem configuring audio. Messages may not play if ringer is silenced." forError:error];
    }
}

- (void)restoreState {    
    NSDictionary* appState = [[_builder userDefaults] objectForKey:VBXUserDefaultsApplicationState];
	NSDictionary* urlState = [NSDictionary dictionaryWithObject:[NSArray array] forKey:@"controllerStates"];
	
	if ([[_builder userDefaults] objectForKey:VBXUserDefaultsApplicationLaunchURL]) {
		NSURL *launchURL = [NSURL URLWithString:[[_builder userDefaults] 
												 objectForKey:VBXUserDefaultsApplicationLaunchURL]];
		
		debug(@"launchURL: %@", launchURL);
		[[_builder userDefaults] setObject:nil forKey:VBXUserDefaultsApplicationLaunchURL];
		[[_builder userDefaults] synchronize];
		urlState = [VBXAppURL route:launchURL];
	}
	
    @try {
		if ([[urlState objectForKey:@"controllerStates"] count] >= 1) {
			debug(@"restoring app state: %@", urlState);
			[_mainNavigationController restoreState:urlState];
		} else {
			[_mainNavigationController restoreState:appState];
		}
		
    } @catch (NSException * e) {
        debug(@"exception restoring state: %@", e);
        [[_builder userDefaults] removeObjectForKey:VBXUserDefaultsApplicationState];		  
    }
}

- (void)saveState {
    // Only save our state if we've complete the setup process
	debug(@"saveState");
    if ([[[_builder userDefaults] objectForKey:VBXUserDefaultsCompletedSetup] boolValue]) {
        id state = [_mainNavigationController saveState];    
        [[_builder userDefaults] setObject:state forKey:VBXUserDefaultsApplicationState];
    }    
}

- (void)applyConfig {
    UIStatusBarStyle style = [[VBXConfiguration sharedConfiguration] statusBarStyleForKey:@"statusBarStyle" defaultValue:UIStatusBarStyleDefault];
    [[UIApplication sharedApplication] setStatusBarStyle:style animated:NO];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	if ([[[_builder userDefaults] objectForKey:VBXUserDefaultsCompletedSetup] boolValue]) {
		[self showMainFlow];
		[self restoreState];
	} else {
        [self restoreState];
    }

}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds] autorelease];    
    
    self.builder = [VBXObjectBuilder sharedBuilder];
    
    // We like it when the screen dims and stops accepting touch events when the
    // phone is held to the user's head.
    [UIDevice currentDevice].proximityMonitoringEnabled = YES;
    
    [self configureAudioSession];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(urlLoaderDidStartLoading:) name:VBXURLLoaderDidStartLoading object:nil];
    [notificationCenter addObserver:self selector:@selector(urlLoaderDidFinishLoading:)name:VBXURLLoaderDidFinishLoading object:nil];
    [notificationCenter addObserver:self selector:@selector(didReceiveAuthenticationChallenge:)
							   name:VBXURLLoaderDidReceiveAuthenticationChallenge object:nil];
	
    _configAccessor = [[_builder configAccessor] retain];
    _configAccessor.delegate = self;
    [_configAccessor loadDefaultConfig];
    
    if ([[_builder userDefaults] boolForKey:VBXUserDefaultsCompletedSetup] == YES) {
        [self showMainFlow];
        [self restoreState];        
    } else {
        [self showSetupFlow];
    }
    
    if (launchOptions != nil && [launchOptions allKeys].count > 0) {
        NSURL *url = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
        debug(@"opened with URL: %@", url);
    }
    
    [[VBXConfiguration sharedConfiguration] addConfigObserver:self];
    [self applyConfig];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
	[self saveState];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [self saveState];
}

#pragma mark App Url handling
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	if (!url) {  return NO; }
	debug(@"handleOpenURL: %@", [url path]);
    NSString *URLString = [url absoluteString];
    [[_builder userDefaults] setObject:URLString forKey:VBXUserDefaultsApplicationLaunchURL];
    [[_builder userDefaults] synchronize];
    return YES;	
}

#pragma mark Network activity

- (void)urlLoaderDidStartLoading:(NSNotification *)notification {
    _outstandingLoads++;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)urlLoaderDidFinishLoading:(NSNotification *)notification {
    _outstandingLoads--;
    if (_outstandingLoads < 1) [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // Everytime we get this notification, it means we executed a successful network request,
    // which also implies our credentials are good.
    _numberOfFailedLoginAttemptsWithCurrentCredentials = 0;
}

- (void)finishedProcessingAuthenticationChallenge {
    _isHandlingAuthenticationChallenge = NO;
    
    if (_authenticationChallenges.count > 0) {
        // process the next challenge if there is one...
        NSURLAuthenticationChallenge *challenge = [[_authenticationChallenges objectAtIndex:0] retain];
        [_authenticationChallenges removeObjectAtIndex:0];
        [self processAuthenticationChallenge:[challenge autorelease]];
    }
}

- (void)processAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    NSURLProtectionSpace *protectionSpace = [challenge protectionSpace];
    NSString *method = [protectionSpace authenticationMethod];
	
    NSUserDefaults *defaults = [_builder userDefaults];
    NSString *serverURL = [defaults stringForKey:VBXUserDefaultsBaseURL];
    BOOL completedSetup = [defaults boolForKey:VBXUserDefaultsCompletedSetup];
    
    if (completedSetup && [method isEqualToString:NSURLAuthenticationMethodHTTPBasic]) {
        
        // By setting this to true, we ensure no more auth challenges get handled until
        // the user has finished with this one.
        _isHandlingAuthenticationChallenge = YES;
        
        // If our authentication fails, we first try and automatically log back in using
        // our last known good credentails.  If that fails, we then prompt the user for
        // new credentials.
        
        BOOL didAttemptAutomaticLogin = NO;
        
        if (_numberOfFailedLoginAttemptsWithCurrentCredentials == 0) {
            // Try to automatically log back in using our last known good credentials.
            
            _numberOfFailedLoginAttemptsWithCurrentCredentials++;
            
            NSError *error = nil;
            
            NSString *username = [defaults stringForKey:VBXUserDefaultsEmailAddress];
            NSString *password = [SFHFKeychainUtils getPasswordForUsername:username andServiceName:serverURL error:&error];
            
            // We could fail to retrieve the password for some reason
            if (error == nil) {
                didAttemptAutomaticLogin = YES;
                
                NSURLCredential *credential = [NSURLCredential credentialWithUser:username 
                                                                         password:password 
                                                                      persistence:NSURLCredentialPersistenceNone];
                
                [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
                
                [self finishedProcessingAuthenticationChallenge];                
            }
        }
        
        // If we've already tried these credentials once and they failed, or for some
        // reason we failed to retrieve our last known good credentials from the keystore
        if (!didAttemptAutomaticLogin && _numberOfFailedLoginAttemptsWithCurrentCredentials > 0) {
            
            VBXSessionExpiredController *controller = [_builder sessionExpiredController];
            controller.delegate = self;
            [controller presentAsPseudoModalViewController];
        
            controller.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                   challenge,
                                   @"challenge",
                                   nil];
        }
    }
    // We only handle SSL issues if we're past the Set Server screen.
    else if (serverURL != nil && [method isEqualToString:NSURLAuthenticationMethodServerTrust]) {
		
        // We only set this flag if we're actually going to do something with
        // this request.
        _isHandlingAuthenticationChallenge = YES;
        
        SecTrustResultType type = 0;    
        OSStatus status = SecTrustEvaluate(protectionSpace.serverTrust, &type);
        
        debug(@"type: %@", VBXStringForSecTrustResultType(type));
        BOOL requireTrustedCertificateForURL = [VBXTrustHelper serverURLRequiresTrustedCertificate:serverURL];
        BOOL lastAcceptedCertWasTrusted = [defaults boolForKey:VBXUserDefaultsLastAcceptedCertificateWasTrusted];
        NSData *lastAcceptedCertData = [defaults dataForKey:VBXUserDefaultsLastAcceptedCertificateData];
        NSData *certData = [VBXTrustHelper dataForFirstCertificate:protectionSpace.serverTrust];
        requireTrustedCertificateForURL = NO;
        PostSetupTrustAction action = [VBXTrustHelper actionForPostSetupCertificateIssueWithOSStatus:status 
																				  secTrustResultType:type 
																							certData:certData
																		requireTrustedCertForThisURL:requireTrustedCertificateForURL
                                                                          lastAcceptedCertWasTrusted:lastAcceptedCertWasTrusted
																				lastAcceptedCertData:lastAcceptedCertData];
		
        //
        // Cases:
        //
        // 1) Cert was OK and trusted during the initial setup, the server is in secure mode,
        // and now the certificate is untrusted.  Expectation:  Go to lock-down mode.  Show alert
        // stating what happened, and don't let the user do anything else but quit.
        //
        // 2) Cert was OK and trusted during the initial setup, the server is NOT in secure mode,
        // and now the certificate is untrusted.  Expectation: Show alert stating that the server
        // is now using an insecure certificate, and that the server might be compromised.
        //
        // 3) Cert was OK but untrusted during the initial setup, and now the certificate has changed
        // from the original untrusted certificate to another.  Expectation: Show alert stating that
        // the certificate has changed from one to another, and that the server might be compromised.
        //
        // 4) Cert was OK but untrusted during the intial setup, and now the certificate has changed
        // from an untrusted cert to a trusted cert.  Expectation: The user shouldn't see anything,
        // but there is an opportunity for us to switch from unsecure mode to secure mode.
        //
        
        if (PostSetupTrustActionDenyWithGenericError == action) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Invalid Certificate", @"App Delegate: Title for alert shown when server is in secure mode but is using an invalid cert.")
                                                            message:LocalizedString(@"The OpenVBX server you're connecting to is using an invalid certificate.  Please contact your OpenVBX service provider right away.", @"App Delegate: Title for alert shown when server is in secure mode but is using an invalid cert.")
                                                           delegate:nil 
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];                
        } else if (PostSetupTrustActionDenyWithSecureModeAlert == action) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Security Alert", @"App Delegate: Title for alert shown when server is in secure mode but is using an invalid cert.")
                                                            message:LocalizedString(@"The OpenVBX server you're connecting to is no longer using a valid secure certificate.  Please contact your OpenVBX service provider right away.", @"App Delegate: Title for alert shown when server is in secure mode but is using an invalid cert.")
                                                           delegate:nil 
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];                
        } else if (PostSetupTrustActionPromptWithCertificateIsNowUntrustedAlert == action) {
            VBXSecurityAlertController *controller = [_builder securityAlertController];
            controller.delegate = self;
            controller.tag = kAlertTagPromptWithCertificateIsNowUntrustedAlert;
            controller.headingText = @"Your OpenVBX server is no longer using a trusted secure certificate.";
            controller.descriptionText = 
            @"This could mean your OpenVBX service provider has been compromised. "
            @"Do not continue using OpenVBX until you have contacted your OpenVBX service provider and verified that "
            @"this was an expected change.  If you connect to a compromised server, you could be giving an attacker access to your "
            @"OpenVBX user account, messages, and password.";
            
            [controller presentAsPseudoModalViewController];
            
            controller.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                   challenge,
                                   @"challenge",
                                   protectionSpace,
                                   @"protectionSpace",
                                   nil];
			
        } else if (PostSetupTrustActionPromptWithUntrustedCertificateHasChangedAlert == action) {
            VBXSecurityAlertController *controller = [_builder securityAlertController];
            controller.delegate = self;
            controller.tag = kAlertTagPromptWithUntrustedCertificateHasChangedAlert;
            controller.headingText = @"Your OpenVBX server is using a different, untrusted secure certificate.";
            controller.descriptionText = 
            @"This could mean your OpenVBX service provider has been compromised. "
            @"Do not continue using OpenVBX until you have contacted your OpenVBX service provider and verified that "
            @"this was an expected change.  If you connect to a compromised server, you could be giving an attacker access to your "
            @"OpenVBX user account, messages, and password.";
            
            [controller presentAsPseudoModalViewController];
            
            controller.userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                   challenge,
                                   @"challenge",
                                   protectionSpace,
                                   @"protectionSpace",
                                   nil];
            
        } else if (PostSetupTrustActionAllow == action) {
            [VBXTrustHelper acceptCertificateAndRecordCertificateInfoWithChallenge:challenge serverTrust:protectionSpace.serverTrust];
            [self finishedProcessingAuthenticationChallenge];
        } else {
            // This can't happen!
            assert(0);
        }
    }
}

- (void)didReceiveAuthenticationChallenge:(NSNotification *)notification {    
    if (!_isHandlingAuthenticationChallenge) {
        // handle immediately
        [self processAuthenticationChallenge:[notification object]];
    } else {
        // queue it up - it'll get handled next
        [_authenticationChallenges addObject:[notification object]];
    }
}

- (void)showMainFlow {
    if (_setupNavigationController != nil) {
        [_setupNavigationController.view removeFromSuperview];
        self.setupNavigationController = nil;
    }
    
    VBXFolderListController *folderListController = [[[VBXFolderListController alloc] initWithNibName:@"FolderListController" bundle:nil] autorelease];
    [_builder configureFolderListController:folderListController];
    
    self.mainNavigationController = [[[VBXNavigationController alloc] initWithRootViewController:folderListController] autorelease];
    _mainNavigationController.builder = _builder;
    [_mainNavigationController setToolbarHidden:NO];
    
    [_configAccessor loadConfig];
    
    [_window addSubview:self.mainNavigationController.view];
    [_window makeKeyAndVisible];    
}

- (void)showSetupFlow {
    if (_mainNavigationController != nil) {
        [_mainNavigationController.view removeFromSuperview];
        self.mainNavigationController = nil;
    }
    
    self.setupNavigationController = [[[UINavigationController alloc] initWithRootViewController:(UIViewController *)[_builder setServerController]] autorelease];
    [_window addSubview:self.setupNavigationController.view];
    [_window makeKeyAndVisible];
}

- (void)sessionExpiredController:(VBXSessionExpiredController *)controller 
                  loginWithEmail:(NSString *)email 
                        password:(NSString *)password 
{
    [controller dismissPseudoModalViewController];
	
    NSURLAuthenticationChallenge *challenge = [controller.userInfo objectForKey:@"challenge"];
    
    NSString *serviceName = [[NSUserDefaults standardUserDefaults] stringForKey:VBXUserDefaultsBaseURL];
    
    NSError *error = nil;
    
    [SFHFKeychainUtils storeUsername:email 
                         andPassword:password 
                      forServiceName:serviceName 
                      updateExisting:YES 
                               error:&error];
    
    if (error != nil) {
        // We care, but even if this fails, it doesn't change what we do...
        debug(@"Error occurred while storing credentials in key chain: %@", error);
    }
	
    NSURLCredential *credential = [NSURLCredential credentialWithUser:email 
                                                             password:password 
                                                          persistence:NSURLCredentialPersistenceNone];
    
    [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
    
    [self finishedProcessingAuthenticationChallenge];
}

- (void)securityAlertDidAccept:(VBXSecurityAlertController *)securityAlert {
    if (securityAlert.tag == kAlertTagPromptWithCertificateIsNowUntrustedAlert) {
        NSDictionary *userInfo = securityAlert.userInfo;
		
        NSURLAuthenticationChallenge *challenge = [userInfo objectForKey:@"challenge"];
        NSURLProtectionSpace *protectionSpace = [userInfo objectForKey:@"protectionSpace"];        
		
        [VBXTrustHelper acceptCertificateAndRecordCertificateInfoWithChallenge:challenge serverTrust:protectionSpace.serverTrust];
		
        [self finishedProcessingAuthenticationChallenge];        
    }
}

- (void)securityAlertDidReject:(VBXSecurityAlertController *)securityAlert {
    if (securityAlert.tag == kAlertTagPromptWithCertificateIsNowUntrustedAlert) {
        NSDictionary *userInfo = securityAlert.userInfo;
        
        NSURLAuthenticationChallenge *challenge = [userInfo objectForKey:@"challenge"];
        
        // reject
        [challenge.sender cancelAuthenticationChallenge:challenge];
        
        [self finishedProcessingAuthenticationChallenge];
    }    
}


- (void)accessor:(VBXConfigAccessor *)accessor didLoadConfigDictionary:(NSDictionary *)dictionary hadTrustedCertificate:(BOOL)hadTrustedCertificate {
    [[VBXConfiguration sharedConfiguration] loadConfigFromDictionary:dictionary 
                                                           serverURL:[[_builder userDefaults] objectForKey:VBXUserDefaultsBaseURL]
                                               hadTrustedCertificate:hadTrustedCertificate];
    
}

- (void)accessor:(VBXConfigAccessor *)accessor loadFailedWithError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Error", @"App: Title for alert when config fails to load.")
                                                    message:LocalizedString(@"There was an error loading configuration information from the OpenVBX server.  Please contact your OpenVBX service provider.", @"App: Body for alert shown when configuration information fails to load.")
                                                   delegate:nil 
                                          cancelButtonTitle:LocalizedString(@"OK", nil) 
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];
}


@end
