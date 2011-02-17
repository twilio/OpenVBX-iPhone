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
#import <AVFoundation/AVFoundation.h>
#import "VBXViewController.h"

@class VBXURLLoader;
@class VBXCache;
@protocol VBXAudioPlaybackControllerDelegate;

@interface VBXAudioPlaybackController : UIViewController {
    NSUserDefaults *userDefaults;
    NSString *contentURL;
    VBXURLLoader *soundLoader;
    VBXCache *cache;

    AVAudioPlayer *audioPlayer;
    BOOL interrupted;
    BOOL waitingToPlay;
    BOOL isPaused;
    
    BOOL shouldResumePlayOnSliderTouchUp;
    
    NSString *downloadErrorMessage;
    NSString *initErrorMessage;
    NSString *playErrorMessage;

    UIView *container;
    UIProgressView *progressView;
    UISlider *slider;
    
    id<VBXAudioPlaybackControllerDelegate> playbackDelegate;
}

@property (nonatomic, retain) NSString *contentURL;
@property (nonatomic, retain) NSUserDefaults *userDefaults;
@property (nonatomic, retain) VBXCache *cache;

@property (nonatomic, readonly) BOOL isPaused;
@property (nonatomic, readonly) BOOL isPlaying;

@property (nonatomic, assign) id<VBXAudioPlaybackControllerDelegate> playbackDelegate;

- (void)refresh;

- (void)play;
- (void)pause;
- (void)stop;

- (void)setOutputToEarpiece;
- (void)setOutputToSpeaker;

- (IBAction)playOrPause;
- (IBAction)sliderChanged;

@end

@protocol VBXAudioPlaybackControllerDelegate

- (void)playbackDidPlayOrResume:(VBXAudioPlaybackController *)controller;
- (void)playbackDidPauseOrFinish:(VBXAudioPlaybackController *)controller;

@end

