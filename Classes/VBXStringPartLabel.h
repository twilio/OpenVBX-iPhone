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

#import <UIKit/UIKit.h>

@interface VBXStringPart : NSObject {
    NSString *_text;
    UIFont *_font;
}

@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) UIFont *font;

+ (VBXStringPart *)partWithText:(NSString *)text font:(UIFont *)font;

@end

@interface VBXStringPartLabel : UIView {
    UIColor *_textColor;
    CGSize _shadowOffset;
    UIColor *_shadowColor;
    NSArray *_parts;
    UITextAlignment _textAlignment;    
}

@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, assign) CGSize shadowOffset;
@property (nonatomic, retain) UIColor *shadowColor;
@property (nonatomic, retain) NSArray *parts;
@property (nonatomic, assign) UITextAlignment textAlignment;

@end
