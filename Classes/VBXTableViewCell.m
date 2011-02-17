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

#import "VBXTableViewCell.h"


@implementation VBXTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [[VBXConfiguration sharedConfiguration] addConfigObserver:self];
        [self applyConfig];
    }
    return self;
}

- (void)dealloc {
    [[VBXConfiguration sharedConfiguration] removeConfigObserver:self];
    [super dealloc];
}

- (void)applyConfig {
    self.backgroundColor = ThemedColor(@"tableViewCellBackgroundColor", ThemedColor(@"tableViewPlainBackgroundColor", [UIColor whiteColor]));
    self.textLabel.textColor = ThemedColor(@"tableViewCellTitleColor", ThemedColor(@"primaryTextColor", [UIColor blackColor]));
    self.detailTextLabel.textColor = ThemedColor(@"tableViewCellValueColor", RGBHEXCOLOR(0x385487));
    self.selectionStyle = [[VBXConfiguration sharedConfiguration] tableViewCellSelectionStyleForKey:@"tableViewCellSelectionStyle" defaultValue:UITableViewCellSelectionStyleBlue];
}

@end
