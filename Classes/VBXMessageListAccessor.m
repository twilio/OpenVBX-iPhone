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

#import "VBXMessageListAccessor.h"
#import "VBXFolderDetail.h"
#import "VBXSublist.h"
#import "VBXMessageSummary.h"
#import "VBXResourceRequest.h"
#import "VBXResourceLoader.h"
#import "VBXCache.h"
#import "NSExtensions.h"


@interface VBXMessageListAccessor ()

@property (nonatomic, retain) VBXFolderDetail *model;

@end


@implementation VBXMessageListAccessor

- (id)initWithKey:(NSString *)key {
    if (self = [super init]) {
        _folderKey = [key retain];
        _pageSize = 25;
    }
    return self;
}

@synthesize folderKey = _folderKey;
@synthesize pageSize = _pageSize;
@synthesize model = _model;
@synthesize loader = _loader;
@synthesize archivePoster = _archivePoster;
@synthesize delegate = _delegate;

- (void)dealloc {
    [_loader cancelAllRequests];    
    [_folderKey release];
    [_model release];
    [_loader release];
    [_archivePoster release];
    [super dealloc];
}

- (NSDate *)timestampOfCachedData {
    NSString *resource = [NSString stringWithFormat:@"messages/inbox/%@", _folderKey];
    VBXResourceRequest *request = [VBXResourceRequest requestWithResource:resource];
    [request.params setInt:0 forKey:@"offset"];
    [request.params setInt:_pageSize forKey:@"max"];
    
    NSString *key = [_loader keyForRequest:[_loader URLRequestForRequest:request]];
    return [_loader.cache timestampForDataForKey:key];
}

- (void)loadFromOffset:(NSInteger)offset usingCache:(BOOL)usingCache {
    NSString *resource = [NSString stringWithFormat:@"messages/inbox/%@", _folderKey];
    VBXResourceRequest *request = [VBXResourceRequest requestWithResource:resource];
    [request.params setInt:offset forKey:@"offset"];
    [request.params setInt:_pageSize forKey:@"max"];
    
    _loader.target = self;
    [_loader loadRequest:request usingCache:usingCache];
}

- (void)loadUsingCache:(BOOL)usingCache {
    [self loadFromOffset:0 usingCache:usingCache];
}

- (void)loadMore {
    [self loadFromOffset:[_model.messages last] usingCache:NO];
}

- (void)loader:(VBXResourceLoader *)loader didLoadObject:(id)object fromCache:(BOOL)fromCache {
    VBXFolderDetail *newModel = [[[VBXFolderDetail alloc] initWithDictionary:object] autorelease];
    [newModel.messages mergeItemsFromBeginning:_model.messages];
    self.model = newModel;
    [_delegate accessorDidLoadData:self fromCache:fromCache];
}

- (void)loader:(VBXResourceLoader *)loader didFailWithError:(NSError *)error {
    [_delegate accessor:self loadDidFailWithError:error];
}

- (void)archiveMessageAtIndex:(NSInteger)index {
    self.model.archivingMessageIndex = index;
    VBXMessageSummary *summary = [self.model.messages objectAtIndex:index];
    summary.archiving = YES;
    
    NSString *resource = [NSString stringWithFormat:@"messages/details/%@", summary.key];
    VBXResourceRequest *request = [VBXResourceRequest requestWithResource:resource method:@"POST"];
    [request.params setObject:@"true" forKey:@"archived"];
    
    [_archivePoster setTarget:self successAction:@selector(loader:didArchiveMessage:)
        errorAction:@selector(loader:archiveDidFailWithError:)];
    [_archivePoster loadRequest:request];
}

- (void)removeMessageFromModelAtIndex:(NSInteger)index {
    [self.model.messages removeObjectAtIndex:index];    
    [_delegate accessor:self didArchiveMessageAtIndex:index];
}

- (void)loader:(VBXResourceLoader *)loader didArchiveMessage:(id)response {
    NSInteger index = self.model.archivingMessageIndex;
    self.model.archivingMessageIndex = NSNotFound;

    [self removeMessageFromModelAtIndex:index];
}

- (void)loader:(VBXResourceLoader *)loader archiveDidFailWithError:(NSError *)error {
    NSInteger index = self.model.archivingMessageIndex;
    self.model.archivingMessageIndex = NSNotFound;

    VBXMessageSummary *summary = [self.model.messages objectAtIndex:index];
    summary.archiving = NO;

    [_delegate accessor:self archiveDidFailWithError:error];
}

@end
