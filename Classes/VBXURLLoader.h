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

@class VBXPerfTimer;

@protocol VBXURLLoaderDelegate;

extern NSString *VBXURLLoaderDidStartLoading;
extern NSString *VBXURLLoaderDidFinishLoading;
extern NSString *VBXURLLoaderDidReceiveAuthenticationChallenge;

@interface VBXURLLoader : NSObject {
    NSURLRequest *_request;
    NSURLConnection *_connection;
    NSURLResponse *_response;
    NSMutableData *_data;
    NSInteger _contentLength;
    VBXPerfTimer *_perfTimer;
    BOOL _answersAuthChallenges;
    id<VBXURLLoaderDelegate> _delegate;
}

+ (VBXURLLoader *)loadRequest:(NSURLRequest *)request andInform:(id<VBXURLLoaderDelegate>)delegate answerAuthChallenges:(BOOL)answerAuthChallenges;
+ (VBXURLLoader *)loadRequestWithURLString:(NSString *)string andInform:(id<VBXURLLoaderDelegate>)delegate;

- (id)initWithURLRequest:(NSURLRequest *)request;

@property (nonatomic, readonly) NSURLRequest *request;
@property (nonatomic, readonly) NSData *data;
@property (nonatomic, readonly) NSInteger contentLength;
@property (nonatomic, readonly) NSInteger bytesReceived;
@property (nonatomic, readonly) float downloadProgress;
@property (nonatomic, assign) BOOL answersAuthChallenges;
@property (nonatomic, assign) id<VBXURLLoaderDelegate> delegate;
@property (nonatomic, readonly) BOOL hadTrustedCertificate;

- (void)load;
- (void)cancel;

@end


@protocol VBXURLLoaderDelegate <NSObject>

- (void)loader:(VBXURLLoader *)loader didFinishWithData:(NSData *)data;

@optional
- (void)loaderDidReceiveData:(VBXURLLoader *)loader;
- (void)loader:(VBXURLLoader *)loader didFailWithError:(NSError *)error;

@end
