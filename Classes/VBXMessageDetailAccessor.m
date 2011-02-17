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

#import "VBXMessageDetailAccessor.h"
#import "VBXMessageDetail.h"
#import "VBXSublist.h"
#import "VBXAnnotation.h"
#import "VBXResourceLoader.h"
#import "VBXResourceRequest.h"
#import "NSExtensions.h"
#import "VBXCache.h"

@interface VBXMessageDetailAccessor ()

@property (nonatomic, retain) VBXMessageDetail *model;

@end


@implementation VBXMessageDetailAccessor

- (id)initWithKey:(NSString *)key {
    if (self = [super init]) {
        _messageKey = [key retain];
        _pageSize = 10;
    }
    return self;
}

@synthesize pageSize = _pageSize;
@synthesize model = _model;
@synthesize modelIsFromCache = _modelIsFromCache;
@synthesize detailLoader = _detailLoader;
@synthesize annotationsLoader = _annotationsLoader;
@synthesize notePoster = _notePoster;
@synthesize archivePoster = _archivePoster;
@synthesize delegate = _delegate;

- (void)dealloc {
    [_detailLoader cancelAllRequests];
    [_annotationsLoader cancelAllRequests];
    
    [_messageKey release];
    self.model = nil;
    self.detailLoader = nil;
    self.annotationsLoader = nil;
    self.notePoster = nil;
    [super dealloc];
}

- (NSDate *)timestampOfCachedData {
    NSString *resource = [@"messages/details/" stringByAppendingString:_messageKey];
    VBXResourceRequest *request = [VBXResourceRequest requestWithResource:resource];
    [request.params setInt:_pageSize forKey:@"max_annotations"];
    
    NSString *key = [_detailLoader keyForRequest:[_detailLoader URLRequestForRequest:request]];
    return [_detailLoader.cache timestampForDataForKey:key];
}

- (void)loadUsingCache:(BOOL)usingCache {
    NSString *resource = [@"messages/details/" stringByAppendingString:_messageKey];
    VBXResourceRequest *request = [VBXResourceRequest requestWithResource:resource];
    [request.params setInt:_pageSize forKey:@"max_annotations"];
    
    _detailLoader.target = self;
    [_detailLoader loadRequest:request usingCache:usingCache];
}

- (void)loadMoreAnnotations {
    NSString *resource = [NSString stringWithFormat:@"messages/details/%@/annotations", _messageKey];
    VBXResourceRequest *request = [VBXResourceRequest requestWithResource:resource];
    [request.params setInt:_model.annotations.last forKey:@"offset"];
    [request.params setInt:_pageSize forKey:@"max"];
    
    [_annotationsLoader setTarget:self successAction:@selector(loader:didFinishWithAnnotations:)];
    [_annotationsLoader loadRequest:request];
}

- (void)loader:(VBXResourceLoader *)loader didLoadObject:(NSDictionary *)object fromCache:(BOOL)fromCache {
    //debug(@"object=%@", object);
    self.model = [[[VBXMessageDetail alloc] initWithDictionary:object] autorelease];
    _modelIsFromCache = fromCache;
    [_delegate accessorDidLoadData:self fromCache:fromCache];
}

- (void)loader:(VBXResourceLoader *)loader didFinishWithAnnotations:(NSDictionary *)object {
    VBXSublist *a = [[[VBXSublist alloc] initWithDictionary:object class:[VBXAnnotation class]] autorelease];
    if (_model.annotations) [a mergeItemsFromBeginning:_model.annotations];
    _model.annotations = a;
    [_delegate accessorDidLoadData:self fromCache:NO];
}

- (void)loader:(VBXResourceLoader *)loader didFailWithError:(NSError *)error {
    [_delegate accessor:self loadDidFailWithError:error];
}

- (void)addNote:(NSString *)text {
    NSString *resource = [NSString stringWithFormat:@"messages/details/%@/annotations", _messageKey];
    VBXResourceRequest *request = [VBXResourceRequest requestWithResource:resource method:@"POST"];
    [request.params setObject:@"noted" forKey:@"annotation_type"];
    [request.params setObject:text forKey:@"description"];
    
    [_notePoster setTarget:self successAction:@selector(loader:didAddNote:)
        errorAction:@selector(loader:addNoteDidFailWithError:)];
    [_notePoster loadRequest:request];
}

- (void)loader:(VBXResourceLoader *)loader didAddNote:(NSDictionary *)response {
    //debug(@"%@", response);
    VBXAnnotation *annotation = [response modelForKey:@"annotation" class:[VBXAnnotation class]];
    [_model.annotations insertObject:annotation atIndex:0];
    [_delegate accessor:self didAddNote:annotation];
}

- (void)loader:(VBXResourceLoader *)loader addNoteDidFailWithError:(NSError *)error {
    [_delegate accessor:self addNoteDidFailWithError:error];
}

- (void)archiveMessage {
    NSString *resource = [NSString stringWithFormat:@"messages/details/%@", _messageKey];
    VBXResourceRequest *request = [VBXResourceRequest requestWithResource:resource method:@"POST"];
    [request.params setObject:@"true" forKey:@"archived"];
    
    [_archivePoster setTarget:self successAction:@selector(loader:didArchiveMessage:)
                 errorAction:@selector(loader:archiveDidFailWithError:)];
    [_archivePoster loadRequest:request];
}

- (void)loader:(VBXResourceLoader *)loader didArchiveMessage:(id)response {
    [_delegate accessorDidArchiveMessage:self];
}

- (void)loader:(VBXResourceLoader *)loader archiveDidFailWithError:(NSError *)error {
    [_delegate accessor:self archiveDidFailWithError:error];
}

@end
