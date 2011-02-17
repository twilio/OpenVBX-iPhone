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

#import "VBXGlobal.h"
#import "VBXStringPartLabel.h"
#import "NSExtensions.h"
#import "VBXObjectBuilder.h"
#import "VBXUserDefaultsKeys.h"
#import "NSExtensions.h"
#import "NSURLExtensions.h"

CGRect VBXApplicationFrame() {
    CGRect appFrame = [UIScreen mainScreen].applicationFrame;
    return CGRectMake(0, 0, appFrame.size.width, appFrame.size.height);
}

CGRect VBXNavigationFrame() {
    CGRect appFrame = VBXApplicationFrame();
    return CGRectMake(0, 0, appFrame.size.width, appFrame.size.height - TOOLBAR_HEIGHT);
}

CGRect VBXNavigationFrameWithKeyboard() {
    CGRect navFrame = VBXNavigationFrame();
    return CGRectMake(0, 0, navFrame.size.width, navFrame.size.height - KEYBOARD_HEIGHT);
}

NSDate *VBXParseISODateString(NSString *input) {

    // This trailing time zone info is always +00:00 (because everything is UTC),
    // so we just remove it because I can't figure out how to get the date format
    // string to parse it.
    input = [input stringByReplacingOccurrencesOfString:@"+00:00" withString:@""];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    
    // Convert from GMT to local time while we're at it
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    
    NSDate *date = [formatter dateFromString:input];
    [formatter release];
    
    return date;
}

NSString *VBXDateToRelativeTime(NSDate *date) {
    NSString *result = nil;
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];

    NSDate *midnightToday = [cal dateFromComponents:[cal components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:now]];    
    NSTimeInterval midnightTodaySeconds = [midnightToday timeIntervalSince1970];
    
    NSDate *midnightYesterday = [NSDate dateWithTimeIntervalSince1970:(midnightTodaySeconds - 86400)];
    NSDate *midnightSixDaysAgo = [NSDate dateWithTimeIntervalSince1970:(midnightTodaySeconds - (6 * 86400))];
    
    NSTimeInterval midnightYesterdaySeconds = [midnightYesterday timeIntervalSince1970];
    NSTimeInterval midnightSixDaysAgoSeconds = [midnightSixDaysAgo timeIntervalSince1970];    
    NSTimeInterval dateSeconds = [date timeIntervalSince1970];
    
    if (dateSeconds > midnightTodaySeconds) {
        // Return something like 8:00pm
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        result = [formatter stringFromDate:date];
        [formatter release];
    } else if (dateSeconds > midnightYesterdaySeconds) {
        result = @"Yesterday";
    } else if (dateSeconds > midnightSixDaysAgoSeconds) {
        // Show the day of the week
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"EEEE"];
        result = [formatter stringFromDate:date];
        [formatter release];
    } else {        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        [formatter setTimeStyle:NSDateFormatterNoStyle];
        result = [formatter stringFromDate:date];
        [formatter release];
    }
    
    return result;
}

NSString *VBXDateToDateAndTimeString(NSDate *date) {
    NSString *result = nil;
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    
    NSDate *midnightToday = [cal dateFromComponents:[cal components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:now]];    
    NSTimeInterval midnightTodaySeconds = [midnightToday timeIntervalSince1970];
        
    NSTimeInterval dateSeconds = [date timeIntervalSince1970];
    
    if (dateSeconds > midnightTodaySeconds) {
        // Return something like 8:00pm
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        result = [formatter stringFromDate:date];
        [formatter release];
    } else {        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        result = [formatter stringFromDate:date];
        [formatter release];
    }
    
    return result;
}

NSArray *VBXStringPartsForUpdatedAtDate(NSDate *date) {    
    
    NSString *dateStr = nil;
    NSString *timeStr = nil;
    NSString *amPmStr = nil;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
    
    dateStr = [[formatter stringFromDate:date] stringByTrimmingWhitespace];
    
    [formatter setDateFormat:@"h:mm"];
    
    timeStr = [[formatter stringFromDate:date] stringByTrimmingWhitespace];
    [formatter setDateFormat:@"a"];    
    amPmStr = [[[formatter stringFromDate:date] uppercaseString] stringByTrimmingWhitespace];
    
    [formatter release];
    
    return [NSArray arrayWithObjects:
            [VBXStringPart partWithText:@"Updated" font:[UIFont boldSystemFontOfSize:13]],
            [VBXStringPart partWithText:@"  " font:[UIFont boldSystemFontOfSize:13]],
            [VBXStringPart partWithText:dateStr font:[UIFont systemFontOfSize:13]],
            [VBXStringPart partWithText:@"  " font:[UIFont boldSystemFontOfSize:13]],
            [VBXStringPart partWithText:timeStr font:[UIFont boldSystemFontOfSize:13]],
            [VBXStringPart partWithText:@" " font:[UIFont boldSystemFontOfSize:13]],
            [VBXStringPart partWithText:amPmStr font:[UIFont systemFontOfSize:13]],
            nil];
}

