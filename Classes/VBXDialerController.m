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

#import "VBXDialerController.h"
#import "VBXDialerAccessor.h"
#import "VBXOutgoingPhone.h"
#import "VBXResult.h"
#import "UIExtensions.h"
#import "NSExtensions.h"
#import "VBXUserDefaultsKeys.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "UIViewPositioningExtension.h"
#import "VBXGlobal.h"
#import "VBXMaskedImageView.h"
#import "VBXCallerIdController.h"
#import "VBXObjectBuilder.h"
#import "VBXConfiguration.h"

static UIImage *__callerIdNormalImage = nil;
static UIImage *__callerIdHighlightedImage = nil;
static UIImage *__callKeyNormalImage = nil;
static UIImage *__callKeyHighlightedImage = nil;
static UIImage *__accessoryKeyNormalImage = nil;
static UIImage *__accessoryKeyHighlightedImage = nil;
static UIImage *__numberKeyNormalSideImage = nil;
static UIImage *__numberKeyHighlightedSideImage = nil;
static UIImage *__numberKeyNormalMiddleImage = nil;
static UIImage *__numberKeyHighlightedMiddleImage = nil;
static UIImage *__numberAreaBackgroundImage = nil;

UIImage *DialerNumberAreaBackgroundImage(NSUserDefaults *userDefaults) {
    return VBXAdjustImageWithPhotoshopHSLWithCache(userDefaults, @"dialer-numberarea-bg.png", @"normal", ThemedHSL(@"dialerNumberAreaTintHSL", VBXHSLMake(200, 15, 1)));
}
UIImage *DialerCallerIdNormalImage(NSUserDefaults *userDefaults) {
    return VBXAdjustImageWithPhotoshopHSLWithCache(userDefaults, @"dialer-callerid-bg.png", @"normal", ThemedHSL(@"dialerCallerIdTintHSL", VBXHSLMake(207, 10, 2)));
}
UIImage *DialerCallerIdHighlightedImage(NSUserDefaults *userDefaults) {
    return VBXAdjustImageWithPhotoshopHSLWithCache(userDefaults, @"dialer-callerid-bg.png", @"highlighted", ThemedHSL(@"dialerCallerIdHighlightedTintHSL", VBXHSLMake(222, 100, -31)));
}
UIImage *DialerCallKeyNormalImage(NSUserDefaults *userDefaults) {
    return VBXAdjustImageWithPhotoshopHSLWithCache(userDefaults, @"dialer-call-bg.png", @"normal", ThemedHSL(@"dialerCallKeyTintHSL", VBXHSLMake(121, 61, 0)));
}
UIImage *DialerCallKeyHighlightedImage(NSUserDefaults *userDefaults) {
    return VBXAdjustImageWithPhotoshopHSLWithCache(userDefaults, @"dialer-call-bg.png", @"highlighted", ThemedHSL(@"dialerCallKeyHighlightedTintHSL", VBXHSLMake(121, 61, 10)));
}
UIImage *DialerSpecialKeyNormalImage(NSUserDefaults *userDefaults) {
    return VBXAdjustImageWithPhotoshopHSLWithCache(userDefaults, @"dialer-accessory-key-bg.png", @"normal", ThemedHSL(@"dialerSpecialKeyTintHSL", VBXHSLMake(207, 10, 2)));
}
UIImage *DialerSpecialKeyHighlightedImage(NSUserDefaults *userDefaults) {
    return VBXAdjustImageWithPhotoshopHSLWithCache(userDefaults, @"dialer-accessory-key-bg.png", @"highlighted", ThemedHSL(@"dialerSpecialKeyHighlightedTintHSL", VBXHSLMake(215, 100, -39)));
}
UIImage *DialerNumberKeySideNormalImage(NSUserDefaults *userDefaults) {
    return VBXAdjustImageWithPhotoshopHSLWithCache(userDefaults, @"dialer-number-side-bg.png", @"normal", ThemedHSL(@"dialerNumberKeyTintHSL", VBXHSLMake(218, 12, 0)));
}
UIImage *DialerNumberKeySideHighlightedImage(NSUserDefaults *userDefaults) {
    return VBXAdjustImageWithPhotoshopHSLWithCache(userDefaults, @"dialer-number-side-bg.png", @"highlighted", ThemedHSL(@"dialerNumberKeyHighlightedTintHSL", VBXHSLMake(218, 100, 0)));
}
UIImage *DialerNumberKeyMiddleNormalImage(NSUserDefaults *userDefaults) {
    return VBXAdjustImageWithPhotoshopHSLWithCache(userDefaults, @"dialer-number-middle-bg.png", @"normal", ThemedHSL(@"dialerNumberKeyTintHSL", VBXHSLMake(218, 12, 0)));
}
UIImage *DialerNumberKeyMiddleHighlightedImage(NSUserDefaults *userDefaults) {
    return VBXAdjustImageWithPhotoshopHSLWithCache(userDefaults, @"dialer-number-middle-bg.png", @"highlighted", ThemedHSL(@"dialerNumberKeyHighlightedTintHSL", VBXHSLMake(218, 100, 0)));
}

