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

#import "VBXConfiguration.h"
#import "NSExtensions.h"
#import "NSData+Base64.h"
#import "VBXUserDefaultsKeys.h"

VBXHSL ThemedHSL(NSString *key, VBXHSL defaultHSL) {
    return [[VBXConfiguration sharedConfiguration] HSLForKey:key defaultHSL:defaultHSL];
}

UIColor *ThemedColor(NSString *key, UIColor *defaultValue) {
    return [[VBXConfiguration sharedConfiguration] colorForKey:key defaultValue:defaultValue];
}

UIImage *ThemedImage(NSString *key, NSString *localFileName) {
    return [[VBXConfiguration sharedConfiguration] imageForKey:key defaultImageFileName:localFileName];
}

NSString *LocalizedString(NSString *str, NSString *comment) {
    return [[VBXConfiguration sharedConfiguration] localizedStringForKey:str];
}

static const void* FakeRetain(CFAllocatorRef allocator, const void *value) { return value; }
static void FakeRelease(CFAllocatorRef allocator, const void *value) { }

@implementation VBXConfiguration

+ (VBXConfiguration *)sharedConfiguration {
    static VBXConfiguration *instance = nil;
    
    if (instance == nil) {
        instance = [[VBXConfiguration alloc] init];
    }
    
    return instance;
}

- (id)init {
    if (self = [super init]) {
        CFArrayCallBacks callbacks = kCFTypeArrayCallBacks;
        callbacks.retain = FakeRetain;
        callbacks.release = FakeRelease;
        _observers = (NSMutableArray *)CFArrayCreateMutable(nil, 0, &callbacks);
    }
    return self;
}

- (void)dealloc {
    [_observers release];
    [super dealloc];
}

- (NSDictionary *)dictionary {
  return _dict;
}

- (void)loadConfigFromDictionary:(NSDictionary *)dict serverURL:(NSString *)serverURL hadTrustedCertificate:(BOOL)hadTrustedCertificate {
    [_dict release];
    _dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
             [NSMutableDictionary dictionaryWithObjectsAndKeys:
              @"#000000",
              @"blackColor",
              @"#aaaaaa",
              @"lightGrayColor",
              @"#545454",
              @"darkGrayColor",
              @"#ffffff",
              @"whiteColor",
              @"#808080",
              @"grayColor",
              @"#ff0000",
              @"redColor",
              @"#00ff00",
              @"greenColor",
              @"#0000ff",
              @"blueColor",
              @"#00ffff",
              @"cyanColor",
              @"#ffff00",
              @"yellowColor",
              @"#ff00ff",
              @"magentaColor",
              @"#ff8000",
              @"orangeColor",
              @"#800080",
              @"purpleColor",
              @"#996633",
              @"brownColor",
              @"#00000000",
              @"clearColor",
             nil],
             @"theme",
             nil];
    [_dict mergeWithContentsOfDictionary:dict];
    [_dict retain];
    
    // If the config came from a secure site with a trusted certificate, then the config
    // is permitted to toggle our secure mode feature...
    if (hadTrustedCertificate) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        BOOL configRequiresTrustedCertificate = [[[_dict objectForKey:@"config"] objectForKey:@"requireTrustedCertificate"] boolValue];
        
        if (configRequiresTrustedCertificate && serverURL) {
            // Append to our list of URLs that require a valid certificate
            NSArray *currentSecureURLs = [defaults objectForKey:VBXUserDefaultsSecureURLs];
            NSMutableArray *secureURLs = nil;
            
            if (currentSecureURLs != nil) {
                secureURLs = [NSMutableArray arrayWithArray:currentSecureURLs];
            } else {
                secureURLs = [NSMutableArray array];
            }
            
            if (![secureURLs containsObject:serverURL]) {
                [secureURLs addObject:serverURL];
                
                [defaults setObject:secureURLs forKey:VBXUserDefaultsSecureURLs];
                [defaults synchronize];            
            }
        }
    }
    
    [_observers makeObjectsPerformSelector:@selector(applyConfig)];
}

- (void)addConfigObserver:(id<VBXConfigurable>)observer {
    if (![_observers containsObject:observer]) {
        [_observers addObject:observer];
    }
}

- (void)removeConfigObserver:(id<VBXConfigurable>)observer {
    [_observers removeObject:observer];
}

- (NSString *)localizedStringForKey:(NSString *)key {
    NSString *localizedStr = [[_dict objectForKey:@"i18n"] objectForKey:key];

    if (localizedStr != nil) {
        return localizedStr;
    }
    
    return key;    
}

- (NSString *)localizedStringForKey:(NSString *)key defaultValue:(NSString *)defaultValue {
    NSString *localizedStr = [[_dict objectForKey:@"i18n"] objectForKey:key];

    if (localizedStr != nil) {
        return localizedStr;
    } else {
        return defaultValue;
    }
}

