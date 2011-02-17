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
#import "VBXGlobal.h"

VBXHSL ThemedHSL(NSString *key, VBXHSL defaultHSL);
UIColor *ThemedColor(NSString *key, UIColor *defaultValue);
UIImage *ThemedImage(NSString *key, NSString *localFileName);

/**
 * Just like NSLocalizedString, but pulls from our strings dictionary instead of using the normal localization
 * machinery.
 */
NSString *LocalizedString(NSString *str, NSString *comment);


@protocol VBXConfigurable;

@interface VBXConfiguration : NSObject {
    NSMutableArray *_observers;
    NSMutableDictionary *_dict;
}

+ (VBXConfiguration *)sharedConfiguration;

- (void)loadConfigFromDictionary:(NSDictionary *)dict serverURL:(NSString *)serverURL hadTrustedCertificate:(BOOL)hadTrustedCertificate;
- (NSDictionary *)dictionary;

/**
 * Adds the observer to a list of observers that will be notified whenever
 * a new configuration is loaded.
 */
- (void)addConfigObserver:(id<VBXConfigurable>)observer;

/**
 * Removes the obeserver from the list of observers that get notified
 * when a new configuration is loaded.
 */ 
- (void)removeConfigObserver:(id<VBXConfigurable>)observer;

- (NSString *)localizedStringForKey:(NSString *)key;
- (NSString *)localizedStringForKey:(NSString *)key defaultValue:(NSString *)defaultValue;
- (UIColor *)colorForKey:(NSString *)key;
- (UIColor *)colorForKey:(NSString *)key defaultValue:(UIColor *)defaultValue;
- (VBXHSL)HSLForKey:(NSString *)key defaultHSL:(VBXHSL)defaultHSL;
- (UIStatusBarStyle)statusBarStyleForKey:(NSString *)key defaultValue:(UIStatusBarStyle)defaultValue;
- (UITableViewCellSelectionStyle)tableViewCellSelectionStyleForKey:(NSString *)key defaultValue:(UIStatusBarStyle)defaultValue;
- (UIImage *)imageForKey:(NSString *)key defaultImageFileName:(NSString *)defaultImageFileName;

@end

@protocol VBXConfigurable <NSObject>
@required
/**
 * Called after a new configuration has been loaded.  Implementations should re-assign whatever
 * colors or style attributes they're using, as well as reload any strings.
 */
- (void)applyConfig;

@end