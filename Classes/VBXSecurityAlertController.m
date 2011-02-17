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

#import "VBXSecurityAlertController.h"
#import "VBXActivityLabel.h"
#import "VBXObjectBuilder.h"
#import "UIViewPositioningExtension.h"

@interface VBXSecurityAlertController (Private) <UIAlertViewDelegate>
@end


@implementation VBXSecurityAlertController

@synthesize builder = _builder;
@synthesize delegate = _delegate;
@synthesize tag = _tag;
@synthesize headingText = _headingText;
@synthesize descriptionText = _descriptionText;
@synthesize userInfo = _userInfo;

- (void)accept {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Are you sure?", @"Security Alert: Title for confirmation alert view.")
                                                    message:LocalizedString(@"You could be allowing an attacker to access your OpenVBX account.", @"Security Alert: Body for confirmation alert view.")
                                                   delegate:self 
                                          cancelButtonTitle:LocalizedString(@"No", nil) 
                                          otherButtonTitles:LocalizedString(@"Yes", nil), nil];
    [alert show];
    [alert release];
}

- (void)reject {
    [self dismissPseudoModalViewController];

    if (_delegate) {
        [_delegate securityAlertDidAccept:self];
    }    
}

- (id)init {
    if (self = [super init]) {
        self.title = LocalizedString(@"Security Alert", @"Security Alert: Title for screen.");
        
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:LocalizedString(@"Cancel", @"Security Alert: Title for cancel button.") 
                                                                                 style:UIBarButtonItemStylePlain 
                                                                                target:self
                                                                                 action:@selector(reject)] autorelease];
        
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:LocalizedString(@"Continue", @"Security Alert: Title for Continue button")
                                                                                  style:UIBarButtonItemStyleDone
                                                                                 target:self
                                                                                 action:@selector(accept)] autorelease];        
        
        self.headingText = @"heading";
        self.descriptionText = @"description";
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)loadView {
    [super loadView];
    
    UIView *view = [self view];
        
    UILabel *firstLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 290, 999)] autorelease];
    firstLabel.numberOfLines = 0;
    firstLabel.font = [UIFont boldSystemFontOfSize:15];
    firstLabel.backgroundColor = [UIColor clearColor];
    firstLabel.text = _headingText;
    firstLabel.lineBreakMode = UILineBreakModeWordWrap;
    firstLabel.textAlignment = UITextAlignmentCenter;
    [firstLabel sizeToFit];
    [view addSubview:firstLabel];
    
    UILabel *secondLabel = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 290, 999)] autorelease];
    secondLabel.numberOfLines = 0;
    secondLabel.font = [UIFont systemFontOfSize:14];
    secondLabel.backgroundColor = [UIColor clearColor];
    secondLabel.text = _descriptionText;
    secondLabel.lineBreakMode = UILineBreakModeWordWrap;
    [secondLabel sizeToFit];
    [view addSubview:secondLabel];
    
    firstLabel.centerX = view.centerX;
    firstLabel.top = 50;
    
    secondLabel.centerX = view.centerX;
    secondLabel.top = firstLabel.bottom + 40;
    
    [self applyConfig];
}

- (void)applyConfig {
    [super applyConfig];
    
    self.navigationController.navigationBar.tintColor = ThemedColor(@"securityAlertNavigationBarTintColor", RGBHEXCOLOR(0x810000));
    
    VBXHSL backgroundHSL = ThemedHSL(@"securityAlertBackgroundHSL", VBXHSLMake(12, 50, -5));
    self.view.backgroundColor = [[[UIColor alloc] initWithPatternImage:VBXAdjustImageWithPhotoshopHSLWithCache([NSUserDefaults standardUserDefaults], @"security-alert-background.png", @"normal", backgroundHSL)] autorelease];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        // cancel        
    } else {
        // confirmed!
        [self dismissPseudoModalViewController];
        
        if (_delegate) {
            [_delegate securityAlertDidAccept:self];
        }
    }
}
@end
