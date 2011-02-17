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

#import "VBXAnnotation.h"
#import "NSExtensions.h"


@implementation VBXAnnotation

- (id)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.key = [dictionary stringForKey:@"id"];
        self.messageKey = [dictionary stringForKey:@"message_id"];
        self.type = [dictionary stringForKey:@"annotation_type"];
        self.created = [dictionary stringForKey:@"created"];
        self.userKey = [dictionary stringForKey:@"user_id"];
        self.email = [dictionary stringForKey:@"email"];
        self.firstName = [dictionary stringForKey:@"first_name"];
        self.lastName = [dictionary stringForKey:@"last_name"];
        self.description = [dictionary stringForKey:@"description"];
    }
    return self;
}

@synthesize key = _key;
@synthesize messageKey = _messageKey;
@synthesize type = _type;
@synthesize created = _created;
@synthesize userKey = _userKey;
@synthesize email = _email;
@synthesize firstName = _firstName;
@synthesize lastName = _lastName;
@synthesize description = _description;

- (void)dealloc {
    self.key = nil;
    self.messageKey = nil;
    self.type = nil;
    self.created = nil;
    self.userKey = nil;
    self.email = nil;
    self.firstName = nil;
    self.lastName = nil;
    self.description = nil;
    [super dealloc];
}

- (NSString *)fullName {
    NSMutableString *name = [NSMutableString string];
    if (_firstName) [name appendString:_firstName];
    [name appendString:@" "];
    if (_lastName) [name appendString:_lastName];
    return [name stringByTrimmingWhitespace];
}

- (NSString *)displayName {
    NSMutableString *name = [NSMutableString stringWithString:[self fullName]];
    if (_email.length > 0) [name appendFormat:@" <%@>", _email];
    return [name stringByTrimmingWhitespace];
}

@end
