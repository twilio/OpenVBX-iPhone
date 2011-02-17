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
#import "VBXViewController.h"

@class VBXObjectBuilder;
@protocol VBXSecurityAlertControllerDelegate;

@interface VBXSecurityAlertController : VBXViewController {
    VBXObjectBuilder *_builder;

    id<VBXSecurityAlertControllerDelegate> _delegate;
    NSInteger _tag;

    NSString *_headingText;
    NSString *_descriptionText;
    
    NSDictionary *_userInfo;
}

@property (nonatomic, retain) VBXObjectBuilder *builder;
@property (nonatomic, assign) id<VBXSecurityAlertControllerDelegate> delegate;
@property (nonatomic, assign) NSInteger tag;

@property (nonatomic, retain) NSString *headingText;
@property (nonatomic, retain) NSString *descriptionText;
@property (nonatomic, retain) NSDictionary *userInfo;

@end

@protocol VBXSecurityAlertControllerDelegate <NSObject>
- (void)securityAlertDidAccept:(VBXSecurityAlertController *)securityAlert;
- (void)securityAlertDidReject:(VBXSecurityAlertController *)securityAlert;
@end
