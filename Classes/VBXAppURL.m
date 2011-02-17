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

#import "VBXAppDelegate.h"
#import "VBXGlobal.h"
#import "VBXAppURL.h"
#import "VBXObjectBuilder.h"
#import "NSExtensions.h"
#import "NSURLExtensions.h"
#import "VBXUserDefaultsKeys.h"
#import "VBXConfiguration.h"

@implementation VBXAppURL

@synthesize host = _host;
@synthesize queryComponents = _queryComponents;
@synthesize pathComponents = _pathComponents;

+ (NSDictionary*)route:(NSURL*)launchURL {
	
    VBXAppURL* appURL = [[VBXAppURL alloc] init];
    appURL.host = [launchURL host];
    appURL.queryComponents = [launchURL queryComponents];
    appURL.pathComponents = [launchURL pathComponents];
    
    NSMutableDictionary* urlState = [[NSMutableDictionary alloc] init];
    
    NSArray *controllerStates = [[NSMutableArray alloc] init];
    NSString *route = @"";
    if ([appURL.pathComponents count] > 1) {
        route = [appURL.pathComponents objectAtIndex:1];
    }

    /* User Routes */
    VBXObjectBuilder *builder = [VBXObjectBuilder sharedBuilder];

    if ([[[builder userDefaults] objectForKey:VBXUserDefaultsCompletedSetup] boolValue]) {
        if([route compare:@"messages" options:NSCaseInsensitiveSearch] == 0) {
            controllerStates = [appURL routeMessages];
        }
    }
	
    /* Public Routes */
    if([route compare:@"setup" options:NSCaseInsensitiveSearch] == 0) {
        controllerStates = [appURL routeSetup];
    }
	
    if ([controllerStates count] >= 1) {
        [urlState setObject:controllerStates forKey:@"controllerStates"];
    }
	
	return urlState;
}

- (NSArray*)routeSetup {
    // Routes all /setup queries and checks to see if a user is already setup. 
    // A prompt is displayed in the case of someone logged in.
    VBXObjectBuilder *builder = [VBXObjectBuilder sharedBuilder];
    NSMutableArray *controllerStates = [NSMutableArray array];
    
    if ([[[builder userDefaults] objectForKey:VBXUserDefaultsCompletedSetup] boolValue]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"You are already signed in", @"Send Text: Title for alert when user wants to change their login.")
                                                    message:LocalizedString(@"Are you sure you want change your OpenVBX login?", @"Send Text: Body for alert when user wants to change their login.")
                                                   delegate:self 
                                          cancelButtonTitle:LocalizedString(@"No", nil)
                                              otherButtonTitles:LocalizedString(@"Yes", nil), nil];
        [alert show];
        [alert release];
        return controllerStates;
    }

    [self _routeSetup];
    
    return controllerStates;
}

- (void)_routeSetup {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *queryComponents = self.queryComponents;

    NSString *defaultEmail = @"";
    NSString *defaultPhone = @"";
    NSString *baseURLString = @"";
    
    if ([[queryComponents objectForKey:@"server"] length] > 0) {
        baseURLString = [queryComponents stringForKey:@"server"];
    }
    
    if ([[queryComponents objectForKey:@"email"] length] > 0) {
        defaultEmail = [queryComponents stringForKey:@"email"];
    }

    if ([[queryComponents objectForKey:@"phone"] length] > 0) {
        defaultPhone = [queryComponents stringForKey:@"phone"];
    }
    
    if (baseURLString && [defaultEmail length] > 0) {
        VBXClearAllData();
        
        [defaults setValue:baseURLString forKey:VBXUserDefaultsBaseURL];    
        [defaults setValue:defaultEmail forKey:VBXUserDefaultsEmailAddress];
        [defaults setValue:defaultPhone forKey:VBXUserDefaultsCallbackPhone];
        [defaults setBool:YES forKey:VBXUserDefaultsAutoconfigure];
        VBXAppDelegate *appDelegate = (VBXAppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate showSetupFlow];
    }    
}

- (NSArray*)routeMessages {
    NSDictionary *queryComponents = self.queryComponents;
    NSMutableArray *controllerStates = [NSMutableArray array];
    NSDictionary *queryArgs = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"selectedFolderKey", @"folderId",
                               @"selectedMessageKey", @"messageId", 
                               @"navigationItem.title", @"folderName", 
                               @"selectedMessageRecordingURL", @"recordingURL",
                               nil];	
	
    if ([[queryComponents objectForKey:@"folderId"] length] > 0) {
        NSDictionary *folderState = [NSDictionary dictionaryWithObject:[queryComponents objectForKey:@"folderId"]
                                                                forKey: @"selectedFolderKey"];
        [controllerStates addObject:folderState];
    }
	
    if ([[queryComponents objectForKey:@"messageId"] length] > 0) {
        NSMutableDictionary *messageState = [[NSMutableDictionary alloc] init];	
        for (id key in queryArgs) {
            if ([queryComponents containsKey:key]) {
                [messageState setObject:[queryComponents objectForKey:key] forKey:[queryArgs valueForKey:key]];
            } else {	
                [messageState setObject:@"" forKey:[queryArgs valueForKey:key]];
            }
        }
        [controllerStates addObject:messageState];
    }
	
    return controllerStates;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self _routeSetup];
    }
}



@end
