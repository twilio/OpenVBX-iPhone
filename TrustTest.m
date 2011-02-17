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

#import <SenTestingKit/SenTestingKit.h>
#import <UIKit/UIKit.h>
#import "VBXTrustHelper.h"

@interface TrustTest : SenTestCase {
}

@end

@implementation TrustTest

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

//
// Cases:
//
// 1) Cert was OK and trusted during the initial setup, the server is in secure mode,
// and now the certificate is untrusted.  Expectation:  Go to lock-down mode.  Show alert
// stating what happened, and don't let the user do anything else but quit.
//

- (void)testCaseOne {
    PostSetupTrustAction actual;
    PostSetupTrustAction expected = PostSetupTrustActionDenyWithSecureModeAlert;
    
    actual = [VBXTrustHelper actionForPostSetupCertificateIssueWithOSStatus:noErr 
                                                         secTrustResultType:kSecTrustResultRecoverableTrustFailure 
                                                                certData:[@"" dataUsingEncoding:NSUTF8StringEncoding]
                                                      requireTrustedCertForThisURL:YES 
                                                    lastAcceptedCertWasTrusted:YES
                                                    lastAcceptedCertData:[@"" dataUsingEncoding:NSUTF8StringEncoding]];
    STAssertEquals(expected, actual, nil);

    actual = [VBXTrustHelper actionForPostSetupCertificateIssueWithOSStatus:noErr 
                                                      secTrustResultType:kSecTrustResultConfirm 
                                                                certData:[@"" dataUsingEncoding:NSUTF8StringEncoding]
                                            requireTrustedCertForThisURL:YES 
                                              lastAcceptedCertWasTrusted:YES
                                                    lastAcceptedCertData:[@"" dataUsingEncoding:NSUTF8StringEncoding]];
    STAssertEquals(expected, actual, nil);
}

// 2) Cert was OK and trusted during the initial setup, the server is NOT in secure mode,
// and now the certificate is untrusted.  Expectation: Show alert stating that the server
// is now using an insecure certificate, and that the server might be compromised.

- (void)testCaseTwo {
    PostSetupTrustAction actual;
    PostSetupTrustAction expected = PostSetupTrustActionPromptWithCertificateIsNowUntrustedAlert;
    
    actual = [VBXTrustHelper actionForPostSetupCertificateIssueWithOSStatus:noErr 
                                                         secTrustResultType:kSecTrustResultRecoverableTrustFailure 
                                                                certData:[@"" dataUsingEncoding:NSUTF8StringEncoding]
                                                      requireTrustedCertForThisURL:NO 
                                                    lastAcceptedCertWasTrusted:YES
              lastAcceptedCertData:[@"" dataUsingEncoding:NSUTF8StringEncoding]];
    STAssertEquals(expected, actual, nil);
    
    actual = [VBXTrustHelper actionForPostSetupCertificateIssueWithOSStatus:noErr 
                                                         secTrustResultType:kSecTrustResultConfirm 
                                                                certData:[@"" dataUsingEncoding:NSUTF8StringEncoding]
                                                      requireTrustedCertForThisURL:NO 
                                                    lastAcceptedCertWasTrusted:YES
              lastAcceptedCertData:[@"" dataUsingEncoding:NSUTF8StringEncoding]];
    STAssertEquals(expected, actual, nil);
}

// 3) Cert was OK but untrusted during the initial setup, and now the certificate has changed
// from the original untrusted certificate to another.  Expectation: Show alert stating that
// the certificate has changed from one to another, and that the server might be compromised.

- (void)testCaseThree {
    PostSetupTrustAction actual;
    PostSetupTrustAction expected = PostSetupTrustActionPromptWithUntrustedCertificateHasChangedAlert;
    
    actual = [VBXTrustHelper actionForPostSetupCertificateIssueWithOSStatus:noErr 
                                                      secTrustResultType:kSecTrustResultRecoverableTrustFailure
                                                                certData:[@"original" dataUsingEncoding:NSUTF8StringEncoding]
                                            requireTrustedCertForThisURL:NO 
                                              lastAcceptedCertWasTrusted:NO
                                                    lastAcceptedCertData:[@"new" dataUsingEncoding:NSUTF8StringEncoding]];
    STAssertEquals(expected, actual, nil);
    
    actual = [VBXTrustHelper actionForPostSetupCertificateIssueWithOSStatus:noErr 
                                                      secTrustResultType:kSecTrustResultConfirm 
                                                                certData:[@"original" dataUsingEncoding:NSUTF8StringEncoding]
                                            requireTrustedCertForThisURL:NO 
                                              lastAcceptedCertWasTrusted:NO
                                                    lastAcceptedCertData:[@"new" dataUsingEncoding:NSUTF8StringEncoding]];
    STAssertEquals(expected, actual, nil);    
    
    actual = [VBXTrustHelper actionForPostSetupCertificateIssueWithOSStatus:noErr 
                                                      secTrustResultType:kSecTrustResultProceed 
                                                                certData:[@"original" dataUsingEncoding:NSUTF8StringEncoding]
                                            requireTrustedCertForThisURL:NO 
                                              lastAcceptedCertWasTrusted:NO
                                                    lastAcceptedCertData:[@"new" dataUsingEncoding:NSUTF8StringEncoding]];
    STAssertEquals(expected, actual, nil);    
}

