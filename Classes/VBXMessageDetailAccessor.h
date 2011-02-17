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

@class VBXMessageDetail;
@class VBXResourceLoader;

@protocol VBXMessageDetailAccessorDelegate;


@interface VBXMessageDetailAccessor : NSObject {
    NSString *_messageKey;
    NSInteger _pageSize;
    VBXMessageDetail *_model;
    BOOL _modelIsFromCache;
    VBXResourceLoader *_detailLoader;
    VBXResourceLoader *_annotationsLoader;
    VBXResourceLoader *_notePoster;
    VBXResourceLoader *_archivePoster;    
    id<VBXMessageDetailAccessorDelegate> _delegate;
}

- (id)initWithKey:(NSString *)key;

@property (nonatomic, assign) NSInteger pageSize;
@property (nonatomic, retain, readonly) VBXMessageDetail *model;
@property (nonatomic, assign, readonly) BOOL modelIsFromCache;
@property (nonatomic, retain) VBXResourceLoader *detailLoader;
@property (nonatomic, retain) VBXResourceLoader *annotationsLoader;
@property (nonatomic, retain) VBXResourceLoader *notePoster;
@property (nonatomic, retain) VBXResourceLoader *archivePoster;
@property (nonatomic, assign) id<VBXMessageDetailAccessorDelegate> delegate;

- (void)loadUsingCache:(BOOL)usingCache;
- (void)loadMoreAnnotations;
- (void)addNote:(NSString *)text;

- (NSDate *)timestampOfCachedData;

- (void)archiveMessage;

@end


@protocol VBXMessageDetailAccessorDelegate

- (void)accessorDidLoadData:(VBXMessageDetailAccessor *)accessor fromCache:(BOOL)fromCache;
- (void)accessor:(VBXMessageDetailAccessor *)accessor loadDidFailWithError:(NSError *)error;

- (void)accessor:(VBXMessageDetailAccessor *)accessor didAddNote:(id)annotation;
- (void)accessor:(VBXMessageDetailAccessor *)accessor addNoteDidFailWithError:(NSError *)error;

- (void)accessorDidArchiveMessage:(VBXMessageDetailAccessor *)accessor;
- (void)accessor:(VBXMessageDetailAccessor *)accessor archiveDidFailWithError:(NSError *)error;


@end
