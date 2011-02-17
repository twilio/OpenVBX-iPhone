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


@interface VBXMessageSummary : NSObject {
    NSString *_key;
    NSString *_caller;
    NSString *_called;
    NSString *_assigned;
    NSString *_recordingURL;
    NSString *_shortSummary;
    NSString *_receivedTime;
    NSString *_lastUpdated;
    NSString *_folder;
    BOOL _archived;
    BOOL _unread;
    BOOL _archiving;
    
    NSString *_relativeReceivedTime;
}

- (id)initWithDictionary:(NSDictionary *)dictionary;

@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) NSString *caller;
@property (nonatomic, retain) NSString *called;
@property (nonatomic, retain) NSString *assigned;
@property (nonatomic, retain) NSString *recordingURL;
@property (nonatomic, retain) NSString *shortSummary;
@property (nonatomic, retain) NSString *receivedTime;
@property (nonatomic, retain) NSString *lastUpdated;
@property (nonatomic, retain) NSString *folder;
@property (nonatomic, assign, getter=isArchived) BOOL archived;
@property (nonatomic, assign, getter=isUnread) BOOL unread;
@property (nonatomic, assign, getter=isArchiving) BOOL archiving;

@property (nonatomic, readonly) BOOL isSms;
@property (nonatomic, retain) NSString *relativeReceivedTime;

@end
