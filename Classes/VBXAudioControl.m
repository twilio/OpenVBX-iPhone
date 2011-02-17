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

#import "VBXAudioControl.h"
#import "UIViewPositioningExtension.h"
#import "VBXConfiguration.h"

#define kButtonSize 24

static UIImage *__playImage = nil;
static UIImage *__stopImage = nil;
static UIImage *__pauseImage = nil;

@interface VBXAudioControl (Private) <VBXConfigurable>
- (void)controlButtonPressed;
@end

@implementation VBXAudioControl

@synthesize delegate = _delegate;
@synthesize context = _context;

- (id)init {
    if (self = [super initWithFrame:CGRectMake(0, 0, kButtonSize, kButtonSize)]) {
        _controlButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_controlButton addTarget:self action:@selector(controlButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_controlButton];        
        [self showPlayButton];
        
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (UIImage *)imageWithSymbol:(UIImage *)symbolImage color:(UIColor *)color {
    CGSize size = CGSizeMake(24, 24);
    UIGraphicsBeginImageContext(size);
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();		
    UIGraphicsPushContext(contextRef);
    
    [color set];
    CGContextFillEllipseInRect(contextRef, CGRectMake(0, 0, size.width, size.height));
    
    
    [symbolImage drawAtPoint:CGPointMake(round((size.width / 2) - (symbolImage.size.width / 2)),
                                         round((size.height / 2) - (symbolImage.size.height / 2)))];
    
    
    UIGraphicsPopContext();								    
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return outputImage;
}

- (UIImage *)imageForPlay {
    if (__playImage == nil) {
        __playImage = [[self imageWithSymbol:[UIImage imageNamed:@"play-symbol.png"] color:ThemedColor(@"playButtonColor", RGBHEXCOLOR(0x0099cc))] retain];
    }
    return __playImage;
}

- (UIImage *)imageForPause {
    if (__pauseImage == nil) {
        __pauseImage = [[self imageWithSymbol:[UIImage imageNamed:@"pause-symbol.png"] color:ThemedColor(@"pauseButtonColor", RGBHEXCOLOR(0x287cda))] retain];
    }
    return __pauseImage;
}

- (UIImage *)imageForStop {
    if (__stopImage == nil) {
        __stopImage = [[self imageWithSymbol:[UIImage imageNamed:@"stop-symbol.png"] color:ThemedColor(@"stopButtonColor", RGBHEXCOLOR(0x287cda))] retain];
    }
    return __stopImage;
}

- (void)applyConfig {
    // Clear and rebuild the images
    [__stopImage release];
    [__pauseImage release];
    [__playImage release];
    __stopImage = nil;
    __playImage = nil;
    __pauseImage = nil;
    
    if (_isPlayButton) {
        [self showPlayButton];
    } else if (_isPauseButton) {
        [self showPauseButton];
    } else if (_isStopButton) {
        [self showStopButton];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize size = self.size;
    _controlButton.frame = CGRectMake(round((size.width / 2) - (kButtonSize / 2)),
                                     round((size.height / 2) - (kButtonSize / 2)),
                                     kButtonSize,
                                     kButtonSize);
}

- (void)showPlayButton {
    _isPlayButton = YES;
    _isStopButton = NO;
    _isPauseButton = NO;
    [_controlButton setImage:[self imageForPlay] forState:UIControlStateNormal];
}

- (void)showPauseButton {
    _isPlayButton = NO;
    _isStopButton = NO;
    _isPauseButton = YES;    
    [_controlButton setImage:[self imageForPause] forState:UIControlStateNormal];
}

- (void)showStopButton {
    _isPlayButton = NO;
    _isStopButton = YES;
    _isPauseButton = NO;    
    [_controlButton setImage:[self imageForStop] forState:UIControlStateNormal];
}

- (void)controlButtonPressed {
    if (_delegate != nil) {
        [_delegate audioControlDidPressControl:self];
    }
}

- (void)setBackgroundColor:(UIColor *)color {
    [super setBackgroundColor:color];
    _controlButton.backgroundColor = color;
}

- (void)setOpaque:(BOOL)opaque {
    [super setOpaque:opaque];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    // If we get a hit anywhere within our bounds, then we claim that it
    // hit our control button.  We want someone to be able to fat finger
    // the play/pause button.

    CGRect frame = _controlButton.frame;
    const CGFloat expandBy = 15;
    frame.origin.x -= expandBy;
    frame.origin.y -= expandBy;
    frame.size.width += (2 * expandBy);
    frame.size.height += (2 * expandBy);

    if (CGRectContainsPoint(frame, point)) {
        return _controlButton;
    } else {
        return nil;
    }
}

@end
