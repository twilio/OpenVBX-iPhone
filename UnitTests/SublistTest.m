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


#import <SenTestingKit/SenTestingKit.h>
#import <UIKit/UIKit.h>

#import "VBXSublist.h"

@interface SublistTest : SenTestCase {
    VBXSublist *page1;
    VBXSublist *page2;
    VBXSublist *page3;
}

@end

@implementation SublistTest

- (void)setUp {
    [super setUp];
    
    page1 = [VBXSublist new];
    page1.offset = 0;
    page1.total = 10;
    page1.items = [NSArray arrayWithObjects:@"foo", @"bar", @"baz", nil];

    page2 = [VBXSublist new];
    page2.offset = 3;
    page2.total = 10;
    page2.items = [NSArray arrayWithObjects:@"quux", @"frob", @"nitz", nil];

    page3 = [VBXSublist new];
    page3.offset = 7;
    page3.total = 10;
    page3.items = [NSArray arrayWithObjects:@"alice", @"bob", @"charlie", nil];
}

- (void)tearDown {
    [page1 release];
    [page2 release];
    [page3 release];
    [super tearDown];
}

- (void) testLast {
    STAssertEquals(3, page1.last, nil);
    STAssertEquals(6, page2.last, nil);
    STAssertEquals(10, page3.last, nil);
}

- (void) testHasMore {
    STAssertTrue(page1.hasMore, nil);
    STAssertTrue(page2.hasMore, nil);
    STAssertFalse(page3.hasMore, nil);
}

- (void)testObjectAtIndex {
    STAssertEquals(@"bar", [page1 objectAtIndex:1], nil);
    STAssertEquals(@"quux", [page2 objectAtIndex:3], nil);
    STAssertEquals(@"charlie", [page3 objectAtIndex:9], nil);
}

- (void)testSublistWithRange {
    NSRange range;
    range.length = 2;

    range.location = 1;
    NSArray *expected1 = [NSArray arrayWithObjects:@"bar", @"baz", nil];
    STAssertEqualObjects(expected1, [page1 sublistWithRange:range], nil);

    range.location = 3;
    NSArray *expected2 = [NSArray arrayWithObjects:@"quux", @"frob", nil];
    STAssertEqualObjects(expected2, [page2 sublistWithRange:range], nil);
}

- (void)testInsertObjectAtIndex {
    [page1 insertObject:@"jason" atIndex:1];
    NSArray *expected1 = [NSArray arrayWithObjects:@"foo", @"jason", @"bar", @"baz", nil];
    STAssertEquals(0, page1.offset, nil);
    STAssertEquals(11, page1.total, nil);
    STAssertEqualObjects(expected1, page1.items, nil);
    
    [page2 insertObject:@"jason" atIndex:5];
    NSArray *expected2 = [NSArray arrayWithObjects:@"quux", @"frob", @"jason", @"nitz", nil];
    STAssertEquals(3, page2.offset, nil);
    STAssertEquals(11, page2.total, nil);
    STAssertEqualObjects(expected2, page2.items, nil);    
}

- (void)testMergeItemsFromBeginning {
    NSArray *expected = nil;
    
    expected = [NSArray arrayWithArray:page1.items];
    [page1 mergeItemsFromBeginning:page2];  // shouldn't change anything
    STAssertEquals(0, page1.offset, nil);
    STAssertEquals(10, page1.total, nil);
    STAssertEqualObjects(expected, page1.items, nil);

    [page1 mergeItemsFromBeginning:page3];  // shouldn't change anything
    STAssertEquals(0, page1.offset, nil);
    STAssertEquals(10, page1.total, nil);
    STAssertEqualObjects(expected, page1.items, nil);
    
    expected = [[NSArray arrayWithArray:page1.items] arrayByAddingObjectsFromArray:page2.items];
    [page2 mergeItemsFromBeginning:page1];
    STAssertEquals(0, page2.offset, nil);
    STAssertEquals(10, page2.total, nil);
    STAssertEqualObjects(expected, page2.items, nil);
    
    expected = [NSArray arrayWithArray:page3.items];
    [page3 mergeItemsFromBeginning:page1];  // shouldn't change anything; disjoint
    STAssertEquals(7, page3.offset, nil);
    STAssertEquals(10, page3.total, nil);
    STAssertEqualObjects(expected, page3.items, nil);
}

- (void)testMergeItemsFromEnd {
    NSArray *expected = nil;
    
    expected = [NSArray arrayWithArray:page2.items];
    [page2 mergeItemsFromEnd:page1];    // shouldn't change anything
    STAssertEquals(3, page2.offset, nil);
    STAssertEquals(10, page2.total, nil);
    STAssertEqualObjects(expected, page2.items, nil);
    
    expected = [NSArray arrayWithArray:page1.items];
    [page1 mergeItemsFromEnd:page3];    // shouldn't change anything; disjoint
    STAssertEquals(0, page1.offset, nil);
    STAssertEquals(10, page1.total, nil);
    STAssertEqualObjects(expected, page1.items, nil);

    expected = [[NSArray arrayWithArray:page1.items] arrayByAddingObjectsFromArray:page2.items];
    [page1 mergeItemsFromEnd:page2];
    STAssertEquals(0, page1.offset, nil);
    STAssertEquals(10, page1.total, nil);
    STAssertEqualObjects(expected, page1.items, nil);    
}

- (void)testMergeItemsFrom1 {
    NSArray *expected = [[NSArray arrayWithArray:page1.items] arrayByAddingObjectsFromArray:page2.items];
    [page2 mergeItemsFrom:page1];
    STAssertEquals(0, page2.offset, nil);
    STAssertEquals(10, page2.total, nil);
    STAssertEqualObjects(expected, page2.items, nil);    
}

- (void)testMergeItemsFrom2 {
    NSArray *expected = [[NSArray arrayWithArray:page1.items] arrayByAddingObjectsFromArray:page2.items];
    [page1 mergeItemsFrom:page2];
    STAssertEquals(0, page1.offset, nil);
    STAssertEquals(10, page1.total, nil);
    STAssertEqualObjects(expected, page1.items, nil);    
}

- (void)testMergeItemsNoOp {
    NSArray *expected = nil;
    
    expected = [NSArray arrayWithArray:page3.items];
    [page3 mergeItemsFrom:page1];
    STAssertEquals(7, page3.offset, nil);
    STAssertEquals(10, page3.total, nil);
    STAssertEqualObjects(expected, page3.items, nil);    
    
    expected = [NSArray arrayWithArray:page1.items];
    [page1 mergeItemsFrom:page3];
    STAssertEquals(0, page1.offset, nil);
    STAssertEquals(10, page1.total, nil);
    STAssertEqualObjects(expected, page1.items, nil);    
}

@end
