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

#import "VBXAudioPlaybackController.h"
#import "VBXURLLoader.h"
#import "VBXCache.h"
#import "UIExtensions.h"
#import "NSExtensions.h"
#import "UIViewPositioningExtension.h"
#import <AudioToolbox/AudioToolbox.h>
#import "VBXUserDefaultsKeys.h"
#import "VBXGlobal.h"
#import "VBXConfiguration.h"

@interface VBXAudioPlaybackController () <AVAudioPlayerDelegate, VBXURLLoaderDelegate>

@property (nonatomic, retain) VBXURLLoader *soundLoader;
@property (nonatomic, retain) AVAudioPlayer *audioPlayer;

@end

@implementation VBXAudioPlaybackController

@synthesize contentURL;
@synthesize userDefaults;
@synthesize soundLoader;
@synthesize cache;

@synthesize audioPlayer;

@synthesize playbackDelegate;
@synthesize isPaused;
@dynamic isPlaying;

- (void)dealloc {
    [audioPlayer stop];
    [soundLoader cancel];

    [contentURL release];
    [soundLoader release];
    [cache release];
    
    [audioPlayer release];

    [container release];

    [super dealloc];
}

- (void)updateAudioControls {
    [self performSelector:@selector(moveSliderToCurrentTime) withObject:nil afterDelay:0.0];
}

- (void)enableAudioControls {
    slider.enabled = YES;
    [self updateAudioControls];
}

- (void)disableAudioControls {
    slider.enabled = NO;
    [self updateAudioControls];
}

- (void)handleAudioError:(NSError *)error withTitle:(NSString *)title {
    debug(@"%@, error: %@", title, [error detailedDescription]);
    [UIAlertView showAlertViewWithTitle:title forError:error];
    [self disableAudioControls];
    [cache removeDataForKey:contentURL];
}

- (void)initializeAudioControlsWithData:(NSData *)data {        
    slider.hidden = NO;
    progressView.hidden = YES;

    NSError *error = nil;
    self.audioPlayer = [[[AVAudioPlayer alloc] initWithData:data error:&error] autorelease];
    if (error) {
        NSError *wrappedError = [NSError twilioErrorWithCode:VBXErrorBadAudioData underlyingError:error];
        [self handleAudioError:wrappedError withTitle:LocalizedString(@"Cannot play message", @"AudioPlaybackController: Message shown when the audio player won't start.")];
        return;
    }
    
    [audioPlayer prepareToPlay];
    audioPlayer.delegate = self;

    slider.maximumValue = audioPlayer.duration;
    [self enableAudioControls];
    
    if (waitingToPlay) [self play];
}

- (void)refresh {
    if (audioPlayer) {
        // already set up; just make sure controls are enabled
        [self enableAudioControls];
        return;
    }
    
    if (contentURL.length == 0) {
        [self disableAudioControls];
        return;
    }
    
    NSData *data = [cache dataForKey:contentURL];
    if (data) {
        [self initializeAudioControlsWithData:data];
    } else if (self.soundLoader == nil) {
        // We only bother to start the load if it's not already in progress
        self.soundLoader = [VBXURLLoader loadRequestWithURLString:contentURL andInform:self];
    }
}

- (void)viewDidLoad {
    //[super viewDidLoad];

    // We intentionally don't configure our view here because there is no point.  It only holds
    // two widgets and should just have a clear background.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refresh];
}

- (void)loadView {
    [super loadView];
    
    container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 30)];
    container.backgroundColor = [UIColor clearColor];
    container.autoresizesSubviews = YES;
    
    progressView = [[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault] autorelease];
    progressView.backgroundColor = [UIColor clearColor];
    progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    progressView.height = 9;    
    progressView.frame = CGRectMake(0, round((container.height / 2) - (progressView.height / 2)), container.width, 9);
    [container addSubview:progressView];
    
    // We start out at 10% just so the user knows we're doing something
    progressView.progress = 0.05;
    
    
    slider = [[[UISlider alloc] initWithFrame:container.bounds] autorelease];
    slider.backgroundColor = [UIColor clearColor];    
    slider.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    slider.height = 22;
    slider.frame = CGRectMake(0, round((container.height / 2) - (slider.height / 2)), container.width, 22);    
    [slider addTarget:self action:@selector(sliderChanged) forControlEvents:UIControlEventValueChanged];
    [slider addTarget:self action:@selector(sliderTouchDown) forControlEvents:UIControlEventTouchDown];    
    [slider addTarget:self action:@selector(sliderTouchUp) forControlEvents:UIControlEventTouchUpInside|UIControlEventTouchUpOutside];
    [container addSubview:slider];
    
    progressView.hidden = NO;
    slider.hidden = YES;
    
    self.view = container;
}

