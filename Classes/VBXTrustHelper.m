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

#import "VBXTrustHelper.h"
#import "VBXUserDefaultsKeys.h"

@implementation VBXTrustHelper

+ (PostSetupTrustAction)actionForPostSetupCertificateIssueWithOSStatus:(OSStatus)osStatus 
                                                    secTrustResultType:(SecTrustResultType)secTrustResultType
                                                              certData:(NSData *)certData
                                          requireTrustedCertForThisURL:(BOOL)requireTrustedCertForThisURL
                                            lastAcceptedCertWasTrusted:(BOOL)lastAcceptedCertWasTrusted
                                                  lastAcceptedCertData:(NSData *)lastAcceptedCertData
{
    if (osStatus == noErr) {
        switch (secTrustResultType) {
            case kSecTrustResultUnspecified:                        
                // The certificate is OK and trusted and we can move along.
                return PostSetupTrustActionAllow;
                
            case kSecTrustResultProceed:
                // Proceed would normally mean that the user had chosen to "Always Trust" an otherwise
                // invalid cert.  I believe this a result code we'll never see on iPhone.  We can only
                // choose to trust things once per app session, and as soon as the app restarts, we'll
                // get prompted again.
            case kSecTrustResultConfirm:
            case kSecTrustResultRecoverableTrustFailure:
                // The current certificate is untrusted.
                if (requireTrustedCertForThisURL && lastAcceptedCertWasTrusted) {
                    return PostSetupTrustActionDenyWithSecureModeAlert;
                } else if (!requireTrustedCertForThisURL && lastAcceptedCertWasTrusted) {
                    return PostSetupTrustActionPromptWithCertificateIsNowUntrustedAlert;
                } else if (!requireTrustedCertForThisURL && !lastAcceptedCertWasTrusted) {
                    // So, our last accepted cert was untrusted and our current certificate is
                    // untrusted.  If it's the same certificate, then we want to just accept it
                    // again and move on.  If it's a different certificate, we want to let the
                    // know.
                    
                    if ([certData isEqualToData:lastAcceptedCertData]) {
                        return PostSetupTrustActionAllow;
                    } else {
                        return PostSetupTrustActionPromptWithUntrustedCertificateHasChangedAlert;
                    }
                    
                } else {
                    // This case shouldn't happen.  If the last known cert was trusted, then
                    // we shouldn't be in secure mode.
                }
            case kSecTrustResultInvalid:
            case kSecTrustResultDeny:
            case kSecTrustResultFatalTrustFailure:
            case kSecTrustResultOtherError:
                // fall through and return a generic erro
                
            default:
                break;
        }
    }
    
    return PostSetupTrustActionDenyWithGenericError;    
}

+ (SetupTrustAction)actionForSetupTrustIssueWithOSStatus:(OSStatus)osStatus 
                                      secTrustResultType:(SecTrustResultType)secTrustResultType
                            requireTrustedCertForThisURL:(BOOL)requireTrustedCertForThisURL
{
    if (osStatus == noErr) {
        switch (secTrustResultType) {
            case kSecTrustResultUnspecified:                        
                // The certificate is OK and trusted and we can move along.
                return SetupTrustActionAllow;
                
            case kSecTrustResultProceed:
                // Proceed would normally mean that the user had chosen to "Always Trust" an otherwise
                // invalid cert.  I believe this a result code we'll never see on iPhone.  We can only
                // choose to trust things once per app session, and as soon as the app restarts, we'll
                // get prompted again.
            case kSecTrustResultConfirm:
            case kSecTrustResultRecoverableTrustFailure:
                // The current certificate is untrusted.
                if (requireTrustedCertForThisURL) {
                    return SetupTrustActionDenyWithTrustedCertRequiredAlert;
                } else {
                    return SetupTrustActionPromptWithUntrustedCertAlert;
                }

            case kSecTrustResultDeny:
                // Deny would normally mean that a user had been prompted with some certificate panel
                // and chosen to always deny.  I believe this a result code we'll never see on iPhone,
                // as there is no system-provided trust panel.
            case kSecTrustResultInvalid:
            case kSecTrustResultFatalTrustFailure:
            case kSecTrustResultOtherError:
                // fall through and return a generic error

            default:
                break;                
        }
    }
    
    return SetupTrustActionDenyWithGenericError;
}

+ (BOOL)serverURLRequiresTrustedCertificate:(NSString *)serverURL {
    NSArray *secureURLs = [[NSUserDefaults standardUserDefaults] objectForKey:VBXUserDefaultsSecureURLs];
    
    if (secureURLs != nil && [secureURLs containsObject:serverURL]) {
        return YES;
    } else {
        return NO;
    }
}

+ (NSData *)dataForFirstCertificate:(SecTrustRef)serverTrust {
    SecTrustResultType type = 0;    
    OSStatus status = SecTrustEvaluate(serverTrust, &type);

    NSData *data = nil;
    
    if (status == noErr) {
        int count = SecTrustGetCertificateCount(serverTrust);

        NSLog(@"Number of certificates: %d", count);
        for (int i = 0; i < count; i++) {
            SecCertificateRef cert = SecTrustGetCertificateAtIndex(serverTrust, i);
            CFStringRef certSummary = SecCertificateCopySubjectSummary(cert);
            NSLog(@"[%d] Certificate Summary: %@", i, certSummary);
            CFRelease(certSummary);
        }

        if (count >= 1) {
            SecCertificateRef cert = SecTrustGetCertificateAtIndex(serverTrust, 0);
            data = (NSData *)SecCertificateCopyData(cert);
        }
    }
    
    return [data autorelease];
}

+ (void)acceptCertificateAndRecordCertificateInfoWithChallenge:(NSURLAuthenticationChallenge *)challenge serverTrust:(SecTrustRef)serverTrust {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    SecTrustResultType type = 0;    
    OSStatus status = SecTrustEvaluate(serverTrust, &type);

    NSData *certificateData = nil;
    BOOL certificateIsTrusted = NO;
    
    if (status == noErr) {
        if (kSecTrustResultUnspecified == type) {
            certificateData = nil;
            certificateIsTrusted = YES;
        } else {
            certificateData = [[self dataForFirstCertificate:serverTrust] retain];
            certificateIsTrusted = NO;
        }
    }
    
    [defaults setBool:certificateIsTrusted forKey:VBXUserDefaultsLastAcceptedCertificateWasTrusted];
    [defaults setObject:certificateData forKey:VBXUserDefaultsLastAcceptedCertificateData];    
    
    [[challenge sender] useCredential:[NSURLCredential credentialForTrust:serverTrust] forAuthenticationChallenge:challenge];

    if (certificateData) {
        [certificateData release];
    }
}

@end


