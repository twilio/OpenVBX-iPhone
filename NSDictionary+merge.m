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

#import "NSDictionary+merge.h"

@implementation NSDictionary (merge)

+ (NSDictionary *) dictionaryByMerging: (NSDictionary *) dict1 with: (NSDictionary *) dict2 {
    NSMutableDictionary * result = [NSMutableDictionary dictionary];
	
    [dict2 enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
		// If object is a dictionary and dict1 contains key with a value, set the object 
        if ([obj isKindOfClass: [NSDictionary class]] && [dict1 containsSomethingForKey: key]) {
            NSDictionary * newVal = [[dict1 objectForKey: key] dictionaryByMergingWith: (NSDictionary *) obj];
            [result setObject: newVal forKey: key];
        } else if (![dict1 containsSomethingForKey: key]) {
            [result setObject: obj forKey: key];
        } else {
            [result setObject: [dict1 objectForKey: key] forKey: key];
        }
    }];
	
    return (NSDictionary *) [[result mutableCopy] autorelease];
}

- (NSDictionary *) dictionaryByMergingWith: (NSDictionary *) dict {
    return [[self class] dictionaryByMerging: self with: dict];
}

- (BOOL)containsSomethingForKey:(id)key
{
    return ([self stringForKey:key] != nil);
}


@end