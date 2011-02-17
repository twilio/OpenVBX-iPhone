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

#import "VBXLicenseController.h"
#import "NSExtensions.h"
#import "VBXGlobal.h"

@implementation VBXLicenseController

@synthesize summary = _summary;
@synthesize webView = _webView;

- (id)init {
	self.navigationItem.title = LocalizedString(@"License Information", @"License Information: title");
    if (self = [super init]) {
		NSString *path =[[NSBundle mainBundle] pathForResource:@"license" ofType:@"html"];
		self.summary = [[NSString alloc] initWithContentsOfFile:path
													   encoding:NSUTF8StringEncoding 
														  error:[NSError twilioErrorWithCode:VBXErrorLoadingFile underlyingError:NSErrorFailingURLStringKey]];
		
		
        //[[VBXConfiguration sharedConfiguration] addConfigObserver:self];
        //[self applyConfig];
		
	}
	
    return self;
}

- (void)loadView {
    [super loadView];
	
	_webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, 120)];
	[_webView loadHTMLString:self.summary baseURL:[NSURL URLWithString:@"http://openvbx.org/"]];
	
	//[self.view addSubview:_textView];
	self.view = _webView;
	
    [self applyConfig];
}


- (void)dealloc {
    [[VBXConfiguration sharedConfiguration] removeConfigObserver:self];
    self.summary = nil;
    [super dealloc];
}

@end
