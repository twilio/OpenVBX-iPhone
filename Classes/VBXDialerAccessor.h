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

@class VBXResult;
@class VBXResourceLoader;

@protocol VBXDialerAccessorDelegate;


@interface VBXDialerAccessor : NSObject {
    NSUserDefaults *_userDefaults;
    VBXResult *_callerIDsResult;
    VBXResourceLoader *_callerIDsLoader;
    VBXResourceLoader *_callPoster;
    id<VBXDialerAccessorDelegate> _delegate;
}

@property (nonatomic, retain) NSUserDefaults *userDefaults;
@property (nonatomic, readonly, retain) VBXResult *callerIDsResult;
@property (nonatomic, retain) VBXResourceLoader *callerIDsLoader;
@property (nonatomic, retain) VBXResourceLoader *callPoster;
@property (nonatomic, assign) id<VBXDialerAccessorDelegate> delegate;

@property (nonatomic, readonly) BOOL hasCallbackNumber;
@property (nonatomic, readonly) NSArray *callerIDs;

- (void)loadCallerIDs;
- (void)call:(NSString *)phone usingCallerID:(NSString *)callerID;

@end


@protocol VBXDialerAccessorDelegate <NSObject>

@optional
- (void)accessorDidPlaceCall:(VBXDialerAccessor *)accessor;
- (void)accessor:(VBXDialerAccessor *)accessor callFailedWithError:(NSError *)error;

- (void)accessorCallerIDsResponseArrived:(VBXDialerAccessor *)accessor fromCache:(BOOL)fromCache;
- (void)accessor:(VBXDialerAccessor *)accessor failedToLoadCallerIDsWithError:(NSError *)error;

@end
