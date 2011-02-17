///////////////////////////////////////////////////////////////////////////////
// ObjPCRE - Regular expression matching (using the PERL Compatible Regular Expression Library)
// Copyright (C) 2007  Christopher Bess (C. Bess Creation)
// <cbess@quantumquinn.com>
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.
//
//		Regular expression support is provided by the PCRE library package,
//   which is open source software, written by Philip Hazel, and copyright
//			 by the University of Cambridge, England. 
//		(PCRE available at ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/)
///////////////////////////////////////////////////////////////////////////////
/* v. 0.3.5 */

// typedef real_pcre pcre
#import "pcre.h"

enum
{
	// hard coded into match logic
	quUTF8 = PCRE_UTF8, // match time only
	
    // ignore case in match
	quICASE = PCRE_CASELESS, // compile time only
	
    // if not set, treat '\n' as an ordinary character
	quNEWLINE = PCRE_MULTILINE, // compile time only
	
    // '^' doesn't match at the start of line
	quNOTBOL = PCRE_NOTBOL, // match time only
	
    // '$' doesn't match at the end of line
	quNOTEOL = PCRE_NOTEOL // match time only
};

@interface ObjPCRE : NSObject
{
	@private
	pcre * mRegex; // current pcre object
	const char * mLastError; // description of the last error
	int mLastErrorOffset; // last error offset
	int mMaxVectorSize; // match capacity size of vector
	int * mVector; // holds vector array of matches
	int mVectorCount; // passed to pcre_exec (used to create mVector) 
	int mExecOptions; // the pcre_exec options
	int mCompileOptions; // the pcre_compile options
	
