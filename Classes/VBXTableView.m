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

#import "VBXTableView.h"
#import "VBXGlobal.h"
#import "VBXConfiguration.h"

UIColor *VBXTableViewGroupedBackgroundColor() {
    VBXHSL hsl = ThemedHSL(@"tableViewGroupedBackgroundTintHSL", VBXHSLMake(255, 15, 240));
    UIImage *tintedImage = VBXAdjustImageWithPhotoshopHSLWithCache([NSUserDefaults standardUserDefaults], @"tableview-grouped-background.png", @"normal", hsl);
    return [[[UIColor alloc] initWithPatternImage:[tintedImage stretchableImageWithLeftCapWidth:0 topCapHeight:1]] autorelease];
}

@interface VBXTableView (Private) <VBXConfigurable>
@end

@implementation VBXTableView

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if (self = [super initWithFrame:frame style:style]) {        
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
    if (self.style == UITableViewStyleGrouped) {
        self.backgroundColor = VBXTableViewGroupedBackgroundColor();
        self.separatorColor = ThemedColor(@"tableViewGroupedSeparatorColor", RGBHEXCOLOR(0xa9abae));
    } else {
        self.backgroundColor = ThemedColor(@"tableViewPlainBackgroundColor", RGBHEXCOLOR(0xffffff));
        self.separatorColor = ThemedColor(@"tableViewPlainSeparatorColor", RGBHEXCOLOR(0xe6e6e6));
    }
}

@end