NSString *VBXStripNonDigitsFromString(NSString *str) {
    int length = str.length;
    
    unichar *chars = malloc(sizeof(unichar) * str.length);
    unichar *newChars = malloc(sizeof(unichar) * str.length);
    
    [str getCharacters:chars];
    
    int j = 0;
    for (int i = 0; i < length; i++) {
        unichar c = chars[i];
        if ((c >= '0' && c <= '9') || c == '+') {
            newChars[j++] = c;
        }
    }
    
    NSString *newStr = [NSString stringWithCharacters:newChars length:j];
    
    free(chars);
    free(newChars);
    
    return newStr;
}

NSString *VBXFormatPhoneNumber(NSString *plainNumber) {
    plainNumber = VBXStripNonDigitsFromString(plainNumber);
    
    if (plainNumber.length == 11 && [[plainNumber substringToIndex:1] isEqualToString:@"1"]) {
        plainNumber = [plainNumber substringFromIndex:1];
    }

    if (plainNumber.length > 0 && [[plainNumber substringToIndex:1] isEqualToString:@"+"]) {
        return plainNumber;
    }
    
    unichar *chars = malloc(sizeof(unichar) * plainNumber.length);
    [plainNumber getCharacters:chars];
    
    NSString *str = nil;
    
    NSString *formatStr = nil;
    
    // Note: It's important we not have any trailing punctuation on these strings.  i.e. "415" gets formatted 
    // as "(415" not "(415)".  This helps us use this function for formatting text as you type.  The reason
    // is that if you have the string "(415)" with the trailing close paren, and the user presses backspace, 
    // the resulting string is "(415" which gets re-formatted as "(415)".  You're effectively stuck.  Whereas
    // if you have the string "(415" and you press backspace, you get "(41" which reformats to "(41".
    switch (plainNumber.length) {
        case 0: formatStr = @""; break;
        case 1: formatStr = @"(%C"; break;
        case 2: formatStr = @"(%C%C"; break;
        case 3: formatStr = @"(%C%C%C"; break;
        case 4: formatStr = @"(%C%C%C) %C"; break;
        case 5: formatStr = @"(%C%C%C) %C%C"; break;
        case 6: formatStr = @"(%C%C%C) %C%C%C"; break;
        case 7: formatStr = @"(%C%C%C) %C%C%C-%C"; break;
        case 8: formatStr = @"(%C%C%C) %C%C%C-%C%C"; break;
        case 9: formatStr = @"(%C%C%C) %C%C%C-%C%C%C"; break;
        default: 
        case 10: formatStr = @"(%C%C%C) %C%C%C-%C%C%C%C"; break;
    }
    
    str = [NSString stringWithFormat:formatStr,
           chars[0], chars[1], chars[2], chars[3], chars[4], chars[5],
           chars[6], chars[7], chars[8], chars[9]];

    free(chars);
    
    return str;
}

// Color conversion routines from http://www.cs.rit.edu/~ncs/color/t_convert.html
// r,g,b values are from 0 to 1
// h = [0,360], s = [0,1], v = [0,1]
//		if s == 0, then h = -1 (undefined)
void RGBtoHSV( float r, float g, float b, float *h, float *s, float *v )
{
	float min, max, delta;
	min = MIN( r, MIN(g, b) );
	max = MAX( r, MAX(g, b) );
	*v = max;				// v
	delta = max - min;
	if( max != 0 )
		*s = delta / max;		// s
	else {
		// r = g = b = 0		// s = 0, v is undefined
		*s = 0;
		*h = -1;
		return;
	}
    if( r == max )
        *h = ( g - b ) / delta;		// between yellow & magenta
    else if( g == max )
        *h = 2 + ( b - r ) / delta;	// between cyan & yellow
    else
        *h = 4 + ( r - g ) / delta;	// between magenta & cyan
	*h *= 60;				// degrees
	if( *h < 0 )
		*h += 360;
}

