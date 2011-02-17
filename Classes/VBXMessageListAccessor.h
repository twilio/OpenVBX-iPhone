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

@class VBXFolderDetail;
@class VBXResourceLoader;

@protocol VBXMessageListAccessorDelegate;

@interface VBXMessageListAccessor : NSObject {
    NSString *_folderKey;
    NSInteger _pageSize;
    VBXFolderDetail *_model;
    VBXResourceLoader *_loader;
    VBXResourceLoader *_archivePoster;
    id<VBXMessageListAccessorDelegate> _delegate;
}

- (id)initWithKey:(NSString *)key;

@property (nonatomic, readonly) NSString *folderKey;
@property (nonatomic, assign) NSInteger pageSize;
@property (nonatomic, readonly, retain) VBXFolderDetail *model;
@property (nonatomic, retain) VBXResourceLoader *loader;
@property (nonatomic, retain) VBXResourceLoader *archivePoster;
@property (nonatomic, assign) id<VBXMessageListAccessorDelegate> delegate;

- (void)loadUsingCache:(BOOL)usingCache;
- (void)loadMore;
- (void)archiveMessageAtIndex:(NSInteger)index;

- (NSDate *)timestampOfCachedData;

- (void)removeMessageFromModelAtIndex:(NSInteger)index;

@end


@protocol VBXMessageListAccessorDelegate

- (void)accessorDidLoadData:(VBXMessageListAccessor *)accessor fromCache:(BOOL)fromCache;
- (void)accessor:(VBXMessageListAccessor *)accessor loadDidFailWithError:(NSError *)error;

- (void)accessor:(VBXMessageListAccessor *)accessor didArchiveMessageAtIndex:(NSInteger)index;
- (void)accessor:(VBXMessageListAccessor *)accessor archiveDidFailWithError:(NSError *)error;

@end
