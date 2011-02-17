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

@class VBXFolderList;
@class VBXResourceLoader;

@protocol VBXFolderListAccessorDelegate;


@interface VBXFolderListAccessor : NSObject {
    VBXFolderList *_model;
    VBXResourceLoader *_loader;
    id<VBXFolderListAccessorDelegate> _delegate;
}

@property (nonatomic, readonly, retain) VBXFolderList *model;
@property (nonatomic, retain) VBXResourceLoader *loader;
@property (nonatomic, assign) id<VBXFolderListAccessorDelegate> delegate;

- (void)loadUsingCache:(BOOL)usingCache;

- (NSDate *)timestampOfCachedData;

@end

@protocol VBXFolderListAccessorDelegate

- (void)accessorDidLoadData:(VBXFolderListAccessor *)accessor fromCache:(BOOL)fromCache;
- (void)accessor:(VBXFolderListAccessor *)accessor loadDidFailWithError:(NSError *)error;

@end