#define WRAP_IN_AUTORELEASE_POOL(x) \
    do { \
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; \
        x; \
        [pool release]; \
    } while (0)

void DialerBuildImages() {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    WRAP_IN_AUTORELEASE_POOL(DialerCallerIdNormalImage(userDefaults));
    WRAP_IN_AUTORELEASE_POOL(DialerCallerIdHighlightedImage(userDefaults));
    WRAP_IN_AUTORELEASE_POOL(DialerCallKeyNormalImage(userDefaults));
    WRAP_IN_AUTORELEASE_POOL(DialerCallKeyHighlightedImage(userDefaults));
    WRAP_IN_AUTORELEASE_POOL(DialerSpecialKeyNormalImage(userDefaults));
    WRAP_IN_AUTORELEASE_POOL(DialerSpecialKeyHighlightedImage(userDefaults));
    WRAP_IN_AUTORELEASE_POOL(DialerNumberKeySideNormalImage(userDefaults));
    WRAP_IN_AUTORELEASE_POOL(DialerNumberKeySideHighlightedImage(userDefaults));
    WRAP_IN_AUTORELEASE_POOL(DialerNumberKeyMiddleNormalImage(userDefaults));
    WRAP_IN_AUTORELEASE_POOL(DialerNumberKeyMiddleHighlightedImage(userDefaults));
    WRAP_IN_AUTORELEASE_POOL(DialerNumberAreaBackgroundImage(userDefaults));
}

@interface NumberAreaView : UIView <VBXConfigurable> {
    UIImageView *_backgroundView;
    UILabel *_numberLabel;
}
@end

@implementation NumberAreaView

- (id)init {
    if (self = [super initWithFrame:CGRectMake(0, 0, 320, 89)]) {
        _backgroundView = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];        
        [self addSubview:_backgroundView];
        
        _numberLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];        
        _numberLabel.text = @"123...text to be replaced later";
        _numberLabel.backgroundColor = [UIColor clearColor];
        _numberLabel.font = [UIFont systemFontOfSize:30];
        _numberLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
        _numberLabel.minimumFontSize = 14;
        _numberLabel.numberOfLines = 1;
        _numberLabel.textAlignment = UITextAlignmentCenter;
        [_numberLabel sizeToFit];
        [self addSubview:_numberLabel];
        
        [self applyConfig];
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)setNumber:(NSString *)number {
    _numberLabel.text = number;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _backgroundView.frame = self.bounds;
    
    _numberLabel.width = 250;
    _numberLabel.left = round((self.width / 2) - (_numberLabel.width / 2));
    _numberLabel.top = round((self.height / 2) - (_numberLabel.height / 2));
}

- (void)applyConfig {
    _backgroundView.image = __numberAreaBackgroundImage;

    _numberLabel.textColor = ThemedColor(@"dialerNumberTextColor", [UIColor blackColor]);
    _numberLabel.shadowColor = ThemedColor(@"dialerNumberTextShadowColor", [UIColor colorWithWhite:0 alpha:0.2]);
    _numberLabel.shadowOffset = CGSizeMake(0, 1);    
}

@end


@interface CallerIdControl : UIControl <VBXConfigurable> {
    UIImageView *_backgroundView;
    UILabel *_callerIdLabel;
    UILabel *_numberLabel;
}

- (void)setCallerId:(NSString *)callerId;
- (NSString *)callerId;

@end

@implementation CallerIdControl

