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

#import "VBXTicketStatus.h"
#import "VBXConfiguration.h"

@implementation VBXTicketStatus

+ (VBXTicketStatus *)ticketStatusWithValue:(NSString *)value {
    return [[[VBXTicketStatus alloc] initWithTicketStatus:value] autorelease];
}

- (id)initWithTicketStatus:(NSString *)value {
    if (self = [super init]) {
        _value = [value retain];
    }
    return self;
}

- (void)dealloc {
    [_value release];
    [super dealloc];
}

- (NSString *)key {
    return _value;
}

- (NSString *)title {
    if ([_value isEqualToString:@"open"]) {
        return LocalizedString(@"Open", @"Friendly label for open state");
    } else if ([_value isEqualToString:@"closed"]) {
        return LocalizedString(@"Closed", @"Friendly label for closed state");
    } else if ([_value isEqualToString:@"pending"]) {
        return LocalizedString(@"Pending", @"Friendly label for pending state");
    } else {
        return _value;
    }
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[VBXTicketStatus class]]) {
        return [[self key] isEqualToString:[((VBXTicketStatus *) object) key]];
    } else {
        return NO;
    }
}

@end