void HSVtoRGB( float *r, float *g, float *b, float h, float s, float v )
{
	int i;
	float f, p, q, t;
	if( s == 0 ) {
		// achromatic (grey)
		*r = *g = *b = v;
		return;
	}
	h /= 60;			// sector 0 to 5
	i = floor( h );
	f = h - i;			// factorial part of h
	p = v * ( 1 - s );
	q = v * ( 1 - s * f );
	t = v * ( 1 - s * ( 1 - f ) );
	switch( i ) {
		case 0:
			*r = v;
			*g = t;
			*b = p;
			break;
		case 1:
			*r = q;
			*g = v;
			*b = p;
			break;
		case 2:
			*r = p;
			*g = v;
			*b = t;
			break;
		case 3:
			*r = p;
			*g = q;
			*b = v;
			break;
		case 4:
			*r = t;
			*g = p;
			*b = v;
			break;
		default:		// case 5:
			*r = v;
			*g = p;
			*b = q;
			break;
	}
}

UIImage *VBXAdjustImageWithColor(UIImage *image, UIColor *color) {
    CGImageRef imageRef = image.CGImage;    
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);    
    int bitmapBytesPerRow = width * 4;
    int bitmapByteCount = (bitmapBytesPerRow * height);    
    void *bitmapData = NULL;
    UIImage *newImage = nil;
    CGColorSpaceRef colorSpaceRef = NULL;
    CGContextRef context = NULL;
    CGDataProviderRef provider = NULL;
    CGImageRef newImageRef = NULL;
    
    bitmapData = calloc(bitmapByteCount, 1);
    
    if (bitmapData == NULL) {
        goto Error;
    }
    
    colorSpaceRef = CGColorSpaceCreateDeviceRGB();    
    context = CGBitmapContextCreate (bitmapData,
                                     width,
                                     height,
                                     8,      // bits per component
                                     bitmapBytesPerRow,
                                     colorSpaceRef,
                                     kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    
    const CGFloat *rgba = CGColorGetComponents(color.CGColor);
    CGFloat colorH = 0.0;
    CGFloat colorS = 0.0;    
    CGFloat colorV = 0.0;
    
    RGBtoHSV(rgba[0], rgba[1], rgba[2], &colorH, &colorS, &colorV);
    
    unsigned char *data = CGBitmapContextGetData(context);
    
    if (data != NULL) {
        CGFloat maxValue = 0.0;
        CGFloat minValue = 1.0;
        for (int x = 0; x < width; x++) {
            for (int y = 0; y < height; y++) {
                int offset = 4 * ((width * y) + x);
                float r = data[offset] / 255.0f;
                float g = data[offset + 1] / 255.0f;
                float b = data[offset + 2] / 255.0f;                
                
                float h = 0.0;
                float s = 0.0;
                float v = 0.0;
                
                RGBtoHSV(r, g, b, &h, &s, &v);
                
                maxValue = MAX(v, maxValue);
                minValue = MIN(v, minValue);
            }
        }
        
        for (int x = 0; x < width; x++) {
            for (int y = 0; y < height; y++) {
                int offset = 4 * ((width * y) + x);
                float r = data[offset] / 255.0f;
                float g = data[offset + 1] / 255.0f;
                float b = data[offset + 2] / 255.0f;
                float a = data[offset + 3] / 255.0f;
                
                float origH = 0.0;
                float origS = 0.0;
                float origV = 0.0;
                
                RGBtoHSV(r, g, b, &origH, &origS, &origV);
                
                float h = colorH;
                float s = colorS;
                float v = colorV - (maxValue - origV);
                
                r = g = b = 0.0;
                
                HSVtoRGB(&r, &g, &b, h, s, v);
                
                unsigned char newR = (int)round(r * 255.0) & 0xff;
                unsigned char newG = (int)round(g * 255.0) & 0xff;
                unsigned char newB = (int)round(b * 255.0) & 0xff;
                unsigned char newA = (int)round(a * 255.0) & 0xff;
                
                
                if (newA == 0) {
                    newR = newG = newB = 0;
                }
                
                data[offset] = newR;
                data[offset + 1] = newG;
                data[offset + 2] = newB;
                data[offset + 3] = newA;
            }
        }
    }
    
    provider = CGDataProviderCreateWithData(NULL, data, bitmapByteCount, NULL);
    
    newImageRef = CGImageCreate (
                                            width,
                                            height,
                                            8,
                                            32,
                                            bitmapBytesPerRow,
                                            colorSpaceRef,
                                            kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast,
                                            provider,
                                            NULL,
                                            false,
                                            kCGRenderingIntentDefault
                                            );

    newImage = [UIImage imageWithCGImage:newImageRef];
Error:
    if (newImageRef != NULL) {
        CGImageRelease(newImageRef);
    }
    if (colorSpaceRef != NULL) {
        CGColorSpaceRelease(colorSpaceRef);
    }
    if (context != NULL) {
        CGContextRelease(context);
    }
    if (provider != NULL) {
        CGDataProviderRelease(provider);
    }
    return newImage;
}

