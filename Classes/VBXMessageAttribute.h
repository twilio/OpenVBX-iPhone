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

@class VBXMessageDetail;


@interface VBXMessageAttribute : NSObject {
    VBXMessageDetail *_messageDetail;
    NSString *_key;
    NSString *_name;
    NSArray *_options;
    
    SEL _valueGetter;
    SEL _valueSetter;
    id _pendingValue;
    
    SEL _titleSelector;
    SEL _detailSelector;
    SEL _keySelector;
}

+ (VBXMessageAttribute *)assignedUserAttributeForMessage:(VBXMessageDetail *)detail name:(NSString *)name;
+ (VBXMessageAttribute *)ticketStatusAttributeForMessage:(VBXMessageDetail *)detail name:(NSString *)name;

@property (nonatomic, retain) VBXMessageDetail *messageDetail;
@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSArray *options;

@property (nonatomic, assign) SEL valueGetter;
@property (nonatomic, assign) SEL valueSetter;
@property (nonatomic, retain) id pendingValue;

@property (nonatomic, assign) SEL titleSelector;
@property (nonatomic, assign) SEL detailSelector;
@property (nonatomic, assign) SEL keySelector;

@property (nonatomic, retain) id value;
@property (nonatomic, readonly) NSInteger selectedIndex;
@property (nonatomic, readonly) BOOL hasDetail;

- (NSString *)titleForValue:(id)value;
- (NSString *)detailForValue:(id)value;
- (NSString *)keyForValue:(id)value;

@end
