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

#import "UIExtensions.h"
#import "NSExtensions.h"
#import "VBXGlobal.h"

@implementation UIColor (Extensions)

- (id)initWithDictionary:(NSDictionary *)dictionary {
    CGFloat red = [dictionary floatForKey:@"r"];
    CGFloat green = [dictionary floatForKey:@"g"];
    CGFloat blue = [dictionary floatForKey:@"b"];
    CGFloat alpha = [dictionary containsKey:@"a"]? [dictionary floatForKey:@"a"] : 1.0;
    return [self initWithRed:red green:green blue:blue alpha:alpha];
}

- (NSString *)hexValue {
    const CGFloat *components = CGColorGetComponents([self rgbColor].CGColor);
    return [NSString stringWithFormat:@"%02x%02x%02x", 
            (int)(components[0] * 255), 
            (int)(components[1] * 255), 
            (int)(components[2] * 255),
            nil];
}

- (UIColor *)rgbColor {    
    CGColorSpaceModel model = CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
    
    if (model == kCGColorSpaceModelRGB) {
        return self;
    } else if (model == kCGColorSpaceModelMonochrome) {
        const CGFloat *components = CGColorGetComponents(self.CGColor);    
        return [UIColor colorWithRed:components[0] green:components[0] blue:components[0] alpha:components[1]];
    } else {
        [NSException raise:NSGenericException format:@"Unhandled color space model (%d)", model];
        return nil;
    }
}

@end


@implementation UIAlertView (Extensions)

+ (void)showAlertViewWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertView *view = [[[UIAlertView alloc] initWithTitle:title message:message
        delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
    [view show];
}

+ (void)showAlertViewWithErrorMessage:(NSString *)message {
    [self showAlertViewWithTitle:@"Error" message:message];
}

+ (void)showAlertViewWithTitle:(NSString *)title forError:(NSError *)error {
    NSString *message = [error localizedDescription];
    if (!message) message = @"An error ocurred. Please contact your OpenVBX service provider, or try again later.";
    [self showAlertViewWithTitle:title message:message];
}

@end


@implementation UIBarButtonItem (Extensions)

+ (UIBarButtonItem *)itemWithCustomView:(UIView *)view {
    return [[[UIBarButtonItem alloc] initWithCustomView:view] autorelease];
}

+ (UIBarButtonItem *)flexibleSpace {
    return [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
}

@end


@implementation UIApplication (Extensions)

- (NSDictionary *)statusBarStylesByName {
    DECLARE_SINGLETON(NSMutableDictionary, styles);
    styles = [NSMutableDictionary new];
    [styles setInt:UIStatusBarStyleDefault forKey:@"UIStatusBarStyleDefault"];
    [styles setInt:UIStatusBarStyleBlackOpaque forKey:@"UIStatusBarStyleBlackOpaque"];
    [styles setInt:UIStatusBarStyleBlackTranslucent forKey:@"UIStatusBarStyleBlackTranslucent"];
    return styles;
}

- (void)setStatusBarStyleByName:(NSString *)name {
    NSNumber *style = [[self statusBarStylesByName] objectForKey:name];
    if (style) self.statusBarStyle = [style intValue];
}

@end


@implementation UIDevice (Extensions)

- (NSString *)systemIdentifier {
    DECLARE_SINGLETON(NSString, identifier);
    identifier = [[NSString alloc] initWithFormat:@"%@ (%@ %@)", [self model], [self systemName], [self systemVersion]];
    return identifier;
}

@end

@implementation UIView (FirstResponderExtensions)

- (UIView *)findFirstResponder {
  if ([self isFirstResponder]) {
    return self;
  } else {
    for (UIView *subview in self.subviews) {
      UIView *firstResponder = [subview findFirstResponder];
      
      if (firstResponder != nil) {
        return firstResponder;
      }
    }
    
    return nil;
  }
}

@end