- (UIColor *)colorForKey:(NSString *)key {
    NSString *value = [[_dict objectForKey:@"theme"] objectForKey:key];
    UIColor *color = nil;
    
    // The value must be at least two characters long, one to indicate the type and
    // at least one more to indicate the value.
    if (value != nil && value.length >= 2) {
        NSString *prefix = [value substringToIndex:1];
        
        if ([prefix isEqualToString:@"@"]) {
            // It's a reference...
            color = [self colorForKey:[value substringFromIndex:1]];
        } else if ([prefix isEqualToString:@"#"]) {
            // Ignore the leading #
            NSString *colorValueStr = [value substringFromIndex:1];
            NSString *hexValue = [NSString stringWithFormat:@"0x%@", colorValueStr];
            unsigned int argb = 0;
            [[NSScanner scannerWithString:hexValue] scanHexInt:&argb];
            
            // Form #AARRGGBB
            if (colorValueStr.length == 8) {
                int alpha = (argb & 0xff000000) >> 24;
                int rgb = (argb & 0xffffff);
                return [RGBHEXCOLOR(rgb) colorWithAlphaComponent:(alpha / 255.0f)];
            
            // Form #RRGGBB
            } else if (colorValueStr.length == 6) {
                color = RGBHEXCOLOR(argb);
                
            // Form #RGB (which expands to #RRGGBB)
            } else if (colorValueStr.length == 3) {
                int r = ((argb & 0xf00) >> 8);
                int g = ((argb & 0xf0) >> 4); 
                int b = ((argb & 0xf) >> 0);
                argb = (((r << 4) | r) << 16) | (((g << 4) | g) << 8) | ((b << 4) | b);
                color = RGBHEXCOLOR(argb);
            } else {
                debug(@"Unexpected color format '%@' for key '%@'.  Valid formats are #rgb, #rrggbb, or #aarrggbb", colorValueStr, key); 
            }
        } else {
            debug(@"Unexpected format on key %@: %@", key, value);
        }
    }
    
    return color;
}

- (UIColor *)colorForKey:(NSString *)key defaultValue:(UIColor *)defaultValue {
    UIColor *color = [self colorForKey:key];
    return (color == nil) ? defaultValue : color;
}

- (VBXHSL)HSLForKey:(NSString *)key defaultHSL:(VBXHSL)defaultHSL {
    BOOL wasSuccessful = NO;
    int h = 0;
    int s = 0;
    int l = 0;
    
    NSString *value = [[_dict objectForKey:@"theme"] objectForKey:key];
    
    if (value != nil) {
        NSArray *parts = [value componentsSeparatedByString:@","];
        
        if (parts != nil && parts.count == 3) {\
            BOOL parseError = NO;
            
            parseError |= ![[NSScanner scannerWithString:[parts objectAtIndex:0]] scanInt:&h];
            parseError |= ![[NSScanner scannerWithString:[parts objectAtIndex:1]] scanInt:&s];
            parseError |= ![[NSScanner scannerWithString:[parts objectAtIndex:2]] scanInt:&l];
            
            if (parseError) {
                debug(@"Failed to parse HSL value from string '%@' for key '%@'", value);
            } else {
                wasSuccessful = YES;
            }
        }
    }
    
    if (wasSuccessful) {
        return VBXHSLMake(h, s, l);
    } else {
        return defaultHSL;
    }
}

- (UIStatusBarStyle)statusBarStyleForKey:(NSString *)key defaultValue:(UIStatusBarStyle)defaultValue {
    NSString *value = [[_dict objectForKey:@"theme"] objectForKey:key];
    
    if ([@"UIStatusBarStyleDefault" isEqualToString:value]) {
        return UIStatusBarStyleDefault;
    } else if ([@"UIStatusBarStyleBlackOpaque" isEqualToString:value]) {
        return UIStatusBarStyleBlackOpaque;
    } else if ([@"UIStatusBarStyleBlackTranslucent" isEqualToString:value]) {
        return UIStatusBarStyleBlackTranslucent;
    } else {
        return defaultValue;
    }
}

- (UITableViewCellSelectionStyle)tableViewCellSelectionStyleForKey:(NSString *)key defaultValue:(UIStatusBarStyle)defaultValue {
    NSString *value = [[_dict objectForKey:@"theme"] objectForKey:key];
    
    if ([@"UITableViewCellSelectionStyleNone" isEqualToString:value]) {
        return UITableViewCellSelectionStyleNone;
    } else if ([@"UITableViewCellSelectionStyleBlue" isEqualToString:value]) {
        return UITableViewCellSelectionStyleBlue;
    } else if ([@"UITableViewCellSelectionStyleGray" isEqualToString:value]) {
        return UITableViewCellSelectionStyleGray;
    } else {
        return defaultValue;
    }
}

- (UIImage *)imageForKey:(NSString *)key defaultImageFileName:(NSString *)defaultImageFileName {
    NSString *value = [[_dict objectForKey:@"theme"] objectForKey:key];
    UIImage *image = nil;
    
    if (value != nil) {
        image = [[[UIImage alloc] initWithData:[NSData dataFromBase64String:value]] autorelease];
    }
    
    if (image == nil && defaultImageFileName != nil) {
        image = [UIImage imageNamed:defaultImageFileName];
    }
    
    return image;
}

@end
