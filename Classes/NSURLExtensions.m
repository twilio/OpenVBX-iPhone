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

#import "VBXConfiguration.h"
#import "NSURLExtensions.h"
#import "NSExtensions.h"
#import "VBXUserDefaultsKeys.h"


@implementation NSURLRequest (Extensions)

+ (NSString *)nameForCachePolicy:(NSURLRequestCachePolicy)policy {
    switch (policy) {
        case NSURLRequestUseProtocolCachePolicy: return @"UseProtocolCachePolicy";
        case NSURLRequestReloadIgnoringLocalCacheData: return @"ReloadIgnoringLocalCacheData";
        case NSURLRequestReloadIgnoringLocalAndRemoteCacheData: return @"ReloadIgnoringLocalAndRemoteCacheData";
        case NSURLRequestReturnCacheDataElseLoad: return @"ReturnCacheDataElseLoad";
        case NSURLRequestReturnCacheDataDontLoad: return @"ReturnCacheDataDontLoad";
        case NSURLRequestReloadRevalidatingCacheData: return @"ReloadRevalidatingCacheData";
        default: return nil;
    }
}

- (NSString *)description {
    NSString *cachePolicy = [NSURLRequest nameForCachePolicy:[self cachePolicy]];
    return [NSString stringWithFormat:@"<%@:%p method=%@ cachePolicy=%@ headers=%@>", [self class], self,
        [self HTTPMethod], cachePolicy, [self allHTTPHeaderFields]];
}

@end


@implementation NSURLResponse (Extensions)

- (NSString *)detailedDescription {
    return [self description];
}

@end


@implementation NSHTTPURLResponse (Extensions)

- (NSString *)description {
    NSInteger status = [self statusCode];
    NSString *statusMessage = [NSHTTPURLResponse localizedStringForStatusCode:status];
    return [NSString stringWithFormat:@"<%@:%p %d %@>", [self class], self, status, statusMessage];
}

- (NSString *)detailedDescription {
    NSInteger status = [self statusCode];
    NSString *statusMessage = [NSHTTPURLResponse localizedStringForStatusCode:status];
    return [NSString stringWithFormat:@"<%@:%p %d %@ headers=%@>", [self class], self, status, statusMessage, [self allHeaderFields]];
}

@end


@implementation NSCachedURLResponse (Extensions)

+ (NSString *)nameForStoragePolicy:(NSURLCacheStoragePolicy)policy {
    switch (policy) {
        case NSURLCacheStorageAllowed: return @"Allowed";
        case NSURLCacheStorageAllowedInMemoryOnly: return @"AllowedInMemoryOnly";
        case NSURLCacheStorageNotAllowed: return @"NotAllowed";
        default: return nil;
    }
}

- (NSString *)description {
    NSString *storagePolicy = [NSCachedURLResponse nameForStoragePolicy:[self storagePolicy]];
    return [NSString stringWithFormat:@"<%@:%p response=%@ storagePolicy=%@ userInfo=%@>", [self class], self,
        [self response], storagePolicy, [self userInfo]];
}

@end


@implementation NSURLCache (Extensions)

- (NSString *)description {
    static NSString *format = @"%d/%d (%.2g%%)";
    NSUInteger diskUsage = [self currentDiskUsage];
    NSUInteger diskCapacity = [self diskCapacity];
    NSUInteger memUsage = [self currentMemoryUsage];
    NSUInteger memCapacity = [self memoryCapacity];
    NSString *diskString = (diskCapacity > 0)? [NSString stringWithFormat:format,
        diskUsage, diskCapacity, diskUsage / (double)diskCapacity] : @"0";
    NSString *memString = (memCapacity > 0)? [NSString stringWithFormat:format,
        memUsage, memCapacity, memUsage / (double)memCapacity] : @"0";
    return [NSString stringWithFormat:@"<%@:%p, mem: %@, disk: %@>", [self class], self, memString, diskString];
}

@end


@implementation NSURLProtectionSpace (Extensions)

- (BOOL)matchesURL:(NSURL *)url {
    if (![[self protocol] isEqualToString:[url scheme]]) return NO;
    if (![[self host] isEqualToString:[url host]]) return NO;
    if ([url port]) {
        if ([self port] != [[url port] intValue]) return NO;
    }
    return YES;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@:%p %@://%@:%d realm=%@ method=%@>", [self class], self,
        [self protocol], [self host], [self port], [self realm], [self authenticationMethod]];
}

@end


@implementation NSURLAuthenticationChallenge (Extensions)

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@:%p error=%@ proposedCredential=%@ protectionSpace=%@ previousFailureCount=%d>",
        [self class], self, [self error], [self proposedCredential], [self protectionSpace], [self previousFailureCount]];
}

@end


@implementation NSURLCredentialStorage (Extensions)

- (NSArray *)protectionSpacesMatchingURL:(NSURL *)url realm:(NSString *)realm {
    NSMutableArray *spaces = [NSMutableArray array];
    for (NSURLProtectionSpace *space in [[self allCredentials] keyEnumerator]) {        
        if ([space matchesURL:url] && [[space realm] isEqualToString:realm]) [spaces addObject:space];
    }
    return spaces;
}

- (NSArray *)usernamesForProtectionSpaces:(NSArray *)spaces {
    NSMutableArray *usernames = [NSMutableArray array];
    for (NSURLProtectionSpace *space in spaces) {
        NSDictionary *credentials = [self credentialsForProtectionSpace:space];
        for (NSString *username in [credentials allKeys]) {
            if (![usernames containsObject:username]) [usernames addObject:username];
        }
    }
    return usernames;
}

- (void)removeCredentialsForProtectionSpace:(NSURLProtectionSpace *)space {
    if (!space) return;
    NSDictionary *credentials = [self credentialsForProtectionSpace:space];
    for (NSURLCredential *credential in [credentials allValues]) {
        [self removeCredential:credential forProtectionSpace:space];
    }
}

- (void)removeCredentialsForProtectionSpaces:(NSArray *)spaces {
    for (NSURLProtectionSpace *space in spaces) [self removeCredentialsForProtectionSpace:space];
}

@end


@implementation NSHTTPCookieStorage (Extensions)

- (void)deleteCookies:(NSArray *)cookies {
    for (NSHTTPCookie *cookie in cookies) {
        [self deleteCookie:cookie];
    }
}

- (void)deleteCookiesForURL:(NSURL *)url {
    [self deleteCookies:[self cookiesForURL:url]];
}

@end

@implementation NSURL (Extensions) 

- (NSDictionary *)queryComponents {
    NSMutableDictionary *dict = [[[NSMutableDictionary alloc] initWithCapacity:6] autorelease];
    NSArray *pairs = [[self query] componentsSeparatedByString:@"&"];
    
    for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        NSString *key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *val = @"";
     
        @try {
            val = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        } 
        @catch (NSException * e) {
            debug(@"Bad value pair");
        }
        
        [dict setObject:val forKey:key];
    }
    return dict;
}

@end
