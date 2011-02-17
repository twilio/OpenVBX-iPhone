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

#import "VBXObjectBuilder.h"

#import "VBXCache.h"
#import "VBXResourceLoader.h"
#import "VBXFolderListAccessor.h"
#import "VBXMessageListAccessor.h"
#import "VBXMessageDetailAccessor.h"
#import "VBXMessageAttributeAccessor.h"
#import "VBXDialerAccessor.h"
#import "VBXConfigAccessor.h"
#import "VBXFolderListController.h"
#import "VBXMessageListController.h"
#import "VBXMessageDetailController.h"
#import "VBXTextEntryController.h"
#import "VBXMessageAttributeController.h"
#import "VBXAudioPlaybackController.h"
#import "VBXDialerController.h"
#import "VBXSettingsController.h"
#import "VBXSetServerController.h"
#import "VBXLoginController.h"
#import "VBXLicenseController.h"
#import "VBXSetNumberController.h"
#import "VBXCallerIdController.h"
#import "VBXSendTextController.h"
#import "VBXSecurityAlertController.h"
#import "VBXSessionExpiredController.h"
#import "VBXError.h"

@implementation VBXObjectBuilder

+ (VBXObjectBuilder *)sharedBuilder {
    DECLARE_SINGLETON(VBXObjectBuilder, builder);
    builder = [VBXObjectBuilder new];
    return builder;
}

- (NSBundle *)bundle {
    return [NSBundle mainBundle];
}

- (NSUserDefaults *)userDefaults {
    return [NSUserDefaults standardUserDefaults];
}

- (NSHTTPCookieStorage *)cookieStorage {
    return [NSHTTPCookieStorage sharedHTTPCookieStorage];
}

- (NSURLCredentialStorage *)credentialStorage {
    return [NSURLCredentialStorage sharedCredentialStorage];
}

- (NSFileManager *)fileManager {
    return [NSFileManager defaultManager];
}

