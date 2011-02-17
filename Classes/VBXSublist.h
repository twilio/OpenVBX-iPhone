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


@interface VBXSublist : NSObject {
    NSInteger _offset;
    NSInteger _total;
    NSMutableArray *_items;
}

- (id)initWithDictionary:(NSDictionary *)dictionary class:(Class)class;

@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, assign) NSInteger total;
@property (nonatomic, copy) NSArray *items;
@property (nonatomic, readonly) NSInteger last;
@property (nonatomic, readonly) BOOL hasMore;

- (id)objectAtIndex:(NSInteger)index;
- (NSArray *)sublistWithRange:(NSRange)range;
- (void)insertObject:(id)object atIndex:(NSInteger)index;
- (void)removeObjectAtIndex:(NSInteger)index;

- (void)mergeItemsFromBeginning:(VBXSublist *)sublist;
- (void)mergeItemsFromEnd:(VBXSublist *)sublist;
- (void)mergeItemsFrom:(VBXSublist *)sublist;

@end
