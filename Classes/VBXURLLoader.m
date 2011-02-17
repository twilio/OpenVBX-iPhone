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

#import "VBXURLLoader.h"
#import "VBXPerfTimer.h"
#import "NSExtensions.h"
#import "NSURLExtensions.h"
#import "VBXGlobal.h"

NSString *VBXURLLoaderDidStartLoading = @"VBXURLLoaderDidStartLoading";
NSString *VBXURLLoaderDidFinishLoading = @"VBXURLLoaderDidFinishLoading";
NSString *VBXURLLoaderDidReceiveAuthenticationChallenge = @"VBXURLLoaderDidReceiveAuthenticationChallenge";

NSMutableArray *VBXURLLoaderTrustedServerNames = nil;

@interface VBXURLLoader ()

@property (nonatomic, retain) VBXPerfTimer *perfTimer;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSURLResponse *response;

@end

@implementation VBXURLLoader

+ (void)initialize {
    [super initialize];    
    VBXURLLoaderTrustedServerNames = [[NSMutableArray alloc] initWithCapacity:0];
}

+ (VBXURLLoader *)loadRequest:(NSURLRequest *)request andInform:(id<VBXURLLoaderDelegate>)delegate
answerAuthChallenges:(BOOL)answerAuthChallenges {
    VBXURLLoader *loader = [[[VBXURLLoader alloc] initWithURLRequest:request] autorelease];
    loader.answersAuthChallenges = answerAuthChallenges;
    loader.delegate = delegate;
    [loader load];
    return loader;
}

+ (VBXURLLoader *)loadRequestWithURLString:(NSString *)string andInform:(id<VBXURLLoaderDelegate>)delegate {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:string]];
    return [VBXURLLoader loadRequest:request andInform:delegate answerAuthChallenges:NO];
}

- (id)initWithURLRequest:(NSURLRequest *)req {
    if (self = [super init]) {
        //debug(@"%@", req);
        _request = [req retain];
        _connection = [[NSURLConnection alloc] initWithRequest:_request delegate:self];
        _data = [NSMutableData new];
    }
    return self;
}

@synthesize request = _request;
@synthesize connection = _connection;
@synthesize response = _response;
@synthesize data = _data;
@synthesize contentLength = _contentLength;
@synthesize perfTimer = _perfTimer;
@synthesize answersAuthChallenges = _answersAuthChallenges;
@synthesize delegate = _delegate;
@dynamic hadTrustedCertificate;

- (NSHTTPURLResponse *)HTTPResponse {
    return [_response isKindOfClass:[NSHTTPURLResponse class]]? (NSHTTPURLResponse *)_response : nil;
}

- (NSInteger)bytesReceived {
    return [_data length];
}

- (float)downloadProgress {
    if (_contentLength == 0) return -1.0;
    return ((float) self.bytesReceived) / _contentLength;
}

- (NSString *)serverName {
    return [NSString stringWithFormat:@"%@:%@", [_request.URL host], [_request.URL port]];
}

