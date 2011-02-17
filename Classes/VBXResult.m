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

#import "VBXResult.h"


@implementation VBXResult

+ (VBXResult *)resultWithObject:(id)object {
    return [[[VBXResult alloc] initWithSuccess:YES object:object error:nil] autorelease];
}

+ (VBXResult *)resultWithError:(NSError *)error {
    return [[[VBXResult alloc] initWithSuccess:NO object:nil error:error] autorelease];
}

- (id)initWithSuccess:(BOOL)s object:(id)o error:(NSError *)e {
    if (self = [super init]) {
        _success = s;
        _object = [o retain];
        _error = [e retain];
    }
    return self;
}

@synthesize success = _success;
@synthesize object = _object;
@synthesize error = _error;

- (NSString *)description {
    NSString *contents = _success ? [_object description] : [NSString stringWithFormat:@"error: %@", _error];
    return [NSString stringWithFormat:@"<Result: %@>", contents];
}

@end
