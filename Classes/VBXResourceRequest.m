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

#import "VBXResourceRequest.h"
#import "VBXGlobal.h"

@implementation VBXResourceRequest

+ (VBXResourceRequest *)requestWithResource:(NSString *)resource {
    return [[[VBXResourceRequest alloc] initWithResource:resource method:nil] autorelease];
}

+ (VBXResourceRequest *)requestWithResource:(NSString *)resource method:(NSString*)method {
    return [[[VBXResourceRequest alloc] initWithResource:resource method:method] autorelease];
}

- (id)initWithResource:(NSString *)r method:(NSString*)m {
    if (self = [super init]) {
        _resource = [r retain];
        _method = [m retain];
        _params = [NSMutableDictionary new];
    }
    return self;
}

@synthesize resource = _resource;
@synthesize method = _method;
@synthesize params = _params;

- (void)dealloc {
    [_resource release];
    [_method release];
    [_params release];
    [super dealloc];
}

- (BOOL)isGet {
    return !_method || [_method isEqualToString:@"GET"];
}

- (BOOL)isPost {
    return [_method isEqualToString:@"POST"];
}

- (BOOL)isDelete {
    return [_method isEqualToString:@"DELETE"];
}

- (NSString *)paramString {
    NSMutableString *s = [NSMutableString string];
    for (NSString *name in [_params allKeys]) {
        if (s.length > 0) [s appendString:@"&"];
        NSString *value = [[_params objectForKey:name] description];
        [s appendFormat:@"%@=%@", name, [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    return s;
}

- (NSMutableURLRequest *)URLRequestWithBaseURL:(NSURL *)baseURL {
    NSString *urlString = nil;
    NSString *body = nil;
    if ([self isGet]) {
        NSMutableString *s = [NSMutableString stringWithString:_resource];
        if ([_params count] > 0) {
            [s appendString:@"?"];
            [s appendString:[self paramString]];
        }
        urlString = s;
    } else if ([self isPost] || [self isDelete]) {
        urlString = _resource;
        body = [self paramString];
    } else {
        debug(@"error: don't know how to make URL request for method %@", _method);
        return nil;
    }
    
    NSURL *url = [NSURL URLWithString:urlString relativeToURL:baseURL];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    if (_method) [urlRequest setHTTPMethod:_method];
    if (body) [urlRequest setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    return urlRequest;
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<ResourceRequest(%p): ", self];
    if (_method) [description appendFormat:@"%@ ", _method];
    [description appendString:_resource];
    if ([_params count] > 0) [description appendFormat:@"?%@", [self paramString]];
    [description appendString:@">"];
    return description;
}

@end
