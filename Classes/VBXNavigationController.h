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

@class VBXObjectBuilder;
@class VBXDialerController;
@class VBXSendTextController;

@interface VBXNavigationController : UINavigationController {
    VBXObjectBuilder *_builder;
    
    BOOL _dialerIsShown;
    BOOL _sendTextIsShown;
    
    VBXDialerController *_dialerController;
    VBXSendTextController *_sendTextController;
}

@property (nonatomic, retain) VBXObjectBuilder *builder;

@property (nonatomic, readonly) BOOL dialerIsShown;
@property (nonatomic, readonly) BOOL sendTextIsShown;
@property (nonatomic, readonly) VBXDialerController *dialerController;
@property (nonatomic, readonly) VBXSendTextController *sendTextController;

- (void)showDialOrTextActionSheet;

- (void)showDialer;
- (void)showSendText;
- (void)showDialerWithState:(NSDictionary *)state animated:(BOOL)animated;
- (void)showSendTextWithState:(NSDictionary *)state animated:(BOOL)animated;

- (NSDictionary *)saveState;
- (void)restoreState:(NSDictionary *)state;

@end
