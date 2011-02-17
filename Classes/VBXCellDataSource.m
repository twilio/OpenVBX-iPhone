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

#import "VBXCellDataSource.h"


@implementation VBXCellDataSource

@synthesize cells = _cells;

+ (VBXCellDataSource *)dataSourceWithCells:(id)object,... {
    NSMutableArray *cells = [NSMutableArray array];
    va_list ap;
    va_start(ap, object);
    while (object) {
        [cells addObject:object];
        object = va_arg(ap, id);
    }
    va_end(ap); 
    
    return [[[self alloc] initWithCells:cells] autorelease];
}

- (id)initWithCells:(NSMutableArray *)cells {
    if (self = [super init]) {
        self.cells = cells;
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    return _cells.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [_cells objectAtIndex:indexPath.row];
}

@end