- (void)viewDidUnload {
    [self stop];
}

- (void)loaderDidReceiveData:(VBXURLLoader *)loader {
    // We clamp the lower value at 10% just so the user knows we're doing something
    progressView.progress = MAX(0.05, loader.downloadProgress);
}

- (void)loader:(VBXURLLoader *)loader didFinishWithData:(NSData *)data {
    [cache cacheData:data hadTrustedCertificate:loader.hadTrustedCertificate forKey:contentURL];
    [self initializeAudioControlsWithData:data];
}

- (void)loader:(VBXURLLoader *)loader didFailWithError:(NSError *)error {
    [self handleAudioError:error withTitle:LocalizedString(@"Could not download recording", @"AudioPlaybackController: Message shown when recording fails to download.")];
}

- (BOOL) isPlaying {
    return audioPlayer.playing;
}

- (void)setOutputToEarpiece {
    [userDefaults setBool:NO forKey:VBXUserDefaultsSpeakerMode];
    [userDefaults synchronize];     
    
    UInt32 sessionCategory = kAudioSessionCategory_PlayAndRecord;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_None;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
}

- (void)setOutputToSpeaker {
    [userDefaults setBool:YES forKey:VBXUserDefaultsSpeakerMode];
    [userDefaults synchronize];     
    
    UInt32 sessionCategory = kAudioSessionCategory_PlayAndRecord;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);    
}

- (void)play {
    if (!audioPlayer) {
        waitingToPlay = YES;
        return;
    }   
    
    if ([userDefaults boolForKey:VBXUserDefaultsSpeakerMode]) {
        [self setOutputToSpeaker];
    } else {
        [self setOutputToEarpiece];
    }
    
    // 'play' can return false if you happen to already be at the
    // end of the audio file.  e.g. maybe you skipped to the end and
    // then pressed the play button.
    BOOL willPlay = [audioPlayer play];
    
    if (willPlay) {
        isPaused = NO;
        waitingToPlay = NO;
        [self updateAudioControls];
        
        if (playbackDelegate != nil) {
            [playbackDelegate playbackDidPlayOrResume:self];
        }
    }
}

- (void)pause {
    isPaused = YES;
    waitingToPlay = NO;
    [audioPlayer pause];
    [self updateAudioControls];
    
    if (playbackDelegate != nil) {
        [playbackDelegate playbackDidPauseOrFinish:self];
    }    
}

- (void)stop {
    isPaused = NO;
    waitingToPlay = NO;
    [audioPlayer stop];
    [self updateAudioControls];
}

- (void)moveSliderToCurrentTime {
    [slider setValue:audioPlayer.currentTime animated:NO];
    
    if (audioPlayer.playing) {        
        [self performSelector:@selector(moveSliderToCurrentTime) withObject:nil afterDelay:0.0];
    }
}

- (IBAction)playOrPause {
    audioPlayer.playing? [self pause] : [self play];
}

- (void)sliderChanged {    
    audioPlayer.currentTime = slider.value;
}

- (void)sliderTouchDown {
    shouldResumePlayOnSliderTouchUp = audioPlayer.playing;

    if (audioPlayer.playing) {
        [audioPlayer pause];
    }    
}

- (void)sliderTouchUp {
    if (shouldResumePlayOnSliderTouchUp) {
        [audioPlayer play];
        [self performSelector:@selector(moveSliderToCurrentTime) withObject:nil afterDelay:0.0];
    }
}

#pragma mark AVAudioPlayerDelegate methods

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)success {
    success? [self updateAudioControls] : [self disableAudioControls];
    
    if (playbackDelegate != nil) {
        [playbackDelegate playbackDidPauseOrFinish:self];
    }
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error {
    NSError *wrappedError = [NSError twilioErrorWithCode:VBXErrorBadAudioData underlyingError:error];
    [self handleAudioError:wrappedError withTitle:LocalizedString(@"Problem playing message", @"AudioPlaybackController: Message shown when we can't decode the audio.")];
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player {
    //trace();
    interrupted = YES;
    [self disableAudioControls];
    
    if (playbackDelegate != nil) {
        [playbackDelegate playbackDidPauseOrFinish:self];
    }
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player {
    //trace();
    [self enableAudioControls];
    interrupted = NO;
    
    if (playbackDelegate != nil) {
        [playbackDelegate playbackDidPlayOrResume:self];
    }
}

@end