- (id)init {
    if (self = [super initWithFrame:CGRectMake(0, 0, 320, 50)]) {
        _backgroundView = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
        [self addSubview:_backgroundView];
        
        _callerIdLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        _callerIdLabel.text = LocalizedString(@"CALLER ID", @"Dailer: Label for caller id number.");
        _callerIdLabel.backgroundColor = [UIColor clearColor];
        _callerIdLabel.font = [UIFont boldSystemFontOfSize:13];
        [_callerIdLabel sizeToFit];
        [self addSubview:_callerIdLabel];    

        _numberLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        _numberLabel.text = @"";
        _numberLabel.backgroundColor = [UIColor clearColor];
        _numberLabel.font = [UIFont boldSystemFontOfSize:18];        
        [_numberLabel sizeToFit];
        [self addSubview:_numberLabel];        
        
        [self applyConfig];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _backgroundView.frame = self.bounds;
    
    _callerIdLabel.left = 10;
    _callerIdLabel.top = round((self.height / 2) - (_callerIdLabel.height / 2));
    
    [_numberLabel sizeToFit];
    _numberLabel.right = self.width - 25;
    _numberLabel.top = round((self.height / 2) - (_numberLabel.height / 2));
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [self applyConfig];
}

- (void)setCallerId:(NSString *)callerId {
    _numberLabel.text = callerId;
    [self setNeedsLayout];
}

- (NSString *)callerId {
    return _numberLabel.text;
}

- (void)applyConfig {
    if (self.isHighlighted) {
        _backgroundView.image = __callerIdHighlightedImage;  

        _numberLabel.textColor = ThemedColor(@"dialerCallerIdNumberHighlightedTextColor", [UIColor whiteColor]);        
        _callerIdLabel.textColor = ThemedColor(@"dialerCallerIdLabelHighlightedTextColor", [UIColor whiteColor]);
                
        _numberLabel.shadowOffset = CGSizeZero;        
        _callerIdLabel.shadowOffset = CGSizeMake(0, 0);        
    } else {
        _numberLabel.textColor = ThemedColor(@"dialerCallerIdNumberTextColor", ThemedColor(@"primaryTextColor", [UIColor blackColor]));
        _numberLabel.shadowColor = ThemedColor(@"dialerCallerIdNumberTextShadowColor", [UIColor colorWithWhite:1.0 alpha:0.7]);
        _callerIdLabel.textColor = ThemedColor(@"dialerCallerIdLabelTextColor", RGBHEXCOLOR(0x333333));
        _callerIdLabel.shadowColor = ThemedColor(@"dialerCallerIdLabelTextShadowColor", [UIColor colorWithWhite:1.0 alpha:0.7]);
        _callerIdLabel.shadowOffset = CGSizeMake(0, 1);      
        _numberLabel.shadowOffset = CGSizeMake(0, 1);
        _backgroundView.image = __callerIdNormalImage;
    }    
}

@end


@interface CallKey : UIControl <VBXConfigurable> {
    UIImageView *_backgroundView;
    UILabel *_label;
}
@end

@implementation CallKey

- (id)init {
    if (self = [super initWithFrame:CGRectMake(0, 0, 110, 61)]) {
        _backgroundView = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
        [self addSubview:_backgroundView];
        
        _label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        _label.text = LocalizedString(@"Call", @"Dialer: Label for call button");
        _label.backgroundColor = [UIColor clearColor];
        _label.font = [UIFont boldSystemFontOfSize:28];
        _label.shadowOffset = CGSizeMake(0, -1);
        
        [_label sizeToFit];
        [self addSubview:_label];
        
        [self applyConfig];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _backgroundView.frame = self.bounds;
    
    _label.top = round((self.height / 2) - (_label.height / 2));
    _label.left = round((self.width / 2) - (_label.width / 2));
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [self applyConfig];
}

- (void)applyConfig {
    if (self.isHighlighted) {
        _backgroundView.image = __callKeyHighlightedImage;        
        _label.shadowColor = ThemedColor(@"dialerCallKeyHighlightedTextShadowColor", ThemedColor(@"dialerNumberKeyDigitHighlightedTextShadowColor", [UIColor colorWithWhite:0 alpha:0.7]));
        _label.textColor = ThemedColor(@"dialerCallKeyHighlightedTextColor", ThemedColor(@"dialerNumberKeyDigitHighlightedTextColor", [UIColor whiteColor]));
    } else {
        _backgroundView.image = __callKeyNormalImage;
        _label.shadowColor = ThemedColor(@"dialerCallKeyTextShadowColor", ThemedColor(@"dialerNumberKeyDigitTextShadowColor", [UIColor colorWithWhite:0 alpha:0.7]));
        _label.textColor = ThemedColor(@"dialerCallKeyTextColor", ThemedColor(@"dialerNumberKeyDigitTextColor", [UIColor whiteColor]));
    }    
}

@end


@interface AccessoryKey : UIControl <VBXConfigurable> {
    UIImageView *_backgroundView;
    VBXMaskedImageView *_iconView;
}

@end

@implementation AccessoryKey

- (id)initWithImage:(UIImage *)image {
    if (self = [super initWithFrame:CGRectMake(0, 0, 105, 61)]) {
        _backgroundView = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
        [self addSubview:_backgroundView];
        
        _iconView = [[[VBXMaskedImageView alloc] initWithImage:image] autorelease];
        _iconView.backgroundColor = [UIColor clearColor];
        [_iconView sizeToFit];
        [self addSubview:_iconView];
        
        [self applyConfig];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [self applyConfig];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _backgroundView.frame = self.bounds;
    
    _iconView.left = round((self.width / 2) - (_iconView.width / 2));
    _iconView.top = round((self.height / 2) - (_iconView.height / 2));
}

- (void)applyConfig {
    if (self.isHighlighted) {
        _iconView.startColor = ThemedColor(@"dialerSpecialKeyIconHighlightedGradientBeginColor", RGBHEXCOLOR(0xffffff));
        _iconView.endColor = ThemedColor(@"dialerSpecialKeyIconHighlightedGradientEndColor", RGBHEXCOLOR(0xffffff));
        _backgroundView.image = __accessoryKeyHighlightedImage;  
    } else {
        _iconView.startColor = ThemedColor(@"dialerSpecialKeyIconGradientBeginColor", RGBHEXCOLOR(0x505866));
        _iconView.endColor = ThemedColor(@"dialerSpecialKeyIconGradientEndColor", RGBHEXCOLOR(0x68707d));
        _backgroundView.image = __accessoryKeyNormalImage;
    }
    
    [_iconView setNeedsDisplay];    
}

@end

typedef enum {
    NumberKeyTypeMiddle,
    NumberKeyTypeSide
} NumberKeyType;

@interface NumberKey : UIControl <VBXConfigurable> {
    NumberKeyType _type;
    UIImageView *_backgroundView;
    UILabel *_numberLabel;
    UILabel *_lettersLabel;
}

- (id)initWithType:(NumberKeyType)type number:(NSString *)number letters:(NSString *)letters;

- (NSString *)keyValue;

@end


@implementation NumberKey

- (id)initWithType:(NumberKeyType)type number:(NSString *)number letters:(NSString *)letters {
    if (self = [super initWithFrame:CGRectMake(0, 0, (type == NumberKeyTypeMiddle ? 110 : 105), 54)]) {
        _type = type;
        
        _backgroundView = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
        [self addSubview:_backgroundView];
        
        _numberLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        _numberLabel.text = number;
        _numberLabel.backgroundColor = [UIColor clearColor];
        _numberLabel.font = [UIFont boldSystemFontOfSize:28];
        _numberLabel.shadowOffset = CGSizeMake(0, -1);
        [_numberLabel sizeToFit];
        [self addSubview:_numberLabel];
        
        _lettersLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        _lettersLabel.text = letters;
        _lettersLabel.backgroundColor = [UIColor clearColor];
        _lettersLabel.font = [UIFont boldSystemFontOfSize:13];
        [_lettersLabel sizeToFit];
        [self addSubview:_lettersLabel];        
        
        [self applyConfig];
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _backgroundView.frame = self.bounds;
    
    _numberLabel.top = 5;
    _numberLabel.left = round((self.width / 2) - (_numberLabel.width / 2));    
    
    _lettersLabel.bottom = self.height - 4;
    _lettersLabel.left = round((self.width / 2) - (_lettersLabel.width / 2));
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [self applyConfig];
}

- (NSString *)keyValue {
    return _numberLabel.text;
}

- (void)applyConfig {
    if (self.isHighlighted) {
        _numberLabel.textColor = ThemedColor(@"dialerNumberKeyDigitHighlightedTextColor", [UIColor whiteColor]);
        _numberLabel.shadowColor = ThemedColor(@"dialerNumberKeyDigitHighlightedTextShadowColor", [UIColor colorWithWhite:0 alpha:0.7]);
        _lettersLabel.textColor = ThemedColor(@"dialerNumberKeyLettersHighlightedTextColor", [UIColor whiteColor]);
        _backgroundView.image = (_type == NumberKeyTypeMiddle) ? __numberKeyHighlightedMiddleImage : __numberKeyHighlightedSideImage;
    } else {
        _backgroundView.image = (_type == NumberKeyTypeMiddle) ? __numberKeyNormalMiddleImage : __numberKeyNormalSideImage;
        _numberLabel.textColor = ThemedColor(@"dialerNumberKeyDigitTextColor", [UIColor whiteColor]);
        _numberLabel.shadowColor = ThemedColor(@"dialerNumberKeyDigitTextShadowColor", [UIColor colorWithWhite:0 alpha:0.7]);
        _lettersLabel.textColor = ThemedColor(@"dialerNumberKeyLettersTextColor", [UIColor colorWithWhite:0.65 alpha:1.0]);
    }
}

@end



@interface VBXDialerController () <VBXDialerAccessorDelegate, ABPeoplePickerNavigationControllerDelegate>

@property (nonatomic, retain) NSString *phoneNumber;

@end


@implementation VBXDialerController

@synthesize userDefaults = _userDefaults;
@synthesize accessor = _accessor;
@synthesize phoneNumber = _phoneNumber;

- (id)initWithPhone:(NSString *)phone {
    if (self = [super init]) {
        _initialPhoneNumber = [phone retain];
        
        self.title = LocalizedString(@"Dialer", @"Dialer: Title for screen.");
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                                                                target:self 
                                                                                action:@selector(cancelPressed)] autorelease];
        
        // We don't want the back button for our screen to take up too much space
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:LocalizedString(@"Back", nil)
                                                                                  style:UIBarButtonItemStyleBordered 
                                                                                 target:nil 
                                                                                 action:nil] autorelease];
    }
    return self;
}

