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

#import "VBXVersion.h"


@implementation VBXVersion

@synthesize patchlevel = _patchlevel;
@synthesize major = _major;
@synthesize minor = _minor;

- (VBXVersion *)initWith:(int) major minor:(int) minor patchlevel:(int) patchlevel {
    if (self = [super init]) {
		self.major = major;
		self.minor = minor;
		self.patchlevel = patchlevel;
	}
	
	return self;
}

+ (VBXVersion *)fromString:(NSString *)versionString {
	const char *vstr, *vend;
	int i = 0, versions[3] = {0, 0, 0};
	
	if(![versionString length]) {
		[NSException raise:NSGenericException format:@"Expected versionString more than zero characters long ???"];
	}
	
	vstr = [versionString cStringUsingEncoding:NSASCIIStringEncoding];
	
	/* strtol converts up until the first non-numeric character, which is pointed to by vend.
	   we use this to walk along the version string. */

	do {
		versions[i++] = strtol(vstr, &vend, 10);
		
		if( !*vend )
			break;
		
		vstr = vend + 1;
	} while( i < (sizeof(versions) / sizeof(int)) );
	
	if( !i )
		[NSException raise:NSGenericException format:@"No numeric values in versionString"];

	return [[VBXVersion alloc] initWith:versions[0] minor:versions[1] patchlevel:versions[2]];
}

- (VBXVersionComparison)compareVersion:(NSString *)comparedVersionString {
	VBXVersion *compareTo = [[VBXVersion fromString:comparedVersionString] autorelease];
	VBXVersionComparison ret = 0;
	int comparison;
	
#define COMPARE(prop, uprop)\
	if( (comparison = (self.prop - compareTo.prop)) ) {\
		if( comparison > 0 )\
			ret |= uprop##_GREATER;\
		else\
			ret |= uprop##_LESSER;\
	} else\
		ret |= uprop##_EQUAL;
	
	COMPARE(major, MAJOR);
	COMPARE(minor, MINOR);
	COMPARE(patchlevel, PATCHLEVEL);

#undef COMPARE
	
	return ret;
}


@end