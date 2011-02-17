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

#import "VBXDialerAccessor.h"
#import "VBXOutgoingPhone.h"
#import "VBXResourceRequest.h"
#import "VBXResourceLoader.h"
#import "UIExtensions.h"
#import "NSExtensions.h"
#import "VBXResult.h"
#import "VBXUserDefaultsKeys.h"
#import "VBXGlobal.h"

@interface VBXDialerAccessor ()

@property (nonatomic, retain) VBXResult *callerIDsResult;

@end


@implementation VBXDialerAccessor

@synthesize userDefaults = _userDefaults;
@synthesize callerIDsResult = _callerIDsResult;
@synthesize callerIDsLoader = _callerIDsLoader;
@synthesize callPoster = _callPoster;
@synthesize delegate = _delegate;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_callerIDsLoader cancelAllRequests];
    [_callPoster cancelAllRequests];
    
    self.userDefaults = nil;
    self.callerIDsResult = nil;
    self.callerIDsLoader = nil;
    self.callPoster = nil;
    [super dealloc];
}

- (NSString *)callbackNumber {
    NSString *phone = [_userDefaults stringForKey:VBXUserDefaultsCallbackPhone];
    return [phone stringByDeletingNonDigits];
}

- (BOOL)hasCallbackNumber {
    return [[self callbackNumber] length] > 0;
}

- (void)loadCallerIDs {
    self.callerIDsResult = nil;
    [_callerIDsLoader setTarget:self successAction:@selector(loader:didLoadCallerIDs:fromCache:)
        errorAction:@selector(loader:callerIDsFailedWithError:)];
    [_callerIDsLoader loadRequest:[VBXResourceRequest requestWithResource:@"numbers/outgoingcallerid"] usingCache:YES];
}

- (void)loader:(VBXResourceLoader *)loader didLoadCallerIDs:(NSArray *)response fromCache:(BOOL)fromCache {
    NSArray *callerIDs = [NSArray arrayWithDictionaries:response class:[VBXOutgoingPhone class]];
    self.callerIDsResult = [VBXResult resultWithObject:callerIDs];

    if ([_delegate respondsToSelector:@selector(accessorCallerIDsResponseArrived:fromCache:)]) {
        [_delegate accessorCallerIDsResponseArrived:self fromCache:fromCache];
    }
}

- (void)loader:(VBXResourceLoader *)loader callerIDsFailedWithError:(NSError *)error {
    debug(@"%@", [error detailedDescription]);
    if (_callerIDsResult.success) 
        // don't overwrite caller IDs from cache with an error
        return;    
    
    self.callerIDsResult = [VBXResult resultWithError:error];
    
    if ([_delegate respondsToSelector:@selector(accessor:failedToLoadCallerIDsWithError:)]) {
        [_delegate accessor:self failedToLoadCallerIDsWithError:error];
    }
}

- (NSArray *)callerIDs {
    return _callerIDsResult.object;
}

- (void)call:(NSString *)phone usingCallerID:(NSString *)callerID {
    phone = [phone stringByDeletingNonDigits];
    callerID = [callerID stringByDeletingNonDigits];

    VBXResourceRequest *request = [VBXResourceRequest requestWithResource:@"messages/call" method:@"POST"];
    [request.params setObject:phone forKey:@"to"];
    [request.params setObject:callerID forKey:@"callerid"];
    [request.params setObject:[self callbackNumber] forKey:@"from"];
    
    [_callPoster setTarget:self successAction:@selector(loader:didPlaceCall:)
        errorAction:@selector(loader:callFailedWithError:)];
    [_callPoster loadRequest:request];
}

- (void)loader:(VBXResourceLoader *)loader didPlaceCall:(NSDictionary *)response {
    // do something with the response? it might have a message
    if ([_delegate respondsToSelector:@selector(accessorDidPlaceCall:)]) {
        [_delegate accessorDidPlaceCall:self];
    }    
}

- (void)loader:(VBXResourceLoader *)loader callFailedWithError:(NSError *)error {
    if ([_delegate respondsToSelector:@selector(accessor:callFailedWithError:)]) {
        [_delegate accessor:self callFailedWithError:error];
    }
}

@end
