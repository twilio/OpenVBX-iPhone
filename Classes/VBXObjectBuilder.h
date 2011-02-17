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

@class VBXFolderListAccessor;
@class VBXMessageListAccessor;
@class VBXMessageDetailAccessor;
@class VBXMessageAttributeAccessor;
@class VBXMessageAttribute;
@class VBXDialerAccessor;
@class VBXConfigAccessor;
@class VBXResourceLoader;
@class VBXFolderListController;
@class VBXMessageListController;
@class VBXAudioPlaybackController;
@class VBXMessageDetailController;
@class VBXMessageAttributeController;
@class VBXTextEntryController;
@class VBXDialerController;
@class VBXSettingsController;
@class VBXLoginController;
@class VBXSettingsController;
@class VBXSetServerController;
@class VBXLoginController;
@class VBXSetNumberController;
@class VBXCallerIdController;
@class VBXSendTextController;
@class VBXSecurityAlertController;
@class VBXSessionExpiredController;
@class VBXLicenseController;

@interface VBXObjectBuilder : NSObject {
}

+ (VBXObjectBuilder *)sharedBuilder;

- (NSBundle *)bundle;
- (NSUserDefaults *)userDefaults;
- (NSHTTPCookieStorage *)cookieStorage;
- (NSURLCredentialStorage *)credentialStorage;
- (NSFileManager *)fileManager;

- (NSMutableArray *)allCaches;

- (VBXFolderListAccessor *)folderListAccessor;
- (VBXMessageListAccessor *)messageListAccessorForFolderKey:(NSString *)key;
- (VBXMessageDetailAccessor *)messageDetailAccessorForKey:(NSString *)key;
- (VBXMessageAttributeAccessor *)messageAttributeAccessorForAttribute:(VBXMessageAttribute *)attribute;
- (VBXDialerAccessor *)dialerAccessor;
- (VBXConfigAccessor *)configAccessor;
- (VBXConfigAccessor *)configAccessorWithBaseURL:(NSString *)URL;
- (VBXResourceLoader *)resourceLoader;

- (void)configureFolderListController:(VBXFolderListController *)controller;

- (VBXMessageListController *)messageListControllerForFolderKey:(NSString *)key;
- (VBXAudioPlaybackController *)audioPlaybackControllerForURL:(NSString *)url;
- (VBXMessageDetailController *)messageDetailControllerForKey:(NSString *)key contentURL:(NSString *)contentURL messageListController:(VBXMessageListController *)messageListController;
- (VBXMessageAttributeController *)messageAttributeControllerForAttribute:(VBXMessageAttribute *)attribute;
- (VBXDialerController *)dialerController;
- (VBXDialerController *)dialerControllerWithPhone:(NSString *)phone;
- (UINavigationController *)navControllerWrapping:(UIViewController *)controller;
- (VBXSettingsController *)settingsController;
- (VBXLoginController *)loginController;
- (VBXSessionExpiredController *)sessionExpiredController;
- (VBXTextEntryController *)textEntryController;
- (VBXSetServerController *)setServerController;
- (VBXSetNumberController *)setNumberController;
- (VBXLicenseController *)setLicenseController;
- (VBXCallerIdController *)callerIdController;
- (VBXSendTextController *)sendTextController;
- (VBXSendTextController *)sendTextControllerWithPhone:(NSString *)phone;
- (VBXSecurityAlertController *)securityAlertController;

@end