// Formulas for RGB <-> HSL conversion ported from:
//   http://www.geekymonkey.com/Programming/CSharp/RGB2HSL_HSL2RGB.htm
void RGBtoHSL(float r, float g, float b, float *h, float *s, float *l) {
    double v;
    double m;
    double vm;
    double r2, g2, b2;
    
    *h = 0; // default to black
    *s = 0;
    *l = 0;
    v = MAX(r,g);
    v = MAX(v,b);
    m = MIN(r,g);
    m = MIN(m,b);
    *l = (m + v) / 2.0;
    if (*l <= 0.0) {
        return;
    }
    vm = v - m;
    *s = vm;
    if (*s > 0.0) {
        *s /= (*l <= 0.5) ? (v + m ) : (2.0 - v - m) ;
    }
    else
    {
        return;
    }
    r2 = (v - r) / vm;
    g2 = (v - g) / vm;
    b2 = (v - b) / vm;
    if (r == v)
    {
        *h = (g == m ? 5.0 + b2 : 1.0 - g2);
    }
    else if (g == v)
    {
        *h = (b == m ? 1.0 + r2 : 3.0 - b2);
    }
    else
    {
        *h = (r == m ? 3.0 + g2 : 5.0 - r2);
    }
    *h /= 6.0;
}

void HSLtoRGB(float *r, float *g, float *b, float h, float s, float l) {
    double v;
    *r = l;   // default to gray
    *g = l;
    *b = l;
    v = (l <= 0.5) ? (l * (1.0 + s)) : (l + s - l * s);
    if (v > 0)
    {
        double m;
        double sv;
        int sextant;
        double fract, vsf, mid1, mid2;
        
        m = l + l - v;
        sv = (v - m ) / v;
        h *= 6.0;
        sextant = (int)h;
        fract = h - sextant;
        vsf = v * sv * fract;
        mid1 = m + vsf;
        mid2 = v - vsf;
        switch (sextant)
        {
            case 0:
                *r = v;
                *g = mid1;
                *b = m;
                break;
            case 1:
                *r = mid2;
                *g = v;
                *b = m;
                break;
            case 2:
                *r = m;
                *g = v;
                *b = mid1;
                break;
            case 3:
                *r = m;
                *g = mid2;
                *b = v;
                break;
            case 4:
                *r = mid1;
                *g = m;
                *b = v;
                break;
            case 5:
                *r = v;
                *g = m;
                *b = mid2;
                break;
        }
    }
}

void ColorizeFilter(float inR, float inG, float inB, float inA, float *outR, float *outG, float *outB, float *outA, void *context) {
    // Our params are in the order of { hue, saturation, lightnessFactor }
    float *params = (float *)context;
    
    float newHue = params[0] / 360.0;
    float newSaturation = params[1];
    float lightnessFactor = params[2];
    
    float h = 0;
    float s = 0;
    float l = 0;
    
    RGBtoHSL(inR, inG, inB, &h, &s, &l);
    
    h = MAX(0.0, MIN(1.0, newHue));
    s = MAX(0.0, MIN(1.0, newSaturation));
    l = MAX(0.0, MIN(1.0, (l * (1 + lightnessFactor))));
    
    HSLtoRGB(outR, outG, outB, h, s, l);
    
    *outA = inA;
}

