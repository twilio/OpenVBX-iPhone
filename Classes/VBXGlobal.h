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

#import <Foundation/Foundation.h>

#define DEFAULT_BASE_URL @""
#define CLIENT_VERSION  @"1.0"

#define DECLARE_SINGLETON(type, name)  static type *name = nil; if (name) return name

#define debug(fmt...)   NSLog(@"%s:%d %@", __FUNCTION__, __LINE__, [NSString stringWithFormat:fmt])
#define debugSize(size)   NSLog(@"%s:%d size { %f, %f }", __FUNCTION__, __LINE__, size.width, size.height)
#define debugRect(rect)   NSLog(@"%s:%d rect { %f, %f, %f, %f }", __FUNCTION__, __LINE__, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)
#define trace()         debug(@"")

#define RGBHEXCOLOR(rgb) [UIColor colorWithRed:((rgb & 0xff0000) >> 16)/255.0f green:((rgb & 0xff00) >> 8)/255.0f blue:(rgb & 0xff)/255.0f alpha:1.0]

#define ROW_HEIGHT 44
#define TOOLBAR_HEIGHT 44
#define LANDSCAPE_TOOLBAR_HEIGHT 33
#define KEYBOARD_HEIGHT 216
#define LANDSCAPE_KEYBOARD_HEIGHT 160

/**
 * Returns the screen dimensions minus the status bar, with origin 0,0.
 */
CGRect VBXApplicationFrame();

/**
 * Returns the bounds for the area under the navigation bar/
 */
CGRect VBXNavigationFrame();

/**
 * Returns the area under the navigation bar minus the keyboard.
 */
CGRect VBXNavigationFrameWithKeyboard();

/**
 * Returns a date object for a string like 2010-01-21T15:53:02-08:00
 * Converts from GMT to local time in the process.
 */
NSDate *VBXParseISODateString(NSString *input);

/**
 * Returns a pretty string with one of the following, and in this order:
 * H:MMam, Yesterday, Day of Week (up to six days ago), Date in form of M/D/YY
 */
NSString *VBXDateToRelativeTime(NSDate *date);

/**
 * Returns a string either in the form of H:MMam (if the date is in the
 * current calendar day), or M/D/YY H:MMam if it happened on a diff. day.
 * H:MMam, Yesterday, Day of Week (up to six days ago), Date in form of M/D/YY
 */
NSString *VBXDateToDateAndTimeString(NSDate *date);

/**
 * Returns an array of parts of a string, meant to be fed into the StringPartLabel
 */
NSArray *VBXStringPartsForUpdatedAtDate(NSDate *date);

/**
 * 
 */
NSString *VBXStripNonDigitsFromString(NSString *str);

/**
 * Formats a number, US-style
 */
NSString *VBXFormatPhoneNumber(NSString *number);

/**
 * Takes in a grayscale source image, and changes the Hue, Saturation,
 * and Value of each pixel in the image to match the specified color.
 * The brighest pixels in the source image (i.e. those with the highest
 * value) will appear the same as the color passed in.  The darker pixels
 * in the source image will have the same Hue and Saturation as the given
 * color, but their value will be lower (i.e. they will be darker).
 */
UIImage *VBXAdjustImageWithColor(UIImage *image, UIColor *color);

/**
 * Takes in an image (probably grayscale) and colorizes it similar to how
 * an "Adjustment Layer" w/ Colorize enabled works in PhotoShop.
 * 
 * Hue is [0.0, 360.0]
 * Saturation is [0.0, 1.0]
 * Lightness Factor is [-1.0, 1.0], and is multiplied against the lightness
 *   value from the source image: newLightness = (oldLightness * (1 + lightNessFactor))
 */
UIImage *VBXAdjustImageWithHSL(UIImage *image, CGFloat hue, CGFloat saturation, CGFloat lightnessFactor);

struct VBXHSL {
    int hue;
    int saturation;
    int lightnessFactor;
};
typedef struct VBXHSL VBXHSL;

static __inline__ VBXHSL VBXHSLMake(int hue, int saturation, int lightnessFactor) {
    VBXHSL hsl;
    hsl.hue = hue;
    hsl.saturation = saturation;
    hsl.lightnessFactor = lightnessFactor;
    return hsl;
}

NSString *NSStringFromVBXHSL(VBXHSL hsl);

/**
 * The same as AdjustImageWithHSL, but accepts parameters in the same format that Photoshop
 * gives them to you.
 *
 * Hue is [0 - 360]
 * Saturation is [0 - 100]
 * Lightness is [-100 - 100]
 */
UIImage *VBXAdjustImageWithPhotoshopHSL(UIImage *image, VBXHSL hsl);
UIImage *VBXAdjustImageWithPhotoshopHSLWithCache(NSUserDefaults *userDefaults, NSString *imageName, NSString *state, VBXHSL hsl);

void CGContextAddRoundedRect (CGContextRef c, CGRect rect, int corner_radius);

NSString *VBXStringForSecTrustResultType(SecTrustResultType resultType);

/**
 * Wipes all local state.
 */
void VBXClearAllData();