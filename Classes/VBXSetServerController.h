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

#import <UIKit/UIKit.h>
#import "VBXTableViewController.h"

@class VBXConfigAccessor;
@class VBXTextFieldCell;
@class VBXSectionedCellDataSource;

@interface VBXSetServerController : VBXTableViewController {
    NSUserDefaults *_userDefaults;
    NSHTTPCookieStorage *_cookieStorage;
    NSURLCredentialStorage *_credentialStorage;
    NSArray *_allCaches;
    VBXConfigAccessor *_configAccessor;
    
    VBXSectionedCellDataSource *_cellDataSource;
    
    VBXTextFieldCell *_serverField;
    
    NSURLAuthenticationChallenge *_challenge;
    NSURLProtectionSpace *_protectionSpace;
}

@property (nonatomic, retain) NSUserDefaults *userDefaults;
@property (nonatomic, retain) NSHTTPCookieStorage *cookieStorage;
@property (nonatomic, retain) NSURLCredentialStorage *credentialStorage;
@property (nonatomic, retain) NSArray *allCaches;

@end