- (void)dealloc {
    self.accessor.delegate = nil;
    self.userDefaults = nil;
    self.accessor = nil;
    self.phoneNumber = nil;

    [_initialPhoneNumber release];
    [_dialerView release];
    
    [__callerIdNormalImage release];
    __callerIdNormalImage = nil;
    [__callerIdHighlightedImage release];
    __callerIdHighlightedImage = nil;
    [__callKeyNormalImage release];
    __callKeyNormalImage = nil;
    [__callKeyHighlightedImage release];
    __callKeyHighlightedImage = nil;
    [__accessoryKeyNormalImage release];
    __accessoryKeyNormalImage = nil;
    [__accessoryKeyHighlightedImage release];
    __accessoryKeyHighlightedImage = nil;
    [__numberKeyNormalSideImage release];
    __numberKeyNormalSideImage = nil;
    [__numberKeyHighlightedSideImage release];
    __numberKeyHighlightedSideImage = nil;
    [__numberKeyNormalMiddleImage release];
    __numberKeyNormalMiddleImage = nil;
    [__numberKeyHighlightedMiddleImage release];
    __numberKeyHighlightedMiddleImage = nil;
    [__numberAreaBackgroundImage release];
    __numberAreaBackgroundImage = nil; 
    
    [super dealloc];
}

