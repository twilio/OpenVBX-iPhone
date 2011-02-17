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

typedef enum {
	MAJOR_EQUAL        = 1,
	MAJOR_GREATER      = 1 << 1,
	MAJOR_LESSER       = 1 << 2,
	
	MINOR_EQUAL        = 1 << 3,
	MINOR_GREATER      = 1 << 4,
	MINOR_LESSER       = 1 << 5,
	
	PATCHLEVEL_EQUAL   = 1 << 6,
	PATCHLEVEL_GREATER = 1 << 7,
	PATCHLEVEL_LESSER  = 1 << 8
} VBXVersionComparison;

@interface VBXVersion : NSObject {

	int _major;
	int _minor;
	int _patchlevel;

}

@property (nonatomic) int major;
@property (nonatomic) int minor;
@property (nonatomic) int patchlevel;

+ (VBXVersion *)fromString:(NSString *)versionString;
- (VBXVersionComparison)compareVersion:(NSString *)comparedVersionString;

@end