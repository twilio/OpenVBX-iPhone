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

@class VBXResourceLoader;
@protocol VBXConfigAccessorDelegate;

@interface VBXConfigAccessor : NSObject {
    VBXResourceLoader *_loader;
    id<VBXConfigAccessorDelegate> _delegate;
}

@property (nonatomic, retain) VBXResourceLoader *loader;
@property (nonatomic, assign) id<VBXConfigAccessorDelegate> delegate;


- (void)loadDefaultConfig;
- (void)loadConfig;
- (void)loadConfigUsingCache:(BOOL)usingCache;

@end

@protocol VBXConfigAccessorDelegate <NSObject>

- (void)accessor:(VBXConfigAccessor *)accessor didLoadConfigDictionary:(NSDictionary *)dictionary hadTrustedCertificate:(BOOL)hadTrustedCertificate;
- (void)accessor:(VBXConfigAccessor *)accessor loadFailedWithError:(NSError *)error;

@end

