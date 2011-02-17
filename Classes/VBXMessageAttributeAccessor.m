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

#import "VBXMessageAttributeAccessor.h"
#import "VBXMessageDetail.h"
#import "VBXMessageAttribute.h"
#import "VBXResourceLoader.h"
#import "VBXResourceRequest.h"
#import "NSExtensions.h"


@implementation VBXMessageAttributeAccessor

- (id)initWithAttribute:(VBXMessageAttribute *)attr {
    if (self = [super init]) {
        _attribute = [attr retain];
    }
    return self;
}

@synthesize valuePoster = _valuePoster;
@synthesize delegate = _delegate;

- (void)dealloc {
    [_attribute release];
    self.valuePoster = nil;
    [super dealloc];
}

- (void)setValue:(id)value {
    _attribute.pendingValue = value;
    
    NSString *resource = [@"messages/details/" stringByAppendingString:_attribute.messageDetail.key];
    VBXResourceRequest *request = [VBXResourceRequest requestWithResource:resource method:@"POST"];
    [request.params setObject:[_attribute keyForValue:value] forKey:_attribute.key];
    
    [_valuePoster setTarget:self successAction:@selector(loader:didSetValue:)];
    [_valuePoster loadRequest:request];
}

- (void)loader:(VBXResourceLoader *)loader didSetValue:(id)response {
    _attribute.value = _attribute.pendingValue;
    _attribute.pendingValue = nil;
    [_delegate accessorDidSetValue:self];
}

- (void)loader:(VBXResourceLoader *)loader didFailWithError:(NSError *)error {
    _attribute.pendingValue = nil;
    [_delegate accessor:self setValueDidFailWithError:error];
}

@end