- (void)applyConfig {
    [super applyConfig];
    
    [__callerIdNormalImage release];
    __callerIdNormalImage = nil;
    [__callerIdHighlightedImage release];
    __callerIdHighlightedImage = nil;
    [__callKeyNormalImage release];
    __callKeyNormalImage = nil;
    [__callKeyHighlightedImage release];
    __callKeyHighlightedImage = nil;
    [__accessoryKeyNormalImage release];
    __accessoryKeyNormalImage = nil;
    [__accessoryKeyHighlightedImage release];
    __accessoryKeyHighlightedImage = nil;
    [__numberKeyNormalSideImage release];
    __numberKeyNormalSideImage = nil;
    [__numberKeyHighlightedSideImage release];
    __numberKeyHighlightedSideImage = nil;
    [__numberKeyNormalMiddleImage release];
    __numberKeyNormalMiddleImage = nil;
    [__numberKeyHighlightedMiddleImage release];
    __numberKeyHighlightedMiddleImage = nil;
    [__numberAreaBackgroundImage release];
    __numberAreaBackgroundImage = nil;
    
    __callerIdNormalImage = [DialerCallerIdNormalImage(_userDefaults) retain];
    __callerIdHighlightedImage = [DialerCallerIdHighlightedImage(_userDefaults) retain];
    __callKeyNormalImage = [DialerCallKeyNormalImage(_userDefaults) retain];
    __callKeyHighlightedImage = [DialerCallKeyHighlightedImage(_userDefaults) retain];
    __accessoryKeyNormalImage = [DialerSpecialKeyNormalImage(_userDefaults) retain];
    __accessoryKeyHighlightedImage = [DialerSpecialKeyHighlightedImage(_userDefaults) retain];
    __numberKeyNormalSideImage = [DialerNumberKeySideNormalImage(_userDefaults) retain];
    __numberKeyHighlightedSideImage = [DialerNumberKeySideHighlightedImage(_userDefaults) retain];
    __numberKeyNormalMiddleImage = [DialerNumberKeyMiddleNormalImage(_userDefaults) retain];
    __numberKeyHighlightedMiddleImage = [DialerNumberKeyMiddleHighlightedImage(_userDefaults) retain];
    __numberAreaBackgroundImage = [DialerNumberAreaBackgroundImage(_userDefaults) retain];
        
    // Make all our children views refresh with the new image (they might not exist yet, though)
    // You might be wondering why these widgets don't just add themselves as config observers and
    // refresh themselves.  The reason for this is that we consolidated all the image adjusting code
    // here, and we need to be sure the new images are built before the child views refresh themselves.
    if (_dialerView != nil) {
        [_dialerView.subviews makeObjectsPerformSelector:@selector(applyConfig)];
    }
}

- (NSString *)selectedCallerID {
    VBXOutgoingPhone *selected = [_accessor.callerIDs objectAtIndex:_selectedCallerIDIndex];
    return selected.name;
}

- (NSString *)stripNonNumbers:(NSString *)str {
    int length = str.length;
    
    unichar *chars = malloc(sizeof(unichar) * str.length);
    unichar *newChars = malloc(sizeof(unichar) * str.length);
    
    [str getCharacters:chars];
    
    int j = 0;
    for (int i = 0; i < length; i++) {
        unichar c = chars[i];
        if (c >= '0' && c <= '9') {
            newChars[j++] = c;
        }
    }
    
    NSString *newStr = [NSString stringWithCharacters:newChars length:j];
    
    free(chars);
    free(newChars);
    
    return newStr;
}

- (NSString *)formatPhoneNumber:(NSString *)number {
    if (number.length <= 1) return number;
    
    NSCharacterSet *nonDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    if ([number rangeOfCharacterFromSet:nonDigits].location != NSNotFound) return number;

    if ([number hasPrefix:@"0"]) return number;
    
    if ([number hasPrefix:@"1"]) {
        if (number.length < 4) number = [number stringByPaddingToLength:4 withString:@" " startingAtIndex:0];
        NSString *area = [number substringWithRange:NSMakeRange(1, 3)];
        if (number.length == 4) {
            return [NSString stringWithFormat:@"1 (%@)", area];
        }
        if (number.length <= 7) {
            NSString *prefix = [number substringFromIndex:4];
            return [NSString stringWithFormat:@"1 (%@) %@", area, prefix];
        }
        if (number.length <= 11) {
            NSString *prefix = [number substringWithRange:NSMakeRange(4, 3)];
            NSString *suffix = [number substringFromIndex:7];
            return [NSString stringWithFormat:@"1 (%@) %@-%@", area, prefix, suffix];
        }
        return number;
    }
    
    if (number.length <= 3) return number;
    if (number.length <= 7) {
        NSString *prefix = [number substringToIndex:3];
        NSString *suffix = [number substringFromIndex:3];
        return [NSString stringWithFormat:@"%@-%@", prefix, suffix];
    }
    if (number.length <= 10) {
        NSString *area = [number substringToIndex:3];
        NSString *prefix = [number substringWithRange:NSMakeRange(3, 3)];
        NSString *suffix = [number substringFromIndex:6];
        return [NSString stringWithFormat:@"(%@) %@-%@", area, prefix, suffix];
    }
    return number;
}

