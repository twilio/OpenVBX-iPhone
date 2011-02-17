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

#import "VBXFolderSummary.h"
#import "NSExtensions.h"


@implementation VBXFolderSummary

- (id)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.key = [dictionary stringForKey:@"id"];
        self.name = [dictionary stringForKey:@"name"];
        self.total = [dictionary intForKey:@"total"];
        self.new = [dictionary intForKey:@"new"];
        self.read = [dictionary intForKey:@"read"];
        self.archived = [dictionary intForKey:@"archived"];
    }
    return self;
}

@synthesize key = _key;
@synthesize name = _name;
@synthesize total = _total;
@synthesize new = _new;
@synthesize read = _read;
@synthesize archived = _archived;

- (void)dealloc {
    self.key = nil;
    self.name = nil;
    [super dealloc];
}

@end