	/**
	 * - the return value from the pcre_exec call via matches:
	 * - the number of matches obtained by pcre_exec
	 */
	int mMatchCount;
}

	/**
	 * @summary: Creates an instance using default behavior.
	 */
	- (id)init;

	/**
	 * @summary: Creates an instance with a default behavior and the specified vector size. 
	 * @note: The default vector holds MAX_VECTOR_SIZE (9999 matches)
	 */
	- (id)initWithVectorSize:(int)maxVectorSize;

	/**
	 * @summary: Creates an instance and compiles the specified pattern with the given options.
	 * - arg1: the regular expression pattern to compile
	 * - arg2: the options to pass to pcre_compile
	 * @note: Calls compile:, use isValid: or lastError: to determine if the
	 * pattern was successfully compiled.
	 */
	- (id)initWithPattern:(NSString *)pattern andOptions:(int)opts;
	- (id)initWithPattern:(NSString *)pattern; // andOptions:0;

	/**
	 * @summary: Creates an autorelease instance and compiles the specified pattern.
	 * - arg1: the regular expression pattern to compile
	 * @note: Calls compile:, use isValid: or lastError: to determine if the
	 * pattern was successfully compiled. 
	 * @returns: An autorelease object instance.
	 */
	+ (id)regexWithPattern:(NSString *)pattern;

	/**
	 * @summary: deallocates allocated memory
	 */
	- (void)dealloc;

	/**
	 * @summary: Compiles the regex pattern for use with the pcre_exec function.
	 * - arg1: the regular expression pattern
	 * - arg2: any compile options to pass to pcre_compile
	 * @returns: True if the regular expression pattern compiled without error.
	 */
	- (BOOL)compileWithPattern:(NSString *)pattern andOptions:(int)opts;

	/**
	 * @returns: the description of the last error encountered.
	 */
	- (NSString *)lastError;

	/**
	 * @returns: the offset (string position) of the last error encountered.
	 */
	- (int)lastErrorOffset;

	/**
	 * @summary: Gets the matches starting position in the subject string.
	 * - arg1: the subexpression (0 = the entire match)
	 */
	- (int)matchStart:(int)match;
	- (int)matchStart; // :0;

	/**
	 * @summary:Gets the matches ending position in the subject string.
	 * - arg1: the subexpression (0 = the entire match)
	 * @returns: the end offset position of the match
	 */
	- (int)matchEnd:(int)match;
	- (int)matchEnd; // :0;

	/**
	 * @summary:Gets the matches length
	 * - arg1: the subexpression (0 = the entire match)
	 * @returns: the length of the match
	 */
	- (int)matchLength:(int)match;
	- (int)matchLength; // :0;

	/**
	 * - this function is used to exec the regex
	 * - arg 1: the text to search through
	 * - arg 2: any options you wish to pass to pcre_exec
	 * - arg 3: the offset pcre_exec is going to start from (pattern matching start index in arg1)
	 * - arg 4: not used yet, it will be used to store the error generated by pcre_study 
	 * @returns: True if the regex pattern found a match
	 */
	- (BOOL)regexMatches:(NSString *)text options:(int)opts startOffset:(int)start error:(void*)err;
	- (BOOL)regexMatches:(NSString *)text options:(int)opts startOffset:(int)start; // error:NULL;

	/**
	 * @summary: Returns true if the regular expression compiled successfully.
	 */
	- (BOOL)isValid;

	/**
	 * @summary: Attempts to match the subject string
	 * - arg1: the subject string
	 * - arg2: any match options you want to pass to pcre_exec (0 = default options)
	 * @returns: True if the regular expression matched the subject string
	 * @note: Only works AFTER a successful call to compile:
	 */
	- (BOOL)matches:(NSString *)text options:(int)opts;
	- (BOOL)matches:(NSString *)text; // options:0;

	/**
	 * @summary: Gets the start and length of the match.
	 * - arg1: pointer to start position of the match
	 * - arg2: pointer to length of the match
	 * @returns: True if the match was successful
	 * @note: Only works AFTER a successful call to compile:
	 */
	- (BOOL)match:(int *)start length:(int *)len atMatchIndex:(int)idx;
	- (BOOL)match:(int *)start length:(int *)len; // atMatchIndex:0;

	/**
	 * @summary: Gets the matched string.
	 * - arg1: the subject string
	 * - arg2: the subexpression (0 = the entire match)
	 * @return: a NSString instance of the matched pattern
	 */
	- (NSString *)match:(NSString *)text atMatchIndex:(int)idx;
	- (NSString *)match:(NSString *)text; // atMatchIndex:0;

	/**
	 * @summary: Gets the number of subexpression in the pattern
	 * @returns: the number of subexpressions
	 */
	- (int)matchCount;

	/**
	 * @summary: Replaces the occurences of the regular expression match, not to exceed
	 * the maxReplacement value.
	 * - arg1: the text to alter (subject string)
	 * - arg2: the replacement text (backreferences are not supported, yet)
	 * - arg3: the replacement limit (0 causes all occurences to be replaced)
	 * @returns: the number of replacements performed
	 */
	- (int)replace:(NSString **)text replacement:(const NSString *)replace maxReplacements:(int)maxReplace;

	/**
	 * @summary: Replaces the first occurence of the regular expression match
	 * - arg1: the text to alter (subject string)
	 * - arg2: the replacement text (backreferences are not supported, yet)
	 * @returns: the number of replacements performed
	 */
	- (int)replaceFirst:(NSString **)text replacement:(const NSString *)replace;

	/**
	 * @summary: Replaces all occurences of the regular expression match
	 * - arg1: the text to alter (subject string)
	 * - arg2: the replacement text (backreferences are not supported, yet)
	 * @returns: the number of replacements performed
	 */
	- (int)replaceAll:(NSString **)subjectString replacement:(NSString *)replace;
		
	/**
	 * Common initialize functions
	 */
	- (void)initializeWithVectorSize:(int)maxVectorSize;
	- (void)reinitialize;

	/**
	 * Common utility functions
	 */
	+ (NSString *)escapedPattern:(NSString *)pattern;
@end