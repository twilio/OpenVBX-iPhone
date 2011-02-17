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

#import "VBXError.h"

@class VBXSublist;


@interface NSString (Extensions)

- (NSString *)stringByDeletingCharactersInSet:(NSCharacterSet *)set;

- (NSString *)stringByDeletingNonDigits;

- (NSString *)stringByTrimmingWhitespace;

@end


@interface NSArray (Extensions)

+ (NSArray *)arrayWithDictionaries:(NSArray *)dictionaries class:(Class)class;

@end


@interface NSDictionary (Extensions)

- (BOOL)containsKey:(NSString *)key;

- (id)objectForKeyTranslatingNSNull:(id)key;

- (id)objectForKey:(id)key ofClass:(Class)class;

- (id)objectForKey:(id)key respondingToSelector:(SEL)selector;

- (int)intForKey:(id)key;

- (float)floatForKey:(id)key;

- (BOOL)boolForKey:(id)key;

- (NSString *)stringForKey:(id)key;

- (id)modelForKey:(id)key class:(Class)class;

- (NSArray *)arrayOfModelsForKey:(id)key class:(Class)class;

- (VBXSublist *)sublistForKey:(id)key class:(Class)class;

@end


@interface NSMutableDictionary (Extensions)

- (void)setInt:(NSInteger)value forKey:(NSString *)key;

- (void)setBool:(BOOL)value forKey:(NSString *)key;

- (void)mergeWithContentsOfDictionary:(NSDictionary *)dict;

@end


@interface NSUserDefaults (Extensions)

- (NSURL *)VBXURLForKey:(NSString *)key;

@end


@interface NSError (Extensions)

+ (NSError *)twilioErrorWithCode:(VBXErrorCode)code underlyingError:(NSError *)error;

+ (NSError *)twilioErrorForHTTPErrorResponse:(NSHTTPURLResponse *)response;

+ (NSError *)twilioErrorForBadJSON:(NSString *)string;

+ (NSError *)twilioErrorForServerError:(NSString *)message;

- (BOOL)matchesDomain:(NSString *)domain code:(int)code;

- (BOOL)isTwilioErrorWithCode:(VBXErrorCode)code;

- (NSString *)detailedDescription;

@end


@interface NSBundle (Extensions)

- (id)loadObjectFromNib:(NSString *)nibName ofType:(Class)class;

@end



@interface NSObject (Extensions)

- (id)performSelectorIfImplemented:(SEL)selector;

- (id)performSelectorIfImplemented:(SEL)selector withObject:(id)object;

- (id)performSelectorIfImplemented:(SEL)selector withObject:(id)object1 withObject:(id)object2;

- (NSInvocation *)invocationForSelector:(SEL)selector;

@end


@interface NSMethodSignature (Extensions)

- (NSString *)description;

@end


@interface NSInvocation (Extensions)

- (NSString *)description;

@end
