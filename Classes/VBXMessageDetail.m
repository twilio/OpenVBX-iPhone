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

#import "VBXMessageDetail.h"
#import "VBXUser.h"
#import "VBXAnnotation.h"
#import "VBXSublist.h"
#import "VBXMessageAttribute.h"
#import "NSExtensions.h"
#import "VBXGlobal.h"
#import "VBXTicketStatus.h"

@implementation VBXMessageDetail

- (id)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.key = [dictionary stringForKey:@"id"];
        self.caller = [dictionary stringForKey:@"caller"];
        self.called = [dictionary stringForKey:@"called"];
        self.folder = [dictionary stringForKey:@"folder"];
        self.assignedUserKey = [dictionary stringForKey:@"assigned"];
        self.status = [dictionary stringForKey:@"status"];
        self.ticketStatusKey = [dictionary stringForKey:@"ticket_status"];
        self.recordingURL = [dictionary stringForKey:@"recording_url"];
        self.recordingLength = [dictionary stringForKey:@"recording_length"];
        self.summary = [dictionary stringForKey:@"summary"];
        self.receivedTime = [dictionary stringForKey:@"received_time"];
        self.lastUpdated = [dictionary stringForKey:@"last_updated"];
        self.unread = [dictionary boolForKey:@"unread"];
        self.callback = [dictionary boolForKey:@"callback"];
        self.archived = [dictionary boolForKey:@"archived"];
        self.activeUsers = [dictionary arrayOfModelsForKey:@"active_users" class:[VBXUser class]];
        self.annotations = [dictionary sublistForKey:@"annotations" class:[VBXAnnotation class]];
    }
    return self;
}

@synthesize key = _key;
@synthesize caller = _caller;
@synthesize called = _called;
@synthesize folder = _folder;
@synthesize assignedUserKey = _assignedUserKey;
@synthesize ticketStatusKey = _ticketStatusKey;
@synthesize recordingURL = _recordingURL;
@synthesize recordingLength = _recordingLength;
@synthesize summary = _summary;
@synthesize receivedTime = _receivedTime;
@synthesize lastUpdated = _lastUpdated;
@synthesize unread = _unread;
@synthesize callback = _callback;
@synthesize archived = _archived;
@synthesize activeUsers = _activeUsers;
@synthesize annotations = _annotations;
@synthesize status = _status;

@dynamic isSms;

- (void)dealloc {
    self.key = nil;
    self.caller = nil;
    self.called = nil;
    self.folder = nil;
    self.assignedUserKey = nil;
    self.status = nil;
    self.ticketStatusKey = nil;
    self.recordingURL = nil;
    self.recordingLength = nil;
    self.summary = nil;
    self.receivedTime = nil;
    self.lastUpdated = nil;
    self.activeUsers = nil;
    self.annotations = nil;
    [super dealloc];
}

- (VBXUser *)activeUserWithKey:(NSString *)userKey {
    for (VBXUser *user in _activeUsers) {
        if ([user.key isEqualToString:userKey]) return user;
    }
    return nil;
}

- (VBXUser *)assignedUser {
    return [self activeUserWithKey:_assignedUserKey];
}

- (void)setAssignedUser:(VBXUser *)user {
    self.assignedUserKey = user.key;
}

- (VBXTicketStatus *)ticketStatus {
    return [VBXTicketStatus ticketStatusWithValue:_ticketStatusKey];
}

- (void)setTicketStatus:(VBXTicketStatus *)state {
    self.ticketStatusKey = [state key];
}

- (NSString *)receivedTime {
    NSDate *date = VBXParseISODateString(_receivedTime);
    NSString *result = nil;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];    
    
    result = [formatter stringFromDate:date];
    
    [formatter release];
    
    return result;
}

- (BOOL)isSms {
    return (_recordingURL == nil || _recordingURL.length == 0);
}

@end
