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

#import "NSExtensions.h"
#import "VBXSublist.h"
#import "VBXUserDefaultsKeys.h"
#import "VBXGlobal.h"

@implementation NSString (Extensions)

- (NSString *)stringByDeletingCharactersInSet:(NSCharacterSet *)set {
    return [[self componentsSeparatedByCharactersInSet:set] componentsJoinedByString:@""];
}

- (NSString *)stringByDeletingNonDigits {
    return [self stringByDeletingCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
}

- (NSString *)stringByTrimmingWhitespace {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

@end


@implementation NSArray (Extensions)

+ (NSArray *)arrayWithDictionaries:(NSArray *)dictionaries class:(Class)class {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[dictionaries count]];
    for (NSDictionary *dictionary in dictionaries) {
        NSObject *object = [[[class alloc] initWithDictionary:dictionary] autorelease];
        [array addObject:object];
    }
    return array;
}

@end


@implementation NSDictionary (Extensions)

- (BOOL)containsKey:(NSString *)key {
    return [self objectForKey:key] != nil;
}

- (id)objectForKeyTranslatingNSNull:(id)key {
    id object = [self objectForKey:key];
    if ([object isKindOfClass:[NSNull class]]) return nil;
    return object;
}

- (id)objectForKey:(id)key ofClass:(Class)class {
    id object = [self objectForKeyTranslatingNSNull:key];
    if (!object) return nil;
    if (![object isKindOfClass:class]) {
        debug(@"error: expecting %@ for key %@ but got %@ %@", class, key, [object class], object);
        return nil;
    }
    return object;
}

- (id)objectForKey:(id)key respondingToSelector:(SEL)selector {
    id object = [self objectForKeyTranslatingNSNull:key];
    if (!object) return nil;
    if (![object respondsToSelector:selector]) {
        debug(@"error: got %@ %@ for key %@, doesn't respond to %@", [object class], object, key, NSStringFromSelector(selector));
        return nil;
    }
    return object;
}

- (int)intForKey:(id)key {
    id object = [self objectForKey:key respondingToSelector:@selector(intValue)];
    return [object intValue];
}

- (float)floatForKey:(id)key {
    id object = [self objectForKey:key respondingToSelector:@selector(floatValue)];
    return [object floatValue];
}

- (BOOL)boolForKey:(id)key {
    id object = [self objectForKey:key respondingToSelector:@selector(boolValue)];
    return [object boolValue];
}

- (NSString *)stringForKey:(id)key {
    return [[self objectForKeyTranslatingNSNull:key] description];
}

- (id)modelForKey:(id)key class:(Class)class {
    NSDictionary *dictionary = [self objectForKey:key ofClass:[NSDictionary class]];
    if (!dictionary) return nil;
    return [[[class alloc] initWithDictionary:dictionary] autorelease];
}

- (NSArray *)arrayOfModelsForKey:(id)key class:(Class)class {
    NSArray *dictionaries = [self objectForKey:key ofClass:[NSArray class]];
    if (!dictionaries) return nil;
    return [NSArray arrayWithDictionaries:dictionaries class:class];
}

- (VBXSublist *)sublistForKey:(id)key class:(Class)class {
    NSDictionary *dictionary = [self objectForKey:key ofClass:[NSDictionary class]];
    if (!dictionary) return nil;
    return [[[VBXSublist alloc] initWithDictionary:dictionary class:class] autorelease];
}

@end


@implementation NSMutableDictionary (Extensions)

- (void)setInt:(int)value forKey:(NSString *)key {
    [self setObject:[NSNumber numberWithInt:value] forKey:key];
}

- (void)setBool:(BOOL)value forKey:(NSString *)key {
    [self setObject:[NSNumber numberWithBool:value] forKey:key];
}

- (void)mergeWithContentsOfDictionary:(NSDictionary *)dict {
    for (NSString *key in [dict allKeys]) {
        if ([self containsKey:key]) {
            if ([[dict objectForKey:key] isKindOfClass:[NSDictionary class]] &&
                [[self objectForKey:key] isKindOfClass:[NSDictionary class]]) {
                
                NSMutableDictionary *newValue = [NSMutableDictionary dictionaryWithDictionary:[self objectForKey:key]];
                [newValue mergeWithContentsOfDictionary:[dict objectForKey:key]];
                
                [self setObject:newValue forKey:key];
            } else {
                // Just overwrite
                [self setObject:[dict objectForKey:key] forKey:key];
            }
        } else {
            [self setObject:[dict objectForKey:key] forKey:key];
        }
    }
}

@end


@implementation NSUserDefaults (Extensions)

- (NSURL *)VBXURLForKey:(NSString *)key {
    NSString *string = [self stringForKey:key];
    if (!string) return nil;
    return [NSURL URLWithString:string];
}

@end


@implementation NSError (Extensions)

+ (NSString *)descriptionForTwilioErrorCode:(VBXErrorCode)code {
    switch (code) {
        case VBXErrorNoNetwork:
            return @"You are not connected to the Internet. Please check your network connection and try again.";

        case VBXErrorBadHost:
            return @"Cannot find OpenVBX server. Please check your settings to make sure the server name is correct. "
                @"If so, please contact your OpenVBX service provider.";

        case VBXErrorLoginRequired:
            return @"You must log in to use OpenVBX.";
                
        case VBXErrorHTTPResponse:
        case VBXErrorBadJSON:
            return @"There was an error with the response received from the server. "
                @"Please contact your OpenVBX service provider, or try again later.";

        case VBXErrorBadAudioData:
            return @"There was an error with the audio data. "
                @"Please contact your OpenVBX service provider, or try again later.";

        default:
            return @"An error ocurred. Please contact your OpenVBX service provider, or try again later.";
    }
}

+ (NSError *)twilioErrorWithCode:(VBXErrorCode)code andObject:(id)object forKey:(NSString *)key {
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    NSString *description = [self descriptionForTwilioErrorCode:code];
    if (description) [userInfo setObject:description forKey:NSLocalizedDescriptionKey];
    if (object) [userInfo setObject:object forKey:key];
    return [NSError errorWithDomain:VBXErrorDomain code:code userInfo:userInfo];
}

+ (NSError *)twilioErrorWithCode:(VBXErrorCode)code underlyingError:(NSError *)error {
    return [self twilioErrorWithCode:code andObject:error forKey:NSUnderlyingErrorKey];
}

+ (NSError *)twilioErrorForHTTPErrorResponse:(NSHTTPURLResponse *)response {
    VBXErrorCode code = ([response statusCode] == 401)? VBXErrorLoginRequired : VBXErrorHTTPResponse;
    return [self twilioErrorWithCode:code andObject:response forKey:VBXErrorHTTPResponseKey];
}

+ (NSError *)twilioErrorForBadJSON:(NSString *)string {
    return [self twilioErrorWithCode:VBXErrorBadJSON andObject:string forKey:VBXErrorBadJSONStringKey];
}

+ (NSError *)twilioErrorForServerError:(NSString *)message {
    return [self twilioErrorWithCode:VBXErrorServerErrorMessage andObject:message forKey:VBXErrorServerErrorMessageKey];
}

- (BOOL)matchesDomain:(NSString *)domain code:(int)code {
    return [[self domain] isEqualToString:domain] && [self code] == code;
}

- (BOOL)isTwilioErrorWithCode:(VBXErrorCode)code {
    return [self matchesDomain:VBXErrorDomain code:code];
}

- (NSString *)detailedDescription {
    NSString *description = [NSString stringWithFormat:@"<%@:%p %@ %d \"%@\" failureReason=%@ recoveryOptions=%@ recoverySuggestion=%@ userInfo=%@>",
        [self class], self, [self domain], [self code], [self localizedDescription], [self localizedFailureReason],
        [self localizedRecoveryOptions], [self localizedRecoverySuggestion], [self userInfo]];
    NSError *underlyingError = [[self userInfo] objectForKey:@"NSUnderlyingError"];
    if (underlyingError) description = [description stringByAppendingFormat:@", underlying error: %@", [underlyingError detailedDescription]];
    return description;
}

@end


@implementation NSBundle (Extensions)

- (id)loadObjectFromNib:(NSString *)nibName ofType:(Class)class {
    NSArray *objects = [self loadNibNamed:nibName owner:nil options:nil];
    for (id object in objects) {
        if ([object isKindOfClass:class]) return object;
    }
    return nil;
}

@end


@implementation NSObject (Extensions)

- (id)performSelectorIfImplemented:(SEL)selector {
    if (![self respondsToSelector:selector]) return nil;
    return [self performSelector:selector];
}

- (id)performSelectorIfImplemented:(SEL)selector withObject:(id)object {
    if (![self respondsToSelector:selector]) return nil;
    return [self performSelector:selector withObject:object];
}

- (id)performSelectorIfImplemented:(SEL)selector withObject:(id)object1 withObject:(id)object2 {
    if (![self respondsToSelector:selector]) return nil;
    return [self performSelector:selector withObject:object1 withObject:object2];
}

- (NSInvocation *)invocationForSelector:(SEL)selector {
    if (![self respondsToSelector:selector]) return nil;
    NSMethodSignature *signature = [self methodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:self];
    [invocation setSelector:selector];
    return invocation;
}

@end


@implementation NSMethodSignature (Extensions)

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@:%p ", [self class], self];
    [description appendFormat:@"{%@ (", [NSString stringWithCString:[self methodReturnType] encoding:NSASCIIStringEncoding]];
    for (int i = 0; i < [self numberOfArguments]; i++) {
        if (i > 0) [description appendString:@", "];
        [description appendString:[NSString stringWithCString:[self getArgumentTypeAtIndex:i] encoding:NSASCIIStringEncoding]];
    }
    [description appendString:@")>"];
    return description;
}

@end


@implementation NSInvocation (Extensions)

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@:%p selector=%@ target=%@ signature=%@>", [self class], self,
        NSStringFromSelector([self selector]), [self target], [self methodSignature]];
}

@end
