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

#import <Foundation/Foundation.h>


@interface NSURLRequest (Extensions)

+ (NSString *)nameForCachePolicy:(NSURLRequestCachePolicy)policy;

- (NSString *)description;

@end


@interface NSURLResponse (Extensions)

- (NSString *)detailedDescription;

@end


@interface NSHTTPURLResponse (Extensions)

- (NSString *)description;

- (NSString *)detailedDescription;

@end


@interface NSCachedURLResponse (Extensions)

+ (NSString *)nameForStoragePolicy:(NSURLCacheStoragePolicy)policy;

- (NSString *)description;

@end


@interface NSURLCache (Extensions)

- (NSString *)description;

@end


@interface NSURLProtectionSpace (Extensions)

- (BOOL)matchesURL:(NSURL *)url;

- (NSString *)description;

@end


@interface NSURLAuthenticationChallenge (Extensions)

- (NSString *)description;

@end


@interface NSURLCredentialStorage (Extensions)

- (NSArray *)protectionSpacesMatchingURL:(NSURL *)url realm:(NSString *)realm;
- (NSArray *)usernamesForProtectionSpaces:(NSArray *)spaces;
- (void)removeCredentialsForProtectionSpace:(NSURLProtectionSpace *)space;
- (void)removeCredentialsForProtectionSpaces:(NSArray *)spaces;

@end


@interface NSHTTPCookieStorage (Extensions)

- (void)deleteCookies:(NSArray *)cookies;
- (void)deleteCookiesForURL:(NSURL *)url;

@end

@interface NSURL (Extensions)

- (NSDictionary *)queryComponents;

@end