UIImage *AdjustImageWithFunction(UIImage *image, void (*filter)(float, float, float, float, float *, float *, float *, float *, void *), void *context) {
    CGImageRef imageRef = image.CGImage;    
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);    
    int bitmapBytesPerRow = width * 4;
    int bitmapByteCount = (bitmapBytesPerRow * height);    
    void *bitmapData = NULL;
    UIImage *newImage = nil;
    CGColorSpaceRef colorSpaceRef = NULL;
    CGContextRef bitmapContext = NULL;
    CGDataProviderRef provider = NULL;
    CGImageRef newImageRef = NULL;
    
    bitmapData = calloc(bitmapByteCount, 1);
    
    if (bitmapData == NULL) {
        goto Error;
    }
    
    colorSpaceRef = CGColorSpaceCreateDeviceRGB();    
    bitmapContext = CGBitmapContextCreate(bitmapData,
                                    width,
                                    height,
                                    8,      // bits per component
                                    bitmapBytesPerRow,
                                    colorSpaceRef,
                                    kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast);

    CGContextDrawImage(bitmapContext, CGRectMake(0, 0, width, height), imageRef);
     
    unsigned char *data = CGBitmapContextGetData(bitmapContext);
     
    if (data != NULL) {        
            
        for (int x = 0; x < width; x++) {
        for (int y = 0; y < height; y++) {
                int offset = 4 * ((width * y) + x);
                float r = data[offset] / 255.0f;
                float g = data[offset + 1] / 255.0f;
                float b = data[offset + 2] / 255.0f;
                float a = data[offset + 3] / 255.0f;
                
                filter(r, g, b, a, &r, &g, &b, &a, context);
                 
                unsigned char newR = (int)round(r * 255.0) & 0xff;
                unsigned char newG = (int)round(g * 255.0) & 0xff;
                unsigned char newB = (int)round(b * 255.0) & 0xff;
                unsigned char newA = (int)round(a * 255.0) & 0xff;
            
                data[offset] = newR;
                data[offset + 1] = newG;
                data[offset + 2] = newB;
                data[offset + 3] = newA;
             }
        }
    }

     provider = CGDataProviderCreateWithData(NULL, data, bitmapByteCount, NULL);
     
     newImageRef = CGImageCreate (
                                             width,
                                             height,
                                             8,
                                             32,
                                             bitmapBytesPerRow,
                                             colorSpaceRef,
                                             kCGImageAlphaPremultipliedLast,
                                             provider,
                                             NULL,
                                             false,
                                             kCGRenderingIntentDefault
                                             );
     
     newImage = [UIImage imageWithCGImage:newImageRef];

Error:
    if (newImageRef != NULL) {
        CGImageRelease(newImageRef);
    }
    if (colorSpaceRef != NULL) {
        CGColorSpaceRelease(colorSpaceRef);
    }
    if (bitmapContext != NULL) {
        CGContextRelease(bitmapContext);
    }
    if (provider != NULL) {
        CGDataProviderRelease(provider);
    }
    return newImage;     
}

UIImage *VBXAdjustImageWithHSL(UIImage *image, CGFloat hue, CGFloat saturation, CGFloat lightnessFactor) {
    float params[3] = { hue, saturation, lightnessFactor };
    return AdjustImageWithFunction(image, ColorizeFilter, params);
}

UIImage *VBXAdjustImageWithPhotoshopHSL(UIImage *image, VBXHSL hsl) {
    float params[3] = { hsl.hue * 1.0f, (hsl.saturation / 100.0f), (hsl.lightnessFactor / 100.0f) };
    return AdjustImageWithFunction(image, ColorizeFilter, params);
}

NSString *NSStringFromHSL(VBXHSL hsl) {
    return [NSString stringWithFormat:@"HSL: {%d, %d, %d}", hsl.hue, hsl.saturation, hsl.lightnessFactor];
}

NSString *PathForDocument(NSString *documentName) {
    NSArray* directories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);    
    return [[directories objectAtIndex:0] stringByAppendingPathComponent:documentName];
}

UIImage *VBXAdjustImageWithPhotoshopHSLWithCache(NSUserDefaults *userDefaults, NSString *imageName, NSString *state, VBXHSL hsl) {    
    NSString *key = [NSString stringWithFormat:@"last_hsl_for_%@_%@", state, imageName];
    NSString *cachedFileName = [NSString stringWithFormat:@"cached_%@_%@", state, imageName];

    NSString *lastHSLString = [userDefaults stringForKey:key];
    NSString *HSLString = NSStringFromHSL(hsl);
    
    UIImage *image = nil;
    
    if ([lastHSLString isEqualToString:HSLString]) {
        // Our cached copy is good
        image = [UIImage imageWithContentsOfFile:PathForDocument(cachedFileName)];
    }
    
    if (image == nil) {
        image = VBXAdjustImageWithPhotoshopHSL([UIImage imageNamed:imageName], hsl);
        NSData *imagePNGData = [UIImagePNGRepresentation(image) retain];                
        [imagePNGData writeToFile:PathForDocument(cachedFileName) atomically:YES];
        [imagePNGData release];
        
        [userDefaults setObject:HSLString forKey:key];
        [userDefaults synchronize];        
    }
    
    return image;
}

