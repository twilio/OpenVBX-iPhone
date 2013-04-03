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

#import "VBXConfigAccessor.h"
#import "VBXResourceRequest.h"
#import "VBXResourceLoader.h"
#import "NSExtensions.h"
#import "NSDictionary+merge.h"
#import "VBXGlobal.h"
#import "VBXConfiguration.h"

@implementation VBXConfigAccessor

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

@synthesize loader = _loader;
@synthesize delegate = _delegate;

- (void)dealloc {
    [_loader cancelAllRequests];
    self.loader = nil;
    [super dealloc];
}

- (NSDictionary *)defaultConfigDictionary {
    NSString* resourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"default-config.json"];
    NSData *defaultConfigData = [NSData dataWithContentsOfFile:resourcePath];
    
    NSError *error = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:defaultConfigData options:0 error:&error];
	
    return dict;
}

- (void)loadConfig {
    [self loadConfigUsingCache:YES];
}

- (void)loadConfigUsingCache:(BOOL)usingCache {
    _loader.target = self;
    _loader.successAction = @selector(loader:didLoadObject:fromCache:hadTrustedCertificate:);
    [_loader loadRequest:[VBXResourceRequest requestWithResource:@"client?with_i18n=1&type=iphone"] usingCache:usingCache];
}

- (void)loader:(VBXResourceLoader *)loader didLoadObject:(id)object fromCache:(BOOL)fromCache hadTrustedCertificate:(BOOL)hadTrustedCertificate {
    debug(@"%@", object);
	NSString *version = [object stringForKey:@"version"];
	if(!version)
		version = @"0.0"; // Could not find version, lets make it as old as it can be.
	NSDictionary *serverConfig = [NSDictionary dictionaryWithObject:version forKey:@"version"];
	
    if (_delegate != nil) {
        [_delegate accessor:self didLoadConfigDictionary:[NSDictionary dictionaryByMerging:serverConfig with:[self defaultConfigDictionary]] hadTrustedCertificate:(BOOL)hadTrustedCertificate];
    }
}

- (void)loader:(VBXResourceLoader *)loader didFailWithError:(NSError *)error {
    debug(@"%@", [error detailedDescription]);
    
    if (_delegate != nil) {
        [_delegate accessor:self loadFailedWithError:error];
    }
}

- (void)loadDefaultConfig {        
    [[VBXConfiguration sharedConfiguration] loadConfigFromDictionary:[self defaultConfigDictionary] serverURL:nil hadTrustedCertificate:NO];
}

@end
