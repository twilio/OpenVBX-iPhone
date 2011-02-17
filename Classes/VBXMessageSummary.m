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

#import "VBXMessageSummary.h"
#import "NSExtensions.h"
#import "VBXGlobal.h"

@implementation VBXMessageSummary

- (id)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.key = [dictionary stringForKey:@"id"];
        self.caller = [dictionary stringForKey:@"caller"];
        self.called = [dictionary stringForKey:@"called"];
        self.assigned = [dictionary stringForKey:@"assigned"];
        self.recordingURL = [dictionary stringForKey:@"recording_url"];
        self.shortSummary = [dictionary stringForKey:@"short_summary"];
        self.receivedTime = [dictionary stringForKey:@"received_time"];
        self.lastUpdated = [dictionary stringForKey:@"last_updated"];
        self.archived = [dictionary boolForKey:@"archived"];
        self.unread = [dictionary boolForKey:@"unread"];
        self.folder = [dictionary stringForKey:@"folder"];
        
        self.relativeReceivedTime = VBXDateToRelativeTime(VBXParseISODateString(_receivedTime));
    }
    return self;
}

@synthesize key = _key;
@synthesize caller = _caller;
@synthesize called = _called;
@synthesize assigned = _assigned;
@synthesize recordingURL = _recordingURL;
@synthesize shortSummary = _shortSummary;
@synthesize receivedTime = _receivedTime;
@synthesize lastUpdated = _lastUpdated;
@synthesize folder = _folder;
@synthesize archived = _archived;
@synthesize unread = _unread;
@synthesize archiving = _archiving;
@synthesize relativeReceivedTime = _relativeReceivedTime;

@dynamic isSms;

- (void)dealloc {
    self.key = nil;
    self.caller = nil;
    self.called = nil;
    self.assigned = nil;
    self.recordingURL = nil;
    self.shortSummary = nil;
    self.receivedTime = nil;
    self.lastUpdated = nil;
    self.folder = nil;
    self.relativeReceivedTime = nil;
    [super dealloc];
}

- (BOOL)isSms {
    return (_recordingURL == nil || _recordingURL.length == 0);
}

@end
