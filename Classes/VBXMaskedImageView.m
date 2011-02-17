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

#import "VBXMaskedImageView.h"
#import "UIExtensions.h"

@implementation VBXMaskedImageView

@synthesize image = _image;
@synthesize startColor = _startColor;
@synthesize endColor = _endColor;

- (id)init {
    if (self = [super initWithFrame:CGRectZero]) {
        self.image = nil;
        self.startColor = [UIColor grayColor];
        self.endColor = [UIColor blackColor];
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (id)initWithImage:(UIImage *)anImage {
    if (self = [self init]) {
        self.image = anImage;
        self.frame = CGRectMake(0, 0, anImage.size.width, anImage.size.height);
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // I don't know why it does this, but you have to flip the context
    // if you want things to appear right side up.
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextClipToMask(context, rect, _image.CGImage);
    
    if ([_startColor isEqual:_endColor]) {
        [_startColor set];
        CGContextFillRect(context, rect);
    } else {    
        CGGradientRef glossGradient = NULL;
        CGColorSpaceRef rgbColorspace = NULL;
        
        size_t num_locations = 2;
        
        CGFloat locations[2] = { 0.0, 1.0 };
        
        const CGFloat *startColorComponents = CGColorGetComponents([_startColor rgbColor].CGColor);    
        const CGFloat *endColorComponents = CGColorGetComponents([_endColor rgbColor].CGColor);
        
        CGFloat components[8] = {            
            endColorComponents[0],
            endColorComponents[1],
            endColorComponents[2],
            endColorComponents[3],
            startColorComponents[0],
            startColorComponents[1],
            startColorComponents[2],
            startColorComponents[3],
        };
        
        rgbColorspace = CGColorSpaceCreateDeviceRGB();
        glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);
        
        CGRect currentBounds = self.bounds;
        CGPoint topCenter = CGPointMake(CGRectGetMidX(currentBounds), 0.0f);
        CGPoint bottomCenter = CGPointMake(CGRectGetMidX(currentBounds), currentBounds.size.height);
        CGContextDrawLinearGradient(context, glossGradient, topCenter, bottomCenter, 0);
        
        CGGradientRelease(glossGradient);
        CGColorSpaceRelease(rgbColorspace);
    }
}

- (void)dealloc {
    [super dealloc];
}

- (void)setImage:(UIImage *)image {
    if (_image != image) {
        [_image release];
        _image = [image retain];
        
        [self setNeedsDisplay];
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(_image.size.width, _image.size.height);
}

@end
