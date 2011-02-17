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

@class VBXSublist;
@class VBXUser;
@class VBXMessageAttribute;
@class VBXTicketStatus;

@interface VBXMessageDetail : NSObject {
    NSString *_key;
    NSString *_caller;
    NSString *_called;
    NSString *_folder;
    NSString *_assignedUserKey;
    NSString *_status;
    NSString *_ticketStatusKey;
    NSString *_recordingURL;
    NSString *_recordingLength;
    NSString *_summary;
    NSString *_receivedTime;
    NSString *_lastUpdated;
    BOOL _unread;
    BOOL _callback;
    BOOL _archived;
    NSArray *_activeUsers;
    VBXSublist *_annotations;
}

- (id)initWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) NSString *caller;
@property (nonatomic, retain) NSString *called;
@property (nonatomic, retain) NSString *folder;
@property (nonatomic, retain) NSString *assignedUserKey;
@property (nonatomic, retain) NSString *status;
@property (nonatomic, retain) NSString *ticketStatusKey;
@property (nonatomic, retain) NSString *recordingURL;
@property (nonatomic, retain) NSString *recordingLength;
@property (nonatomic, retain) NSString *summary;
@property (nonatomic, retain) NSString *receivedTime;
@property (nonatomic, retain) NSString *lastUpdated;
@property (nonatomic, assign) BOOL unread;
@property (nonatomic, assign) BOOL callback;
@property (nonatomic, assign) BOOL archived;
@property (nonatomic, retain) NSArray *activeUsers;
@property (nonatomic, retain) VBXSublist *annotations;

@property (nonatomic, retain) VBXUser *assignedUser;

@property (nonatomic, readonly) BOOL isSms;

@end
