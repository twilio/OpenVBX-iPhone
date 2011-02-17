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

#import "VBXViewController.h"
#import "UIExtensions.h"
#import "UIViewPositioningExtension.h"
#import "VBXGlobal.h"
#import "VBXDimOverlay.h"
#import "VBXConfiguration.h"
#import "VBXObjectBuilder.h"

@implementation VBXViewController

- (void)keyboardWillShow:(NSNotification *)notification {
    [UIView beginAnimations:@"showKeyboard" context:nil];
    [UIView setAnimationDuration:0.3];

    self.view.frame = VBXNavigationFrameWithKeyboard();

    if (_overlayView != nil) {
        _overlayView.frame = self.view.frame;
    }    
    
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [UIView beginAnimations:@"hideKeyboard" context:nil];
    [UIView setAnimationDuration:0.3];

    self.view.frame = VBXNavigationFrame();

    if (_overlayView != nil) {
        _overlayView.frame = self.view.bounds;
    }
    
    [UIView commitAnimations];
}

- (id)init {
    if (self = [super init]) {
        [[VBXConfiguration sharedConfiguration] addConfigObserver:self];
    }
    return self;
}

- (void)loadView {
	[super loadView];
    UIView *view = [[[UIView alloc] initWithFrame:VBXApplicationFrame()] autorelease];
    view.opaque = NO;
    view.backgroundColor = [UIColor whiteColor];

    [self setView:view];
    [self applyConfig];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
        
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:) name:@"UIKeyboardWillShowNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:) name:@"UIKeyboardWillHideNotification" object:nil];                
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIKeyboardWillShowNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIKeyboardWillHideNotification" object:nil];    
}

- (void)dealloc {
    [[VBXConfiguration sharedConfiguration] removeConfigObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [super dealloc];
}

- (void)applyConfig {
    self.navigationController.navigationBar.tintColor = ThemedColor(@"navigationBarTintColor", RGBHEXCOLOR(0x8094ae));
    self.navigationController.toolbar.tintColor = ThemedColor(@"toolbarTintColor", self.navigationController.navigationBar.tintColor);
}

- (void)setOverlayView:(UIView *)overlayView {
    if (_overlayView != overlayView) {
        [_overlayView release];
        _overlayView = [overlayView retain];
        
        [self.view.superview addSubview:_overlayView];
        _overlayView.frame = self.view.frame;
    }
}

- (void)clearOverlayView {
    if (_overlayView != nil) {
        [_overlayView removeFromSuperview];
        [_overlayView release];
        _overlayView = nil;
    }
}

- (void)dimViewAfterDelay {
    // We always want to check because it could happen that the screen is dimmed and cleared
    // before we ever even show the dimmed overlay.  (remember, we wait a moment before we
    // start dimming)
    if (_viewIsDimmed) {
        [self setOverlayView:[VBXDimOverlay overlay]];
    }
}

- (void)setPromptAndDimView:(NSString *)title {
    _viewIsDimmed = YES;
    self.navigationItem.prompt = title;
    
    [self performSelector:@selector(dimViewAfterDelay) withObject:nil afterDelay:0.1];    
}

- (void)unsetPromptAndUndim {
    self.navigationItem.prompt = nil;
    _viewIsDimmed = NO;
    [self clearOverlayView];
}

/**
 * Presents the view controller in a modal manner (slides up from the bottom). This
 * method is useful when you need something to be modal, but you don't already have
 * a reference to the top-most controller (since that's what the normal presentModalViewController
 * machinery requires.
 */
- (void)presentAsPseudoModalViewController {

    _pseudoModalWindow = [[UIWindow alloc] initWithFrame:VBXApplicationFrame()];
    _pseudoNavigationController = [[[VBXObjectBuilder sharedBuilder] navControllerWrapping:self] retain];
    [_pseudoModalWindow addSubview:_pseudoNavigationController.view];
    [_pseudoModalWindow makeKeyAndVisible];

    _pseudoNavigationController.view.top = _pseudoNavigationController.view.height;

    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];

    _pseudoNavigationController.view.top = 0;

    [UIView commitAnimations];
}

- (void)dismissAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    [[[_pseudoModalWindow subviews] objectAtIndex:0] removeFromSuperview];
    [_pseudoModalWindow release];
    [_pseudoNavigationController release];
}

- (void)dismissPseudoModalViewController {
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(dismissAnimationDidStop:finished:context:)];

    _pseudoNavigationController.view.top = _pseudoNavigationController.view.height;

    [UIView commitAnimations];
}

@end
