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

#import "VBXSectionedDataSource.h"


@implementation VBXSectionedCellDataSource

@synthesize headers = _headers;
@synthesize footers = _footers;
@synthesize sections = _sections;

+ (VBXSectionedCellDataSource *)dataSourceWithHeadersCellsAndFooters:(id)object,... {
    NSMutableArray *objects = [NSMutableArray array];
    
    va_list ap;
    va_start(ap, object);
    while (object) {
        [objects addObject:object];
        object = va_arg(ap, id);
    }
    va_end(ap); 
    
    return [self dataSourceWithArray:objects];
}

+ (VBXSectionedCellDataSource *)dataSourceWithArray:(NSArray *)array {
    NSMutableArray *headers = [NSMutableArray array];
    NSMutableArray *footers = [NSMutableArray array];                               
    NSMutableArray *sections = [NSMutableArray array];

    int i = 0;
    while (i < array.count) {
        NSObject *header = [array objectAtIndex:i];
        
        if (![header isKindOfClass:[NSString class]]) {
            [NSException raise:NSGenericException format:@"Expected string header but got %@ at position %d", header, i];
            return nil;
        }
        
        NSMutableArray *cells = [NSMutableArray array];
        
        i++;
        for (;;) {
            NSObject *cell = [array objectAtIndex:i];
            
            if ([cell isKindOfClass:[NSString class]]) {
                break;
            } else if ([cell isKindOfClass:[UITableViewCell class]]) {
                [cells addObject:cell];
                i++;
            } else {
                [NSException raise:NSGenericException format:@"Expected UITableViewCell but got %@ at position %d", [header class], i];
                return nil;                
            }            
        }
        
        NSObject *footer = [array objectAtIndex:i];        

        if (![footer isKindOfClass:[NSString class]]) {
            [NSException raise:NSGenericException format:@"Expected string footer but got %@ at position %d", footer, i];
            return nil;
        }
        
        // All is well
        [headers addObject:header];
        [footers addObject:footer];
        [sections addObject:cells];
        
        i++;
    }
        
    return [[[self alloc] initWithHeaders:headers footers:footers sections:sections] autorelease];
}

- (id)initWithHeaders:(NSMutableArray *)headers footers:(NSMutableArray *)footers sections:(NSMutableArray *)sections {
    if (self = [super init]) {
        self.headers = headers;
        self.footers = footers;
        self.sections = sections;
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    NSMutableArray *cells = [_sections objectAtIndex:section];
    return cells.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray *cells = [_sections objectAtIndex:indexPath.section];    
    return [cells objectAtIndex:indexPath.row];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sections.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [_headers objectAtIndex:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return [_footers objectAtIndex:section];
}

@end
