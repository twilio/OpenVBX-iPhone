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

#import "VBXSublist.h"
#import "NSExtensions.h"


@implementation VBXSublist

- (id)initWithDictionary:(NSDictionary *)dictionary class:(Class)class {
    if (self = [super init]) {
        self.offset = [dictionary intForKey:@"offset"];
        self.total = [dictionary intForKey:@"total"];
        self.items = [dictionary arrayOfModelsForKey:@"items" class:class];
    }
    return self;
}

@synthesize offset = _offset;
@synthesize total = _total;
@synthesize items = _items;

- (void)setItems:(NSArray *)items {
    if (_items != items) {
        [_items release];
        _items = [[NSMutableArray alloc] initWithArray:items];
    }
}

- (void)dealloc {
    self.items = nil;
    [super dealloc];
}

- (NSInteger)last {
    return _offset + [_items count];
}

- (BOOL)hasMore {
    return _total > self.last;
}

- (id)objectAtIndex:(NSInteger)index {
    index -= _offset;
    return [_items objectAtIndex:index];
}

- (NSArray *)sublistWithRange:(NSRange)range {
    range.location -= _offset;
    return [_items subarrayWithRange:range];
}

- (void)insertObject:(id)object atIndex:(NSInteger)index {
    index -= _offset;
    [_items insertObject:object atIndex:index];
    _total++;
}

- (void)removeObjectAtIndex:(NSInteger)index {
    index -= _offset;
    [_items removeObjectAtIndex:index];
    _total--;
}

- (void)mergeItemsFromBeginning:(VBXSublist *)sublist {
    if (sublist.last < self.offset) return; // list is disjoint
    NSInteger length = self.offset - sublist.offset;
    if (length < 1) return; // nothing to do
    NSRange range = NSMakeRange(sublist.offset, length);
    NSMutableArray *newItems = [NSMutableArray arrayWithArray:[sublist sublistWithRange:range]];
    [newItems addObjectsFromArray:_items];
    self.items = newItems;
    self.offset = sublist.offset;
}

- (void)mergeItemsFromEnd:(VBXSublist *)sublist {
    if (sublist.offset > self.last) return; // list is disjoint
    NSInteger length = sublist.last - self.last;
    if (length < 1) return; // nothing to do
    NSArray *newItems = [sublist sublistWithRange:NSMakeRange(self.last, length)];
    [_items addObjectsFromArray:newItems];
}

- (void)mergeItemsFrom:(VBXSublist *)sublist {
    [self mergeItemsFromBeginning:sublist];
    [self mergeItemsFromEnd:sublist];
}

@end
