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

#import "VBXFolderListAccessor.h"
#import "VBXFolderList.h"
#import "VBXResourceRequest.h"
#import "VBXResourceLoader.h"
#import "VBXCache.h"


@interface VBXFolderListAccessor ()

@property (nonatomic, retain) VBXFolderList *model;

@end


@implementation VBXFolderListAccessor

@synthesize model = _model;
@synthesize loader = _loader;
@synthesize delegate = _delegate;

- (void)dealloc {
    [_loader cancelAllRequests];    
    [_model release];
    [_loader release];
    [super dealloc];
}

- (NSDate *)timestampOfCachedData {
    NSString *key = [_loader keyForRequest:[_loader URLRequestForRequest:[VBXResourceRequest requestWithResource:@"messages/inbox"]]];
    return [_loader.cache timestampForDataForKey:key];
}

- (void)loadUsingCache:(BOOL)usingCache {
    _loader.target = self;
    [_loader loadRequest:[VBXResourceRequest requestWithResource:@"messages/inbox"] usingCache:usingCache];
}

- (void)loader:(VBXResourceLoader *)loader didLoadObject:(id)object fromCache:(BOOL)fromCache {
    self.model = [[[VBXFolderList alloc] initWithDictionary:object] autorelease];
    [_delegate accessorDidLoadData:self fromCache:fromCache];
}

- (void)loader:(VBXResourceLoader *)loader didFailWithError:(NSError *)error {
    [_delegate accessor:self loadDidFailWithError:error];
}

@end
