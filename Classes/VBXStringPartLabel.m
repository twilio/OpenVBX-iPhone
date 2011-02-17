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

#import "VBXStringPartLabel.h"

@implementation VBXStringPart

@synthesize text = _text;
@synthesize font = _font;

+ (VBXStringPart *)partWithText:(NSString *)text font:(UIFont *)font {
    VBXStringPart *sp = [[[VBXStringPart alloc] init] autorelease];
    sp.text = text;
    sp.font = font;
    return sp;
}

@end


@implementation VBXStringPartLabel

@synthesize textColor = _textColor;
@synthesize shadowOffset = _shadowOffset;
@synthesize shadowColor = _shadowColor;
@synthesize parts = _parts;
@synthesize textAlignment = _textAlignment;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.parts = [NSMutableArray array];
        self.textColor = [UIColor blackColor];
        self.shadowOffset = CGSizeMake(0, 0);
        self.shadowColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // First, figure out the bounds
    CGSize bounds = CGSizeMake(0, 0);
    
    CGContextSetShadowWithColor(context, _shadowOffset, 1.0, _shadowColor.CGColor);
    
    CGSize sizes[_parts.count];
    CGFloat maxAscender = 0.0;
    int i = 0;
    for (VBXStringPart *part in _parts) {
        CGSize size = [part.text sizeWithFont:part.font];
        sizes[i++] = size;

        bounds.width += size.width;
        bounds.height = MAX(bounds.height, size.height);
        
        maxAscender = MAX(maxAscender, part.font.ascender);
    }

    // Then DRAW!
    [_textColor set];    
    CGPoint point = {0};
    
    switch (_textAlignment) {
        case UITextAlignmentLeft:
            point = CGPointMake(0, 0);
            break;
        case UITextAlignmentRight:
            point = CGPointMake(rect.size.width - bounds.width, 0);
            break;
        case UITextAlignmentCenter:
            point = CGPointMake(round((rect.size.width / 2) - (bounds.width / 2)), 0);
            break;
        default:
            break;
    }
    
    i = 0;
    for (VBXStringPart *part in _parts) {
        CGSize size = sizes[i++];
        [part.text drawAtPoint:CGPointMake(point.x, point.y + (maxAscender - part.font.ascender)) withFont:part.font];
        point.x += size.width;
    }
}

- (void)setTextColor:(UIColor *)textColor {
    if (_textColor != textColor) {
        [_textColor release];
        _textColor = [textColor retain];
        
        [self setNeedsDisplay];
    }    
}

- (void)setShadowOffset:(CGSize)shadowOffset {
    _shadowOffset = shadowOffset;
    [self setNeedsDisplay];
}

- (void)setShadowColor:(UIColor *)shadowColor {
    if (_shadowColor != shadowColor) {
        [_shadowColor release];
        _shadowColor = [shadowColor retain];

        [self setNeedsDisplay];
    }
}

- (void)setTextAlignment:(UITextAlignment)textAlignment {
    _textAlignment = textAlignment;
    [self setNeedsDisplay];
}

- (CGSize)sizeThatFits:(CGSize)size {
    // First, figure out the bounds
    CGSize bounds = CGSizeMake(0, 0);
    
    for (VBXStringPart *part in _parts) {
        CGSize size = [part.text sizeWithFont:part.font];
        
        bounds.width += size.width;
        bounds.height = MAX(bounds.height, size.height);
    }
    
    return bounds;
}

- (void)setParts:(NSArray *)parts {
    if (_parts != parts) {
        [_parts release];
        _parts = [parts retain];
        
        [self setNeedsDisplay];
    }
}

- (void)dealloc {
    self.parts = nil;
    self.textColor = nil;
    [super dealloc];
}


@end
