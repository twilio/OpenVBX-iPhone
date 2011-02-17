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

#import "VBXNavigationController.h"
#import "VBXFolderListController.h"
#import "VBXDialerController.h"
#import "VBXSendTextController.h"
#import "VBXObjectBuilder.h"
#import "NSExtensions.h"
#import "VBXGlobal.h"
#import "VBXSettingsController.h"
#import "VBXConfiguration.h"

@interface VBXNavigationController (Private) <UIActionSheetDelegate>
@end


@implementation VBXNavigationController

@synthesize builder = _builder;
@synthesize sendTextIsShown = _sendTextIsShown;
@synthesize dialerIsShown = _dialerIsShown;
@synthesize sendTextController = _sendTextController;
@synthesize dialerController = _dialerController;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // This is a workaround for an issue we started seeing with OS 4.0.  When you would click the
    // reply button on the message details screen, a UIActivitySheet would slide up, then you'd
    // be taken the to the dailer.  But! when the user closed the dialer, the bottom toolbar would
    // appear completely black (but still with the icons showing).  It would correct itself after
    // about a second.
    //
    // Telling the toolbar to repaint himself seems to make it go way.
    [self.toolbar setNeedsDisplay];
    
    // This will happen when we return from the dialer or new text screen.
    _dialerIsShown = NO;
    _sendTextIsShown = NO;
    _dialerController = nil;
    _sendTextController = nil;
}

- (void)showDialOrTextActionSheet {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil 
                                                       delegate:self 
                                              cancelButtonTitle:LocalizedString(@"Cancel", @"NavigationController: Title for cancel button.")
                                         destructiveButtonTitle:nil 
                                              otherButtonTitles:LocalizedString(@"Make a call", @"NavigationController: Title for make a call button."), 
                                                                LocalizedString(@"Send a text", @"NavigationController: Title for send a text button."), nil];
    [sheet showFromToolbar:self.toolbar];
    [sheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [actionSheet cancelButtonIndex]) {
        // do nothing!
    } else if (buttonIndex == [actionSheet firstOtherButtonIndex]) {
        [self showDialer];
    } else if (buttonIndex == ([actionSheet firstOtherButtonIndex] + 1)) {
        [self showSendText];
    }
}

- (UIViewController *)rootController {
    return [self.viewControllers objectAtIndex:0];
}

- (NSDictionary *)saveState {
    NSMutableDictionary *state = [NSMutableDictionary dictionary];

    NSMutableArray *controllerStates = [NSMutableArray arrayWithCapacity:[self.viewControllers count]];
    for (UIViewController *controller in self.viewControllers) {
        id controllerState = [controller performSelectorIfImplemented:@selector(saveState)];
        if (!controllerState) break;
        [controllerStates addObject:controllerState];
    }
    [state setObject:controllerStates forKey:@"controllerStates"];
    
    return state;
}

- (void)restoreState:(NSDictionary *)state {
    NSArray *controllerStates = [state objectForKey:@"controllerStates"];
    NSInteger index = 0;
    for (id controllerState in controllerStates) {
        if (index >= [self.viewControllers count]) {
            debug(@"warning: had %d state items to restore, ran out of controllers at index %d", [controllerStates count], index);
            break;
        }
        
        UIViewController *controller = [self.viewControllers objectAtIndex:index++];
        [controller performSelectorIfImplemented:@selector(restoreState:) withObject:controllerState];
    }
}

- (void)showDialer {
    [self showDialerWithState:[NSDictionary dictionary] animated:YES];
}

- (void)showDialerWithState:(NSDictionary *)state animated:(BOOL)animated {
    _dialerIsShown = YES;
    _dialerController = [_builder dialerController];
    [_dialerController performSelector:@selector(restoreState:) withObject:state];

    UINavigationController *navController = [_builder navControllerWrapping:_dialerController];
    [self presentModalViewController:navController animated:animated];
}

- (void)showSendTextWithState:(NSDictionary *)state animated:(BOOL)animated {
    _sendTextIsShown = YES;
    _sendTextController = [_builder sendTextController];
    [_sendTextController performSelector:@selector(restoreState:) withObject:state];
    [self presentModalViewController:[_builder navControllerWrapping:_sendTextController] animated:animated];    
}

- (void)showSendText {
    [self showSendTextWithState:[NSDictionary dictionary] animated:YES];
}

@end