- (void)refreshView {
    [_numberAreaView setNumber:[self formatPhoneNumber:_phoneNumber]];
}

- (void)callerIdPressed {
    VBXObjectBuilder *builder = [VBXObjectBuilder sharedBuilder];
    [self.navigationController pushViewController:[builder callerIdController] animated:YES];
    _callerIdPickerIsOpen = YES;
}

- (void)deleteAfterDelay {
    [self deletePressed];
    [self performSelector:@selector(deleteAfterDelay) withObject:nil afterDelay:0.1];
}

- (void)deleteStartTimer {
    [self performSelector:@selector(deleteAfterDelay) withObject:nil afterDelay:1.0];
}

- (void)deleteStopTimer {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(deleteAfterDelay) object:nil];
}

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [UIColor blackColor];

    _dialerView = [[UIView alloc] initWithFrame:self.view.bounds];
    
    _callerIdControl = [[[CallerIdControl alloc] init] autorelease];
    [_dialerView addSubview:_callerIdControl];    
    _callerIdControl.left = 0; _callerIdControl.top = 0;
    
    [_callerIdControl addTarget:self action:@selector(callerIdPressed) forControlEvents:UIControlEventTouchUpInside];
    
    _numberAreaView = [[[NumberAreaView alloc] init] autorelease];
    [_dialerView addSubview:_numberAreaView];
    _numberAreaView.left = 0; _numberAreaView.top = _callerIdControl.bottom;
    
    NumberKey *num1 = [[[NumberKey alloc] initWithType:NumberKeyTypeSide number:@"1" letters:@""] autorelease];
    NumberKey *num2 = [[[NumberKey alloc] initWithType:NumberKeyTypeMiddle number:@"2" letters:@"ABC"] autorelease];
    NumberKey *num3 = [[[NumberKey alloc] initWithType:NumberKeyTypeSide number:@"3" letters:@"DEF"] autorelease];
    NumberKey *num4 = [[[NumberKey alloc] initWithType:NumberKeyTypeSide number:@"4" letters:@"GHI"] autorelease];
    NumberKey *num5 = [[[NumberKey alloc] initWithType:NumberKeyTypeMiddle number:@"5" letters:@"JKL"] autorelease];
    NumberKey *num6 = [[[NumberKey alloc] initWithType:NumberKeyTypeSide number:@"6" letters:@"MNO"] autorelease];
    NumberKey *num7 = [[[NumberKey alloc] initWithType:NumberKeyTypeSide number:@"7" letters:@"PQRS"] autorelease];
    NumberKey *num8 = [[[NumberKey alloc] initWithType:NumberKeyTypeMiddle number:@"8" letters:@"TUV"] autorelease];
    NumberKey *num9 = [[[NumberKey alloc] initWithType:NumberKeyTypeSide number:@"9" letters:@"WXYZ"] autorelease];
    NumberKey *num0 = [[[NumberKey alloc] initWithType:NumberKeyTypeMiddle number:@"0" letters:@""] autorelease];
    NumberKey *numPlus = [[[NumberKey alloc] initWithType:NumberKeyTypeSide number:@"+" letters:@""] autorelease];
    NumberKey *numPound = [[[NumberKey alloc] initWithType:NumberKeyTypeSide number:@"#" letters:@""] autorelease];
    
    [num1 addTarget:self action:@selector(numberPressed:) forControlEvents:UIControlEventTouchDown];
    [num2 addTarget:self action:@selector(numberPressed:) forControlEvents:UIControlEventTouchDown];
    [num3 addTarget:self action:@selector(numberPressed:) forControlEvents:UIControlEventTouchDown];
    [num4 addTarget:self action:@selector(numberPressed:) forControlEvents:UIControlEventTouchDown];
    [num5 addTarget:self action:@selector(numberPressed:) forControlEvents:UIControlEventTouchDown];    
    [num6 addTarget:self action:@selector(numberPressed:) forControlEvents:UIControlEventTouchDown];
    [num7 addTarget:self action:@selector(numberPressed:) forControlEvents:UIControlEventTouchDown];
    [num8 addTarget:self action:@selector(numberPressed:) forControlEvents:UIControlEventTouchDown];
    [num9 addTarget:self action:@selector(numberPressed:) forControlEvents:UIControlEventTouchDown];
    [num0 addTarget:self action:@selector(numberPressed:) forControlEvents:UIControlEventTouchDown];    
    [numPlus addTarget:self action:@selector(numberPressed:) forControlEvents:UIControlEventTouchDown];
    [numPound addTarget:self action:@selector(numberPressed:) forControlEvents:UIControlEventTouchDown];    
    
    AccessoryKey *contacts = [[[AccessoryKey alloc] initWithImage:[UIImage imageNamed:@"dialer-contacts-icon-mask.png"]] autorelease];
    AccessoryKey *backspace = [[[AccessoryKey alloc] initWithImage:[UIImage imageNamed:@"dialer-backspace-icon-mask.png"]] autorelease];
    
    [contacts addTarget:self action:@selector(chooseContactPressed) forControlEvents:UIControlEventTouchDown];
    [backspace addTarget:self action:@selector(deletePressed) forControlEvents:UIControlEventTouchDown];    
    [backspace addTarget:self action:@selector(deleteStartTimer) forControlEvents:UIControlEventTouchDown];    
    [backspace addTarget:self action:@selector(deleteStopTimer) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];    
    
    CallKey *call = [[[CallKey alloc] init] autorelease];
    [call addTarget:self action:@selector(callPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [_dialerView addSubview:num1];
    [_dialerView addSubview:num2];
    [_dialerView addSubview:num3];
    [_dialerView addSubview:num4];
    [_dialerView addSubview:num5];
    [_dialerView addSubview:num6];
    [_dialerView addSubview:num7];
    [_dialerView addSubview:num8];
    [_dialerView addSubview:num9];
    [_dialerView addSubview:num0];
    [_dialerView addSubview:numPlus];
    [_dialerView addSubview:numPound];
    [_dialerView addSubview:contacts];
    [_dialerView addSubview:backspace];
    [_dialerView addSubview:call];
    
    num1.left = 0; num1.top = _numberAreaView.bottom;
    num2.left = num1.right; num2.top = num1.top;
    num3.left = num2.right; num3.top = num1.top;
    num4.left = 0; num4.top = num1.bottom;
    num5.left = num4.right; num5.top = num1.bottom;
    num6.left = num5.right; num6.top = num1.bottom;
    num7.left = 0; num7.top = num4.bottom;
    num8.left = num4.right; num8.top = num4.bottom;
    num9.left = num5.right; num9.top = num4.bottom;
    numPlus.left = 0; numPlus.top = num7.bottom;    
    num0.left = numPlus.right; num0.top = num7.bottom;
    numPound.left = num0.right; numPound.top = num7.bottom;
    
    contacts.left = 0; contacts.top = numPlus.bottom;
    backspace.right = self.view.width; backspace.top = numPlus.bottom;
    call.left = contacts.right; call.top = contacts.top;
    
    [self.view addSubview:_dialerView];
}

- (void)viewDidLoad {
    _callerIdNumber = [[_userDefaults stringForKey:VBXUserDefaultsCallerId] retain];
    
    if (_callerIdNumber == nil) {
        _callerIdNumber = [((VBXOutgoingPhone *)[_accessor.callerIDs objectAtIndex:0]).phone retain];
    }
    
    _accessor.delegate = self;
    [_accessor loadCallerIDs];
    
    // Default to whatever our last used number was...
    [_callerIdControl setCallerId:[_userDefaults stringForKey:VBXUserDefaultsCallerId]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDefaultsDidChange:)
        name:NSUserDefaultsDidChangeNotification object:nil];

    if (!_phoneNumber) self.phoneNumber = [NSMutableString string];
    
    [_phoneNumber setString:_initialPhoneNumber];
    [_numberAreaView setNumber:_phoneNumber];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshView];
    
    if (_callerIdPickerIsOpen) {
        _callerIdPickerIsOpen = NO;
        [_callerIdNumber release];
        _callerIdNumber = [[_userDefaults stringForKey:VBXUserDefaultsCallerId] retain];
        [_callerIdControl setCallerId:_callerIdNumber];
    }
}

