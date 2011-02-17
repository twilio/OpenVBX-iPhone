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

@class VBXResourceRequest;
@class VBXCache;

@interface VBXResourceLoader : NSObject {
    NSMutableArray *_urlLoaders;
    id _target;
    SEL _successAction;
    SEL _errorAction;
    BOOL _answersAuthChallenges;
    VBXCache *_cache;
    NSUserDefaults *_userDefaults;
    NSURL *_baseURL;
}

+ (VBXResourceLoader *)loader;

@property (nonatomic, assign) id target;
@property (nonatomic, assign) SEL successAction;
@property (nonatomic, assign) SEL errorAction;
@property (nonatomic, assign) BOOL answersAuthChallenges;
@property (nonatomic, retain) VBXCache *cache;
@property (nonatomic, retain) NSUserDefaults *userDefaults;
@property (nonatomic, retain) NSURL *baseURL;

- (void)setTarget:(id)target successAction:(SEL)successAction;
- (void)setTarget:(id)target successAction:(SEL)successAction errorAction:(SEL)errorAction;

- (void)loadRequest:(VBXResourceRequest *)request;
- (void)loadRequest:(VBXResourceRequest *)request usingCache:(BOOL)usingCache;
- (void)cancelAllRequests;

- (NSURLRequest *)URLRequestForRequest:(VBXResourceRequest *)request;
- (NSString *)keyForRequest:(NSURLRequest *)request;

@end