/**
 * Taken from:
 * http://www.iphonedevforums.com/forum/sdk-coding-help/200-problem-make-rounded-rectangle.html#post593
 */
void CGContextAddRoundedRect (CGContextRef c, CGRect rect, int corner_radius) {  
    int x_left = rect.origin.x;  
    int x_left_center = rect.origin.x + corner_radius;  
    int x_right_center = rect.origin.x + rect.size.width - corner_radius;  
    int x_right = rect.origin.x + rect.size.width;  
    int y_top = rect.origin.y;  
    int y_top_center = rect.origin.y + corner_radius;  
    int y_bottom_center = rect.origin.y + rect.size.height - corner_radius;  
    int y_bottom = rect.origin.y + rect.size.height;  
    
    /* Begin! */  
    CGContextBeginPath(c);  
    CGContextMoveToPoint(c, x_left, y_top_center);  
    
    /* First corner */  
    CGContextAddArcToPoint(c, x_left, y_top, x_left_center, y_top, corner_radius);  
    CGContextAddLineToPoint(c, x_right_center, y_top);  
    
    /* Second corner */  
    CGContextAddArcToPoint(c, x_right, y_top, x_right, y_top_center, corner_radius);  
    CGContextAddLineToPoint(c, x_right, y_bottom_center);  
    
    /* Third corner */  
    CGContextAddArcToPoint(c, x_right, y_bottom, x_right_center, y_bottom, corner_radius);  
    CGContextAddLineToPoint(c, x_left_center, y_bottom);  
    
    /* Fourth corner */  
    CGContextAddArcToPoint(c, x_left, y_bottom, x_left, y_bottom_center, corner_radius);  
    CGContextAddLineToPoint(c, x_left, y_top_center);  
    
    /* Done */  
    CGContextClosePath(c);
}

NSString *VBXStringForSecTrustResultType(SecTrustResultType resultType) {
    switch (resultType) {
        case kSecTrustResultProceed:
            return @"kSecTrustResultProceed";
        case kSecTrustResultUnspecified:
            return @"kSecTrustResultUnspecified";
        case kSecTrustResultConfirm:
            return @"kSecTrustResultConfirm";
        case kSecTrustResultRecoverableTrustFailure:
            return @"kSecTrustResultRecoverableTrustFailure";
        case kSecTrustResultInvalid:
            return @"kSecTrustResultInvalid";
        case kSecTrustResultDeny:
            return @"kSecTrustResultDeny";
        case kSecTrustResultFatalTrustFailure:
            return @"kSecTrustResultFatalTrustFailure";
        case kSecTrustResultOtherError:
            return @"kSecTrustResultOtherError";
        default:
            return @"UNKNOWN";
    }
}

void VBXClearAllData() {
    VBXObjectBuilder *builder = [VBXObjectBuilder sharedBuilder];
    
    NSMutableArray *allCaches = [builder allCaches];
    NSURLCredentialStorage *credentialStorage = [builder credentialStorage];
    NSHTTPCookieStorage *cookieStorage = [builder cookieStorage];
    NSUserDefaults *userDefaults = [builder userDefaults];
    
    NSURL *url = [userDefaults VBXURLForKey:VBXUserDefaultsBaseURL];
    NSString *realm = [userDefaults stringForKey:VBXUserDefaultsAuthenticationRealm];
    NSArray *protectionSpaces = [credentialStorage protectionSpacesMatchingURL:url realm:realm];
    
    // Bye bye caches
    [allCaches makeObjectsPerformSelector:@selector(removeAllObjects)];
    // Bye bye login info
    [credentialStorage removeCredentialsForProtectionSpaces:protectionSpaces];
    // Bye bye cookies
    if ([userDefaults VBXURLForKey:VBXUserDefaultsBaseURL]) {
        [cookieStorage deleteCookiesForURL:[userDefaults VBXURLForKey:VBXUserDefaultsBaseURL]];
    }
    
    // Clear any stored prefs
    for (NSString *key in [[userDefaults dictionaryRepresentation] allKeys]) {
        [userDefaults removeObjectForKey:key];
    }
    [userDefaults synchronize];
}