// Our last accepted cert was an untrusted one, our new cert is also untrusted, but
// the data for the certs is identical.  In that case, just accept!

- (void)testResultIsAllowWhenCertificateDataMatches {
    PostSetupTrustAction actual;
    PostSetupTrustAction expected = PostSetupTrustActionAllow;
    
    actual = [VBXTrustHelper actionForPostSetupCertificateIssueWithOSStatus:noErr 
                                                      secTrustResultType:kSecTrustResultRecoverableTrustFailure
                                                                certData:[@"same" dataUsingEncoding:NSUTF8StringEncoding]
                                            requireTrustedCertForThisURL:NO 
                                              lastAcceptedCertWasTrusted:NO
                                                    lastAcceptedCertData:[@"same" dataUsingEncoding:NSUTF8StringEncoding]];
    STAssertEquals(expected, actual, nil);    
}

// 4) Cert was OK but untrusted during the intial setup, and now the certificate has changed
// from an untrusted cert to a trusted cert.  Expectation: The user shouldn't see anything,
// but there is an opportunity for us to switch from unsecure mode to secure mode.

- (void)testCaseFour {
    PostSetupTrustAction actual;
    PostSetupTrustAction expected = PostSetupTrustActionAllow;
    
    actual = [VBXTrustHelper actionForPostSetupCertificateIssueWithOSStatus:noErr 
                                                         secTrustResultType:kSecTrustResultProceed
                                                                certData:[@"" dataUsingEncoding:NSUTF8StringEncoding]
                                                      requireTrustedCertForThisURL:NO 
                                                    lastAcceptedCertWasTrusted:NO
                                                    lastAcceptedCertData:[@"" dataUsingEncoding:NSUTF8StringEncoding]];
    STAssertEquals(expected, actual, nil);
    
    actual = [VBXTrustHelper actionForPostSetupCertificateIssueWithOSStatus:noErr 
                                                         secTrustResultType:kSecTrustResultUnspecified
                                                                certData:[@"" dataUsingEncoding:NSUTF8StringEncoding]
                                                      requireTrustedCertForThisURL:NO 
                                                    lastAcceptedCertWasTrusted:NO
              lastAcceptedCertData:[@"" dataUsingEncoding:NSUTF8StringEncoding]];
    STAssertEquals(expected, actual, nil);        
}

- (void)testOsErrorsReturnGenericFailure {
    PostSetupTrustAction actual;
    PostSetupTrustAction expected = PostSetupTrustActionDenyWithGenericError;
    
    actual = [VBXTrustHelper actionForPostSetupCertificateIssueWithOSStatus:1
                                                         secTrustResultType:kSecTrustResultProceed
                                                                certData:[@"" dataUsingEncoding:NSUTF8StringEncoding]
                                                      requireTrustedCertForThisURL:NO 
                                                    lastAcceptedCertWasTrusted:NO
              lastAcceptedCertData:[@"" dataUsingEncoding:NSUTF8StringEncoding]];
    STAssertEquals(expected, actual, nil);
}