- (NSString *)cacheDirectory {
    DECLARE_SINGLETON(NSString, directory);
#if TARGET_IPHONE_SIMULATOR
    // the simulator re-installs the app each time you start it, so instead of the app-specific cache directory,
    // we just use /tmp for testing convenience
    NSString *systemCacheDirectory = NSTemporaryDirectory();
#else
    // cf. http://cocoawithlove.com/2009/07/temporary-files-and-folders-in-cocoa.html
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    if ([paths count] == 0) return nil;
    NSString *systemCacheDirectory = [paths objectAtIndex:0];
#endif
    NSString *bundleName = [[[self bundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    directory = [[systemCacheDirectory stringByAppendingPathComponent:bundleName] retain];
    return directory;
}

- (NSMutableArray *)allCaches {
    DECLARE_SINGLETON(NSMutableArray, allCaches);
    allCaches = [NSMutableArray new];
    return allCaches;
}

- (VBXCache *)newCacheWithDirectory:(NSString *)directory {
    NSString *mainDirectory = [self cacheDirectory];
    NSString *path = [mainDirectory stringByAppendingPathComponent:directory];
    VBXCache *cache = [[VBXCache alloc] initWithFileManager:[self fileManager] DirectoryPath:path];
    [[self allCaches] addObject:cache];
    return cache;
}

- (VBXCache *)mainCache {
    DECLARE_SINGLETON(VBXCache, cache);
    cache = [self newCacheWithDirectory:@"main"];
    cache.maxDiskEntries = 10;
    return cache;
}

- (VBXCache *)messageListCache {
    DECLARE_SINGLETON(VBXCache, cache);
    cache = [self newCacheWithDirectory:@"messageList"];
    cache.maxDiskEntries = 10;
    return cache;
}

- (VBXCache *)messageDetailCache {
    DECLARE_SINGLETON(VBXCache, cache);
    cache = [self newCacheWithDirectory:@"messageDetail"];
    cache.maxDiskEntries = 30;
    return cache;
}

- (VBXCache *)audioCache {
    DECLARE_SINGLETON(VBXCache, cache);
    cache = [self newCacheWithDirectory:@"audio"];
    cache.maxDiskEntries = 10;
    return cache;
}

- (VBXResourceLoader *)resourceLoaderWithCache:(VBXCache *)cache baseURL:(NSURL *)url; {
    VBXResourceLoader *loader = [VBXResourceLoader loader];
    loader.cache = cache;
    loader.userDefaults = [self userDefaults];
    loader.baseURL = url;
    return loader;
}

- (VBXResourceLoader *)resourceLoaderWithCache:(VBXCache *)cache {
    return [self resourceLoaderWithCache:cache baseURL:nil];
}

- (VBXResourceLoader *)resourceLoader {
    return [self resourceLoaderWithCache:nil];
}

- (VBXFolderListAccessor *)folderListAccessor {
    VBXFolderListAccessor *accessor = [[VBXFolderListAccessor new] autorelease];    
    accessor.loader = [self resourceLoaderWithCache:[self mainCache]];
    return accessor;
}

- (VBXMessageListAccessor *)messageListAccessorForFolderKey:(NSString *)key {
    VBXMessageListAccessor *accessor = [[[VBXMessageListAccessor alloc] initWithKey:key] autorelease];
    accessor.loader = [self resourceLoaderWithCache:[self messageListCache]];
    accessor.archivePoster = [self resourceLoader];
    return accessor;
}

- (VBXMessageDetailAccessor *)messageDetailAccessorForKey:(NSString *)key {
    VBXMessageDetailAccessor *accessor = [[[VBXMessageDetailAccessor alloc] initWithKey:key] autorelease];
    accessor.detailLoader = [self resourceLoaderWithCache:[self messageDetailCache]];
    accessor.annotationsLoader = [self resourceLoader];
    accessor.notePoster = [self resourceLoader];
    accessor.archivePoster = [self resourceLoader];
    return accessor;
}

- (VBXMessageAttributeAccessor *)messageAttributeAccessorForAttribute:(VBXMessageAttribute *)attribute {
    VBXMessageAttributeAccessor *accessor = [[[VBXMessageAttributeAccessor alloc] initWithAttribute:attribute] autorelease];
    accessor.valuePoster = [self resourceLoader];
    return accessor;
}

- (VBXDialerAccessor *)dialerAccessor {
    DECLARE_SINGLETON(VBXDialerAccessor, accessor);
    accessor = [VBXDialerAccessor new];
    accessor.userDefaults = [self userDefaults];
    accessor.callerIDsLoader = [self resourceLoaderWithCache:[self mainCache]];
    accessor.callPoster = [self resourceLoader];
    return accessor;
}

- (VBXConfigAccessor *)configAccessor {
    VBXConfigAccessor *accessor = [VBXConfigAccessor new];
    accessor.loader = [self resourceLoaderWithCache:[self mainCache]];
    accessor.loader.answersAuthChallenges = YES;
    return [accessor autorelease];
}

- (VBXConfigAccessor *)configAccessorWithBaseURL:(NSString *)URL {
    VBXConfigAccessor *accessor = [VBXConfigAccessor new];
    accessor.loader = [self resourceLoaderWithCache:[self mainCache] baseURL:[NSURL URLWithString:URL]];
    accessor.loader.answersAuthChallenges = YES;
    return [accessor autorelease];
}

- (void)configureFolderListController:(VBXFolderListController *)controller {
    controller.userDefaults = [self userDefaults];
    controller.accessor = [self folderListAccessor];
    controller.builder = self;
}

- (VBXMessageListController *)messageListControllerForFolderKey:(NSString *)key {
    VBXMessageListController *controller = [[[VBXMessageListController alloc] initWithNibName:@"MessageListController" bundle:nil] autorelease];
    controller.userDefaults = [self userDefaults];
    controller.accessor = [self messageListAccessorForFolderKey:key];
    controller.bundle = [self bundle];
    controller.builder = self;
    return controller;
}

- (VBXAudioPlaybackController *)audioPlaybackControllerForURL:(NSString *)url {
    VBXAudioPlaybackController *controller = [[[VBXAudioPlaybackController alloc] init] autorelease]; 
    controller.userDefaults = [self userDefaults];
    controller.contentURL = url;
    controller.cache = [self audioCache];
    return controller;
}

- (VBXMessageDetailController *)messageDetailControllerForKey:(NSString *)key contentURL:(NSString *)contentURL messageListController:(VBXMessageListController *)messageListController {
    VBXMessageDetailController *controller = [[[VBXMessageDetailController alloc] initWithNibName:@"MessageDetailController" bundle:nil] autorelease];
    controller.userDefaults = [self userDefaults];
    controller.accessor = [self messageDetailAccessorForKey:key];
    controller.dialerAccessor = [self dialerAccessor];		
    controller.playbackController = [self audioPlaybackControllerForURL:contentURL];
    controller.messageListController = messageListController;
    controller.builder = self;
    controller.bundle = [self bundle];
    return controller;
}


- (VBXMessageAttributeController *)messageAttributeControllerForAttribute:(VBXMessageAttribute *)attribute {
    VBXMessageAttributeController *controller = [[[VBXMessageAttributeController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
    controller.attribute = attribute;
    controller.accessor = [self messageAttributeAccessorForAttribute:attribute];
    return controller;
}

- (VBXDialerController *)dialerControllerWithPhone:(NSString *)phone {
    VBXDialerController *controller = [[[VBXDialerController alloc] initWithPhone:phone] autorelease];
    controller.accessor = [self dialerAccessor];
    controller.userDefaults = [self userDefaults];
    return controller;
}

- (VBXDialerController *)dialerController {
    return [self dialerControllerWithPhone:@""];
}

- (UINavigationController *)navControllerWrapping:(UIViewController *)controller {
    UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:controller] autorelease];
    navController.navigationBar.tintColor = ThemedColor(@"navigationBarTintColor", RGBHEXCOLOR(0x8094ae));
    return navController;
}

- (VBXSettingsController *)settingsController {
    VBXSettingsController *controller = [[[VBXSettingsController alloc] init] autorelease];
    controller.builder = self;
    controller.userDefaults = [self userDefaults];
    controller.configAccessor = [self configAccessor];
    return controller;
}

- (VBXLoginController *)loginController {
    VBXLoginController *controller = [[[VBXLoginController alloc] init] autorelease];
    controller.loader = [self resourceLoader];
    controller.userDefaults = [self userDefaults];
    controller.credentialStorage = [self credentialStorage];    
    return controller;
}

- (VBXSessionExpiredController *)sessionExpiredController {
    VBXSessionExpiredController *controller = [[[VBXSessionExpiredController alloc] init] autorelease];
    controller.userDefaults = [self userDefaults];
    controller.builder = self;
    return controller;
}

- (VBXTextEntryController *)textEntryController {
    VBXTextEntryController *controller = [[[VBXTextEntryController alloc] initWithNibName:@"TextEntryController" bundle:nil] autorelease];
    return controller;
}

- (VBXSetServerController *)setServerController {
    VBXSetServerController *controller = [[[VBXSetServerController alloc] init] autorelease];
    controller.userDefaults = [self userDefaults];
    controller.cookieStorage = [self cookieStorage];
    controller.credentialStorage = [self credentialStorage];
    controller.allCaches = [self allCaches];
    return controller;
}

- (VBXSetNumberController *)setNumberController {
    VBXSetNumberController *controller = [[[VBXSetNumberController alloc] init] autorelease];
    controller.userDefaults = [self userDefaults];
    return controller;
}

- (VBXLicenseController *)setLicenseController {
	/* Read from local license file */
	VBXLicenseController *controller = [[[VBXLicenseController alloc] init] autorelease];
	//controller.userDefaults = [self userDefaults];
	return controller;
}

- (VBXCallerIdController *)callerIdController {
    VBXCallerIdController *controller = [[[VBXCallerIdController alloc] init] autorelease];
    controller.userDefaults = [self userDefaults];
    controller.accessor = [self dialerAccessor];    
    return controller;
}

- (VBXSendTextController *)sendTextController {
    return [self sendTextControllerWithPhone:@""];
}

- (VBXSendTextController *)sendTextControllerWithPhone:(NSString *)phone {
    VBXSendTextController *controller = [[[VBXSendTextController alloc] initWithPhone:phone] autorelease];
    controller.userDefaults = [self userDefaults];
    controller.sendTextPoster = [self resourceLoader];
    return controller;
}

- (VBXSecurityAlertController *)securityAlertController {
    VBXSecurityAlertController *controller = [[[VBXSecurityAlertController alloc] init] autorelease];
    controller.builder = self;
    return controller;
}

@end
