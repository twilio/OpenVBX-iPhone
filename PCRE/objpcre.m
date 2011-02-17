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

#import <Foundation/Foundation.h>
#import "objpcre.h"

@implementation ObjPCRE

const int MAX_VECTOR_SIZE = 99;

- (id)init
{
	self = [super init];
	
	[self initializeWithVectorSize:MAX_VECTOR_SIZE];
	
	return self;
}

- (id)initWithVectorSize:(int)maxVectorSize
{
	self = [super init];
	
	// overwrite the default value
	[self initializeWithVectorSize:maxVectorSize];
	
	return self;
}

- (id)initWithPattern:(NSString *)pattern
		   andOptions:(int)opts
{
	self = [super init];
	
	[self initializeWithVectorSize:MAX_VECTOR_SIZE];
		
	// compile the regex for the client
	[self compileWithPattern:pattern
				  andOptions:opts];
	
	return self;
}

- (id)initWithPattern:(NSString *)pattern
{
	self = [super init];
	
	[self initializeWithVectorSize:MAX_VECTOR_SIZE];
	
	// compile the regex for the client
	[self compileWithPattern:pattern
				  andOptions:0];
	
	return self;
}

+ (id)regexWithPattern:(NSString *)pattern
{
	return [[[ObjPCRE alloc] initWithPattern:pattern] autorelease];
}

- (void)dealloc
{
	if ( mRegex )
		pcre_free(mRegex);
	
	mRegex = (pcre*)NULL;
	
	free(mVector);
	
	[super dealloc];
}

- (void)initializeWithVectorSize:(int)maxVectorSize
{
	mRegex = (pcre*)NULL;
	mLastError = (char*)NULL;
	mLastErrorOffset = -1;
	mMaxVectorSize = maxVectorSize;
	
	// calculate vector info
	int nVectorSize = mMaxVectorSize; // vector will hold mMaxVectoSize matches (start and end index)
	mVectorCount = (1 + nVectorSize) * 3; // should always be a multiple of 3
	mVector = (int*) malloc(mVectorCount * sizeof(int));
}

- (void)reinitialize
{
	if ( [self isValid] )
	{
		// cleanup pcre object
		pcre_free(mRegex);
		mRegex = (pcre*)NULL;
		
		if ( mLastError )
		{
			free((char*)mLastError);
			mLastError = (char*)NULL;
		} // end IF
		
		mLastErrorOffset = -1;
		mMatchCount = 0;
	} // end 
}

- (BOOL)compileWithPattern:(NSString *)regexPattern
				andOptions:(int)options
{
	// re-init this object
	[self reinitialize];
	
	// convert the wxString to a PCRE safe std::string object
	const char* pattern = (char*)NULL;
	const char* error = (char*)NULL;
	
	// convert the NSString to a cstring
	pattern = [regexPattern UTF8String];
	
	// store the options
	mCompileOptions = options;
	
	// perform the pcre regex pattern compilation
	mRegex = pcre_compile(pattern, 
						  PCRE_UTF8|options,
						  &error, &mLastErrorOffset,
						  NULL);

	// store the error
	mLastError = error;

	// check the regex object (if false then check mLastError)
	BOOL isValid = [self isValid];
	
	// if not valid then reset respective vars
	if ( !isValid )
	{
		mMatchCount = 0;
	} // end IF
	
	return isValid;
}

- (int)matchStart:(int)match
{
	return mVector[match*2];
}

- (int)matchStart
{
	return mVector[0];
}

- (int)matchEnd:(int)match
{
	return mVector[match*2+1];
}

- (int)matchEnd
{
	return mVector[1];
}

- (int)matchLength:(int)match
{
	return mVector[match*2+1] - mVector[match*2];
}

- (int)matchLength
{
	return mVector[1] - mVector[0];
}