- (void)viewDidUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _accessor.delegate = nil;
}

- (void)chooseContactPressed {
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    picker.displayedProperties = [NSArray arrayWithObject:[NSNumber numberWithInt:kABPersonPhoneProperty]];
    [self.navigationController presentModalViewController:picker animated:YES];
    [picker release];
}

- (void)makeCallAfterDelay {
    _callIsBeingScheduled = NO;
    [_accessor call:_phoneNumber usingCallerID:_callerIdNumber];
}

- (void)callPressed {
    if (_callerIdNumber == nil || _callerIdNumber.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Emtpy Caller ID", @"Dialer: Title for alert when caller id is not set")
                                                        message:LocalizedString(@"You must set your caller ID before placing a call.", @"Dialer: Body for alert when caller id is not set.")
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    } else if (VBXStripNonDigitsFromString(VBXFormatPhoneNumber(_phoneNumber)).length == 0) {
        // Just don't do anything.  The native dialer does nothing until you enter a number.
    } else {
        [self setPromptAndDimView:LocalizedString(@"Calling...", @"Dialer: Navigation bar prompt shown when call is being scheduled.")];
        [self performSelector:@selector(makeCallAfterDelay) withObject:nil afterDelay:1.5];
        
        _callIsBeingScheduled = YES;
    }
}

