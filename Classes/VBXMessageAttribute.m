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

#import "VBXMessageAttribute.h"
#import "VBXMessageDetail.h"
#import "VBXTicketStatus.h"

@implementation VBXMessageAttribute

+ (VBXMessageAttribute *)assignedUserAttributeForMessage:(VBXMessageDetail *)detail name:(NSString *)name {
    VBXMessageAttribute *attribute = [[VBXMessageAttribute new] autorelease];
    attribute.messageDetail = detail;
    attribute.key = @"assigned";
    attribute.name = name;
    attribute.options = detail.activeUsers;
    attribute.valueGetter = @selector(assignedUser);
    attribute.valueSetter = @selector(setAssignedUser:);
    attribute.titleSelector = @selector(fullName);
    attribute.detailSelector = @selector(email);
    attribute.keySelector = @selector(key);

    return attribute;
}

+ (VBXMessageAttribute *)ticketStatusAttributeForMessage:(VBXMessageDetail *)detail name:(NSString *)name {
    VBXMessageAttribute *attribute = [[VBXMessageAttribute new] autorelease];
    attribute.messageDetail = detail;
    attribute.key = @"ticket_status";
    attribute.name = name;
    attribute.options = [NSArray arrayWithObjects:
                         [VBXTicketStatus ticketStatusWithValue:@"open"],
                         [VBXTicketStatus ticketStatusWithValue:@"closed"],
                         [VBXTicketStatus ticketStatusWithValue:@"pending"],
                         nil];
    attribute.valueGetter = @selector(ticketStatus);
    attribute.valueSetter = @selector(setTicketStatus:);
    attribute.titleSelector = @selector(title);
    attribute.keySelector = @selector(key);
    return attribute;
}

@synthesize messageDetail = _messageDetail;
@synthesize key = _key;
@synthesize name = _name;
@synthesize options = _options;

@synthesize valueGetter = _valueGetter;
@synthesize valueSetter = _valueSetter;
@synthesize pendingValue = _pendingValue;

@synthesize titleSelector = _titleSelector;
@synthesize detailSelector = _detailSelector;
@synthesize keySelector = _keySelector;

- (void)dealloc {
    self.messageDetail = nil;
    self.key = nil;
    self.name = nil;
    self.options = nil;
    self.pendingValue = nil;
    [super dealloc];
}

- (id)value {
    return [_messageDetail performSelector:_valueGetter];
}

- (void)setValue:(id)value {
    [_messageDetail performSelector:_valueSetter withObject:value];
}

- (NSInteger)selectedIndex {
    return [_options indexOfObject:self.value];
}

- (BOOL)hasDetail {
    return _detailSelector != NULL;
}

- (NSString *)titleForValue:(id)value {
    return [value performSelector:_titleSelector];
}

- (NSString *)detailForValue:(id)value {
    return self.hasDetail? [value performSelector:_detailSelector] : nil;
}

- (NSString *)keyForValue:(id)value {
    return [value performSelector:_keySelector];
}

@end