- (BOOL)regexMatches:(NSString *)text 
			 options:(int)options
		 startOffset:(int)startOffset
			   error:(void *)err
{	
	if ( ![self isValid] )
		return NO;
	
	// store the options
	mExecOptions = options;
	
	/*
	- implement later	
	// returned value may be used to speed up match
	pcre_extra *regexExtra = pcre_study(mRegex, 
	options, // options
	&error);
	*/
	
	/*
	// get full info
	int pcre_fullinfo(const pcre *code, const pcre_extra *extra,
	int what, void *where);
	int rc;
	size_t len;
	rc = pcre_fullinfo(mRegex, regexExtra, PCRE_INFO_CAPTURECOUNT, &len);
	
	*/
	
	// convert the NSString to a const char* (for use with PCRE)
	const char* subject = (char*)NULL;
	
	// convert the string
	subject = [text UTF8String];
	
	/*
	int pcre_exec(const pcre *code, const pcre_extra *extra,
	const char *subject, int length, int startoffset,
	int options, int *ovector, int ovecsize);
	*/
	// execute the pattern matching mechanism (obtain match vector, etc)
	mMatchCount = pcre_exec(
	mRegex,             /* result of pcre_compile() */
	0,           /* we didn't study the pattern */
	subject,  /* the subject string */
	[text length],             /* the length of the subject string */
	startOffset,              /* start at offset ? in the subject */
	options,              /* options */
	mVector,        /* vector of integers for substring information */
	mVectorCount);            /* number of elements (NOT size in bytes) */
	
	return (mVector[1] > 0);
}

- (BOOL)regexMatches:(NSString *)text
			 options:(int)opt
		 startOffset:(int)start
{
	return [self regexMatches:text
					  options:opt
				  startOffset:start
						error:NULL];
}

- (BOOL)isValid
{
	return (mRegex != NULL);
}

- (BOOL)matches:(NSString *)text
		options:(int)opts
{
	return [self regexMatches:text
					  options:opts
				  startOffset:0
						error:NULL];
}

- (BOOL)matches:(NSString *)text
{
	return [self matches:text
				 options:0];
}

- (BOOL)match:(int *)start
	   length:(int *)len
 atMatchIndex:(int)match
{
	if ( ![self isValid] )
		return NO;
	
	// store the length for later use
	int l = [self matchLength:match];
	
	// pass the values to ptrs
	*start = [self matchStart:match];
	*len = l;
	
	// if the length is useful, match is valid
	return (l >= 1);
}

- (BOOL)match:(int *)start
	   length:(int *)len
{
	return [self match:start
				length:len
		  atMatchIndex:0];
}


- (NSString *)match:(NSString *)text
	   atMatchIndex:(int)match
{	
	if ( ![self isValid] )
		return @"";
	
	// cast for safety
	int m = match;
	
	/* alternative method
	// get the matched string
	int pcre_get_substring(const char *subject, int *ovector,
	int stringcount, int stringnumber,
	const char **stringptr);
	// returns the length of the string (or the error code if return negative int)
	*/
	
	// get the NSString value of the match
	return [text substringWithRange:NSMakeRange([self matchStart:m], [self matchLength:m])];
}

- (NSString *)match:(NSString *)text
{
	return [self match:text
		  atMatchIndex:0];
}

- (int)matchCount
{
	if ( ![self isValid] )
		return 0;
	
	/* - if the match count is less than 0
	* then it contains the error code, but to the
	* client of this function its a zero match count
	*/
	if ( mMatchCount < 0 )
		return 0;
	
	return mMatchCount;
}

- (int)replace:(NSString **)subjectString
   replacement:(NSString *)replacement