- (void)testRandomCertificateErrorsReturnGenericError {
    PostSetupTrustAction actual;
    PostSetupTrustAction expected = PostSetupTrustActionDenyWithGenericError;

    actual = [VBXTrustHelper actionForPostSetupCertificateIssueWithOSStatus:noErr
                                                         secTrustResultType:kSecTrustResultInvalid
                                                                certData:[@"" dataUsingEncoding:NSUTF8StringEncoding]
                                                      requireTrustedCertForThisURL:NO 
                                                    lastAcceptedCertWasTrusted:YES
                            lastAcceptedCertData:[@"" dataUsingEncoding:NSUTF8StringEncoding]];
    STAssertEquals(expected, actual, nil);

    actual = [VBXTrustHelper actionForPostSetupCertificateIssueWithOSStatus:noErr
                                                         secTrustResultType:kSecTrustResultDeny
                                                                certData:[@"" dataUsingEncoding:NSUTF8StringEncoding]
                                                      requireTrustedCertForThisURL:NO 
                                                    lastAcceptedCertWasTrusted:YES
                            lastAcceptedCertData:[@"" dataUsingEncoding:NSUTF8StringEncoding]];
    STAssertEquals(expected, actual, nil);

    actual = [VBXTrustHelper actionForPostSetupCertificateIssueWithOSStatus:noErr
                                                         secTrustResultType:kSecTrustResultFatalTrustFailure
                                                                certData:[@"" dataUsingEncoding:NSUTF8StringEncoding]
                                                      requireTrustedCertForThisURL:NO 
                                                    lastAcceptedCertWasTrusted:YES
                            lastAcceptedCertData:[@"" dataUsingEncoding:NSUTF8StringEncoding]];
    STAssertEquals(expected, actual, nil);

    actual = [VBXTrustHelper actionForPostSetupCertificateIssueWithOSStatus:noErr
                                                         secTrustResultType:kSecTrustResultOtherError
                                                                certData:[@"" dataUsingEncoding:NSUTF8StringEncoding]
                                                      requireTrustedCertForThisURL:NO 
                                                    lastAcceptedCertWasTrusted:YES
                            lastAcceptedCertData:[@"" dataUsingEncoding:NSUTF8StringEncoding]];
    STAssertEquals(expected, actual, nil);
}

- (void)testRandomCertificateErrorsDuringSetupReturnGenericError {
    SetupTrustAction actual;
    SetupTrustAction expected = SetupTrustActionDenyWithGenericError;

    actual = [VBXTrustHelper actionForSetupTrustIssueWithOSStatus:noErr
                                            secTrustResultType:kSecTrustResultDeny
                                  requireTrustedCertForThisURL:NO];
    STAssertEquals(expected, actual, nil);

    actual = [VBXTrustHelper actionForSetupTrustIssueWithOSStatus:noErr
                                            secTrustResultType:kSecTrustResultFatalTrustFailure
                                  requireTrustedCertForThisURL:NO];
    STAssertEquals(expected, actual, nil);

    actual = [VBXTrustHelper actionForSetupTrustIssueWithOSStatus:noErr
                                            secTrustResultType:kSecTrustResultOtherError
                                  requireTrustedCertForThisURL:NO];
    STAssertEquals(expected, actual, nil);

    actual = [VBXTrustHelper actionForSetupTrustIssueWithOSStatus:noErr
                                            secTrustResultType:kSecTrustResultOtherError
                                  requireTrustedCertForThisURL:NO];
    STAssertEquals(expected, actual, nil);    
}

- (void)testOSErrorDuringSetupReturnsGenericError {
    SetupTrustAction actual;
    SetupTrustAction expected = SetupTrustActionDenyWithGenericError;
    
    actual = [VBXTrustHelper actionForSetupTrustIssueWithOSStatus:1
                                            secTrustResultType:kSecTrustResultProceed
                                  requireTrustedCertForThisURL:NO];
    STAssertEquals(expected, actual, nil);    
}

- (void)testDuringSetupUntrustedCertReturnsPromptWhenTrustedCertWasNotRequired {
    SetupTrustAction actual;
    SetupTrustAction expected = SetupTrustActionPromptWithUntrustedCertAlert;
    
    actual = [VBXTrustHelper actionForSetupTrustIssueWithOSStatus:noErr
                                            secTrustResultType:kSecTrustResultRecoverableTrustFailure
                                  requireTrustedCertForThisURL:NO];
    STAssertEquals(expected, actual, nil);    
    
    actual = [VBXTrustHelper actionForSetupTrustIssueWithOSStatus:noErr
                                            secTrustResultType:kSecTrustResultConfirm
                                  requireTrustedCertForThisURL:NO];
    STAssertEquals(expected, actual, nil);
}

- (void)testDuringSetupUntrustedCertReturnsDenyWhenTrustedCertWasRequired {
    SetupTrustAction actual;
    SetupTrustAction expected = SetupTrustActionDenyWithTrustedCertRequiredAlert;
    
    actual = [VBXTrustHelper actionForSetupTrustIssueWithOSStatus:noErr
                                            secTrustResultType:kSecTrustResultRecoverableTrustFailure
                                  requireTrustedCertForThisURL:YES];
    STAssertEquals(expected, actual, nil);    
    
    actual = [VBXTrustHelper actionForSetupTrustIssueWithOSStatus:noErr
                                            secTrustResultType:kSecTrustResultConfirm
                                  requireTrustedCertForThisURL:YES];
    STAssertEquals(expected, actual, nil);
}
@end