- (BOOL)hadTrustedCertificate {    
    if ([VBXURLLoaderTrustedServerNames containsObject:[self serverName]]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)dealloc {
    [_connection cancel];
    
    [_request release];
    [_connection release];
    [_response release];
    [_data release];
    [_perfTimer release];
    [super dealloc];
}

- (void)load {
    //trace();
    self.perfTimer = [VBXPerfTimer startTimer];
    [_connection start];
    [[NSNotificationCenter defaultCenter] postNotificationName:VBXURLLoaderDidStartLoading object:self];
}

- (void)cancel {
    //trace();
    if (!_connection) return;
    [_connection cancel];
    self.connection = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:VBXURLLoaderDidFinishLoading object:self];
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    //debug(@"%@", protectionSpace);
    NSString *method = [protectionSpace authenticationMethod];
    if ([method isEqualToString:NSURLAuthenticationMethodHTTPBasic]) return YES;
    else if ([method isEqualToString:NSURLAuthenticationMethodServerTrust]) return YES;
    else if ([method isEqualToString:NSURLAuthenticationMethodClientCertificate]) return NO;
    else return _answersAuthChallenges;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    //debug(@"%@", challenge);
    
    NSURLProtectionSpace *protectionSpace = [challenge protectionSpace];
    NSString *method = [protectionSpace authenticationMethod];    

    if ([method isEqualToString:NSURLAuthenticationMethodServerTrust]) {    
        SecTrustResultType type = 0;    
        OSStatus status = SecTrustEvaluate(protectionSpace.serverTrust, &type);
        
        NSString *serverName = [self serverName];
        
        if (status == noErr && type == kSecTrustResultUnspecified) {            
            if (![VBXURLLoaderTrustedServerNames containsObject:serverName]) {
                [VBXURLLoaderTrustedServerNames addObject:serverName];
            }
        } else {
            if ([VBXURLLoaderTrustedServerNames containsObject:serverName]) {
                [VBXURLLoaderTrustedServerNames removeObject:serverName];
            }            
        }
    }
        
    [[NSNotificationCenter defaultCenter] postNotificationName:VBXURLLoaderDidReceiveAuthenticationChallenge object:challenge];
}

-(NSURLRequest *)connection:(NSURLConnection *)connection
            willSendRequest:(NSURLRequest *)request
           redirectResponse:(NSURLResponse *)redirectResponse
{
    if (redirectResponse != nil) {
        debug(@"Redirected to URL: %@", [request URL]);
    }
	return request;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)r {
    self.response = r;
    NSHTTPURLResponse *httpResponse = [self HTTPResponse];
    if (httpResponse) {
        if ([httpResponse statusCode] != 200) {
            debug(@"%@", [_response detailedDescription]);
        }
        _contentLength = [[httpResponse allHeaderFields] intForKey:@"Content-Length"];
    }
	debug(@"%@", httpResponse);
    //debug(@"%@", [response detailedDescription]);
    [_data setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)d {
    //debug(@"%d bytes", [d length]);
    [_data appendData:d];
    if ([_delegate respondsToSelector:@selector(loaderDidReceiveData:)]) [_delegate loaderDidReceiveData:self];
}

- (void)finishWithError:(NSError *)error {
    if ([_delegate respondsToSelector:@selector(loader:didFailWithError:)])
        [_delegate loader:self didFailWithError:error];
    [[NSNotificationCenter defaultCenter] postNotificationName:VBXURLLoaderDidFinishLoading object:self];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    //debug(@"loaded %@ in %@", request, perfTimer);
    self.connection = nil;
    
    NSHTTPURLResponse *httpResponse = [self HTTPResponse];
    if (httpResponse && [httpResponse statusCode] >= 400) {
        [self finishWithError:[NSError twilioErrorForHTTPErrorResponse:httpResponse]];
        return;
    }
    
    [_delegate loader:self didFinishWithData:_data];
    [[NSNotificationCenter defaultCenter] postNotificationName:VBXURLLoaderDidFinishLoading object:self];
}

- (NSError *)wrappedErrorForConnectionError:(NSError *)cause {    
    VBXErrorCode code = VBXErrorUnknown;
    
    NSString *domain = [cause domain];
    if ([domain isEqualToString:NSURLErrorDomain]) {
        switch ([cause code]) {
            case NSURLErrorNotConnectedToInternet:
            case NSURLErrorTimedOut:
            case NSURLErrorNetworkConnectionLost:
                code = VBXErrorNoNetwork;
                break;
                
            case NSURLErrorCannotFindHost:
            case NSURLErrorDNSLookupFailed:
                code = VBXErrorBadHost;
                break;
                
            case NSURLErrorUserCancelledAuthentication:
            case NSURLErrorUserAuthenticationRequired:
                code = VBXErrorLoginRequired;
                break;
        }
    }
    
    return [NSError twilioErrorWithCode:code underlyingError:cause];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    debug(@"request=%@, error=%@", _request, error);
    self.connection = nil;
    [self finishWithError:[self wrappedErrorForConnectionError:error]];
}

@end
