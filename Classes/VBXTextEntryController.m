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

#import "VBXTextEntryController.h"
#import "NSExtensions.h"
#import "VBXConfiguration.h"

@interface VBXTextEntryController (Private) <VBXConfigurable>
@end


@implementation VBXTextEntryController

@synthesize target = _target;
@synthesize action = _action;
@synthesize navTitle = _navTitle;
@synthesize initialText = _initialText;
@synthesize navBar = _navBar;
@synthesize textView = _textView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [[VBXConfiguration sharedConfiguration] addConfigObserver:self];
    }
    return self;
}

- (void)dealloc {
    [[VBXConfiguration sharedConfiguration] removeConfigObserver:self];
    self.navTitle = nil;
    self.initialText = nil;
    self.navBar = nil;
    self.textView = nil;
    [super dealloc];
}

- (void)applyConfig {
    _navBar.tintColor = ThemedColor(@"navigationBarTintColor", RGBHEXCOLOR(0x8094ae));

    _textView.backgroundColor = ThemedColor(@"textEntryBackgroundColor", ThemedColor(@"tableViewPlainBackgroundColor", [UIColor whiteColor]));
    self.view.backgroundColor = _textView.backgroundColor;
    
    _textView.textColor = ThemedColor(@"textEntryTextColor", ThemedColor(@"primaryTextColor", [UIColor blackColor]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self applyConfig];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _navBar.topItem.title = _navTitle;
    _textView.text = _initialText;
    [_textView becomeFirstResponder];
}

- (void)viewDidUnload {
    self.initialText = _textView.text;
}

- (IBAction)save {
    //debug(@"text: %@", textView.text);
    if (!_action) {
        _action = @selector(textEntryControllerFinishedWithText:);
    }
    
    [_target performSelector:_action withObject:_textView.text];
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (IBAction)cancel {
    //trace();
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}

#pragma mark State save and restore

- (NSDictionary *)saveState {
    if (!_textView.text) {
        return [NSDictionary dictionary];
    }
    
    return [NSDictionary dictionaryWithObject:_textView.text forKey:@"text"];
}

- (void)restoreState:(NSDictionary *)state {
    if ([state containsKey:@"text"]) {
        self.initialText = [state stringForKey:@"text"];
    }
}

@end