maxReplacements:(int)max
{
	/* replace logic steps
	 * - first: get all the backreferences (their start/end index and the NSString value)
	 * - second: inject them in the correct pos of the replacement NSString
	 * - final: perform the replacements on all the matches in text (do not replace more than max)
	 */
	
	// check validaty of the regex
	if ( ![self isValid] )
		return 0;
	
	// assign the subject string to the worker mutable string
	NSMutableString *text = [NSMutableString stringWithCapacity: [*subjectString length]];
	[text setString:*subjectString];
	
	// store the current class values
	int prevMatchCount = mMatchCount;
	int *prevVector = mVector;	
	
	int startIndex = 0; // what match to begin with
	int nOffset = startIndex;
	int nMatch = 0;
	int nCount = 0; // stores num of iterations/replacements
	
	/*
	 * - only match \xx if it is not escaped
	 * - (?<!\\\\)(\\\\)([0-9]+) - will not capture the non-escape char 
	 * - ([^\\\\]|^)(\\\\)([0-9]+) - will capture the non-escaping char
	 * - also it seems that you have to escape the escape char for C++ (compiler) and for PCRE (ex: \\\\ = \\ [pcre escape])
	 */
	ObjPCRE *refRegex = [[ObjPCRE alloc] initWithPattern:@"([^\\\\]|^)(\\\\)(\\d+)"];
		
	// do we process back references \xx (are there any backrefs in the replacement string)
	BOOL obtainRefs = [refRegex matches:replacement];
	NSMutableArray *intArr = (NSMutableArray*)NULL;
	
	if ( obtainRefs )
	{ // start backref grab SCOPE
		
		intArr = [NSMutableArray arrayWithCapacity:2];
		int nOffset = 0;
		
		// get all the values of the backrefs
		while ( [refRegex regexMatches:replacement
							   options:0
						   startOffset:nOffset
								 error:NULL])
		{
			// get the int value (of the back ref)			
			[intArr addObject: [refRegex match:replacement 
								  atMatchIndex:3]];
			
			// move the marker forward
			nOffset = [refRegex matchEnd];
			
			if ( nOffset == 0 )
				break;
		} // end WHILE
	} // end IF
	
	// iterate through all the possible matches (or till max)
	while ( [self regexMatches:text
					   options:mExecOptions
				   startOffset:nOffset
						 error:NULL] )
	{				
		// get the match info
		int start = [self matchStart:nMatch];
		int len = [self matchLength:nMatch];

		if ( obtainRefs )
		{			
			int limit = [intArr count];
			int i = 0;
			// iterate through all the backrefs
			for ( ; i < limit ; ++i )
			{
				/*
				* - rerun the match using the actual matched string
				* - this ensures that the replace will have
				* the correct text pos even after the first replace
				* - it is faster to convert a string to a number that it is
				* to convert a number to a string (using wxString::Format)
				*/
				[self regexMatches:text
						   options:mExecOptions
					   startOffset:nOffset
							 error:NULL];
								
				// convert the string to a long
				int matchIdx = 0;
				NSString *backRef = [intArr objectAtIndex:i];
				matchIdx = [backRef intValue];
				
				// get the match info
				int s = [self matchStart:matchIdx];
				int l = [self matchLength:matchIdx];
				
				// get the backref string value
				NSString *value = [text substringWithRange:NSMakeRange(s, l)];
				
				// setup the replacement text vars
				NSMutableString *replacementText = [NSMutableString stringWithCapacity: [replacement length]];
				[replacementText setString:replacement];
				backRef = [NSString stringWithFormat:@"\\%@", backRef];
				
				/*
				* - replace the backref in 'replacement' with
				* the value acquired from the actual backref
				*/
				[replacementText replaceOccurrencesOfString:backRef
												 withString:value
													options:NSLiteralSearch
													  range:NSMakeRange(0, [replacementText length])];
								
				// replace the string in the current pos with the actual backref value
				[text replaceCharactersInRange:NSMakeRange(start, len)
									withString:replacementText];
			} // end FOR
		} // end IF (obtainRefs)
		
		if ( !obtainRefs )
		{
			// replace the matched string the current match
			[text replaceCharactersInRange:NSMakeRange(start, len)
								withString:replacement];
		} // end IF
		
		// set next mark past this match
		nOffset = start + len;		
		
		// increment the replacement count
		++nCount;
		
		// if max not set then keep going
		if ( max != 0 )
		{
			// if we have reached the max
			if ( max == nCount )
				break;
		} // end IF
	} // end WHILE
	
	// free mem
	if ( refRegex )
		[refRegex release];
	
	// restore to class vars
	mVector = prevVector;
	mMatchCount = prevMatchCount;
	
	// assign the newly created NSString
	*subjectString = [NSString stringWithString:text];
	
	return nCount;
}

- (int)replaceFirst:(NSString **)text
		replacement:(const NSString *)replace
{
	return [self replace:text
			 replacement:replace
		 maxReplacements:1];
}

- (int)replaceAll:(NSString **)text
	  replacement:(NSString *)replace
{
	return [self replace:text
			 replacement:replace
		 maxReplacements:0];
}

- (NSString *)lastError
{
	if ( mLastError )
		return [NSString stringWithCString:mLastError
								  encoding:NSUTF8StringEncoding];
	else
		return @"";
}

- (int)lastErrorOffset
{
	return mLastErrorOffset;
}	

+ (NSString *)escapedPattern:(NSString *)pattern
{
	int len = [pattern length];
	NSMutableString *escaped = [NSMutableString stringWithCapacity:len];

	int i = 0;
	for( ; i < len ; ++i )
	{
		char c = [pattern characterAtIndex:i];
		
		if( c=='^' || c=='.' || c=='[' || c=='$' || c=='(' || c==')'
		|| c=='|' || c=='*' || c=='+' || c=='?' || c=='{' || c=='\\' ) 
		{
			[escaped appendFormat:@"\\%C", c];
		}
		else
		{
			[escaped appendFormat:@"%C", c];
		}
	} // end FOR
	
	return (NSString*)escaped;
}	
@end