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

#import "VBXDataSource.h"
#import "VBXConfiguration.h"
#import "UIViewPositioningExtension.h"

@implementation VBXDataSource

@synthesize proxyToDelegate = _proxyToDelegate;

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    if ([_proxyToDelegate respondsToSelector:@selector(tableView:accessoryButtonTappedForRowWithIndexPath:)]) {
        [_proxyToDelegate tableView:tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell conformsToProtocol:@protocol(VBXVariableHeightCell)]) {
        id<VBXVariableHeightCell> variableHeightCell = (id<VBXVariableHeightCell>)cell;        
        return [variableHeightCell heightForCell];        
    } else {
        return ROW_HEIGHT;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_proxyToDelegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        [_proxyToDelegate tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    NSString *footerText = [tableView.dataSource tableView:tableView titleForFooterInSection:section];
 
    if (footerText != nil && footerText.length > 0) {
        UILabel *label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        label.text = footerText;
        label.font = [UIFont systemFontOfSize:15.0];
        label.numberOfLines = 0;
        label.textAlignment = UITextAlignmentCenter;
        label.shadowOffset = CGSizeMake(0, 1);
        label.lineBreakMode = UILineBreakModeWordWrap;
        label.textColor = ThemedColor(@"tableViewFooterTextColor", RGBHEXCOLOR(0x4d576b));
        label.shadowColor = ThemedColor(@"tableViewFooterTextShadowColor", RGBHEXCOLOR(0xf8f9fa));
        label.width = 305;
        label.backgroundColor = [UIColor clearColor];
        [label sizeToFit];
        
        UIView *wrapper = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, label.height + 5)] autorelease];
        wrapper.backgroundColor = tableView.backgroundColor;
        wrapper.autoresizesSubviews = NO;
        [wrapper addSubview:label];
        label.left = round((tableView.width / 2) - (label.width / 2));
        label.top = 5;
        
        return wrapper;
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    UIView *view = [tableView.delegate tableView:tableView viewForFooterInSection:section];
    return view.height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *headerText = [tableView.dataSource tableView:tableView titleForHeaderInSection:section];
    
    if (headerText != nil && headerText.length > 0) {
        UILabel *label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        label.text = headerText;
        label.font = [UIFont boldSystemFontOfSize:17.0];
        label.numberOfLines = 1;
        label.textAlignment = UITextAlignmentLeft;
        label.shadowOffset = CGSizeMake(0, 1);
        label.lineBreakMode = UILineBreakModeTailTruncation;
        label.textColor = ThemedColor(@"tableViewHeaderTextColor", RGBHEXCOLOR(0x4b566d));
        label.shadowColor = ThemedColor(@"tableViewHeaderTextShadowColor", RGBHEXCOLOR(0xffffff));
        label.width = 300;
        label.backgroundColor = [UIColor clearColor];
        [label sizeToFit];
        
        UIView *wrapper = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, label.height + 8)] autorelease];
        wrapper.backgroundColor = tableView.backgroundColor;
        wrapper.autoresizesSubviews = NO;
        [wrapper addSubview:label];
        label.left = 19;
        label.top = 0;
        
        return wrapper;
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    UIView *view = [tableView.delegate tableView:tableView viewForHeaderInSection:section];
    return view.height;
}

@end