- (void)numberPressed:(id)sender {
    NumberKey *button = sender;
    [_phoneNumber appendString:[button keyValue]];
    [self refreshView];
}

- (void)deletePressed {
    if (_phoneNumber.length < 1) return;
    NSRange range = NSMakeRange([_phoneNumber length] - 1, 1);
    [_phoneNumber deleteCharactersInRange:range];
    [self refreshView];
}

- (void)cancelPressed {
    if (_callIsBeingScheduled) {
        // They pressed cancel right as we were about to place a call, so it only cancels the
        // call not the whole dialer
        [self unsetPromptAndUndim];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(makeCallAfterDelay) object:nil];
    } else {
        [[self parentViewController] dismissModalViewControllerAnimated:YES];
    }
}

- (void)userDefaultsDidChange:(NSNotification *)notification {
    [self refreshView];
}

#pragma mark PeoplePicker delegate methods

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [self.navigationController dismissModalViewControllerAnimated:YES];
}


- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person {

    // We return YES so the details on this person is displayed.
    return YES;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier {
    
    NSString *name = [NSString stringWithFormat:@"%@ %@",
                      (NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty),
                      (NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty)];
    
    
    ABMultiValueRef phoneProperty = ABRecordCopyValue(person, property);
	NSString *phone = (NSString *)ABMultiValueCopyValueAtIndex(phoneProperty, identifier);	
    
    debug(@"Name = %@", name);
    debug(@"Phone Number = %@", phone);
    
    [_phoneNumber setString:[self stripNonNumbers:phone]];
    [self refreshView];
    
    [self.navigationController dismissModalViewControllerAnimated:YES];

    // Don't do the default action - we'll handle closing the picker
    return NO;
}

#pragma mark DialerAccessor delegate methods

- (void)accessorCallerIDsResponseArrived:(VBXDialerAccessor *)accessor fromCache:(BOOL)fromCache {
    if (accessor.callerIDs.count > 0 && [[_callerIdControl callerId] length] < 1) {
        _callerIdNumber = [[_accessor.callerIDs objectAtIndex:0] phone];
        [_userDefaults setValue:_callerIdNumber forKey:VBXUserDefaultsCallerId];
        [_callerIdControl setCallerId:_callerIdNumber];

    }
    [self refreshView];
}

- (void)removePromptAfterDelay {
    [self unsetPromptAndUndim];
}

- (void)accessorDidPlaceCall:(VBXDialerAccessor *)accessor {
    self.navigationItem.prompt = LocalizedString(@"Done! You'll get a call in a moment.", @"Dialer: Navigation bar prompt shown when call was successfully scheduled.");
    [self performSelector:@selector(removePromptAfterDelay) withObject:nil afterDelay:1.0];
}

- (void)accessor:(VBXDialerAccessor *)accessor callFailedWithError:(NSError *)error {
    debug(@"%@", [error detailedDescription]);
    [self unsetPromptAndUndim];

    if ([error isTwilioErrorWithCode:VBXErrorLoginRequired]) return;
    [UIAlertView showAlertViewWithTitle:LocalizedString(@"Call could not be placed", @"Dialer: Title for alert shown when call fails.") forError:error];
}

#pragma mark State saving

- (NSDictionary *)saveState {
    NSMutableDictionary *state = [NSMutableDictionary dictionary];
    
    if (_phoneNumber) { 
        [state setObject:_phoneNumber forKey:@"to"];
    }

    if (_callerIdNumber != nil) {
        [state setObject:_callerIdNumber forKey:@"from"];
    }
    
    return state;
}

- (void)restoreState:(NSDictionary *)state {
    
    // Make our view load early so we can fiddle with it.
    [self view];
    
    NSString *phoneValue = [state stringForKey:@"to"];
    NSString *fromValue = [state stringForKey:@"from"];
    
    if (phoneValue) {
        self.phoneNumber = [NSMutableString stringWithString:phoneValue];
        [_numberAreaView setNumber:self.phoneNumber];
    }
    
    if (fromValue) {
        _callerIdNumber = [fromValue retain];
        [_callerIdControl setCallerId:_callerIdNumber];
    }
}

- (void)setPromptAndDimView:(NSString *)title {
    [super setPromptAndDimView:title];
    
    [UIView beginAnimations:@"StayInPlace" context:nil];
    [UIView setAnimationDuration:0.35];
    _dialerView.top -= 74 - TOOLBAR_HEIGHT;
    [UIView commitAnimations];
}

- (void)unsetPromptAndUndim {
    [super unsetPromptAndUndim];

    [UIView beginAnimations:@"StayInPlace" context:nil];
    [UIView setAnimationDuration:0.35];
    _dialerView.top = 0;
    [UIView commitAnimations];
}


@end
