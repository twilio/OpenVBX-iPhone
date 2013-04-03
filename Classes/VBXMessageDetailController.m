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

#import "VBXMessageDetailController.h"
#import "VBXMessageDetail.h"
#import "VBXUser.h"
#import "VBXAnnotation.h"
#import "VBXSublist.h"
#import "VBXMessageAttribute.h"
#import "VBXMessageDetailAccessor.h"
#import "VBXDialerAccessor.h"
#import "VBXMessageAttributeController.h"
#import "VBXDialerController.h"
#import "VBXSendTextController.h"
#import "VBXAudioPlaybackController.h"
#import "VBXTextEntryController.h"
#import "VBXObjectBuilder.h"
#import "UIExtensions.h"
#import "NSExtensions.h"
#import "VBXTableView.h"
#import "UIViewPositioningExtension.h"
#import "VBXSectionedDataSource.h"
#import "VBXGlobal.h"
#import "VBXAudioControl.h"
#import "VBXStringPartLabel.h"
#import "VBXUserDefaultsKeys.h"
#import "VBXMessageListController.h"
#import <QuartzCore/QuartzCore.h>
#import "VBXViewCell.h"
#import "VBXNavigationController.h"
#import "VBXConfiguration.h"
#import "VBXTableViewCell.h"
#import "VBXLoadMoreCell.h"

#define kSheetTagCallback 101
#define kSheetTagArchive 102
#define kSheetTagContactFromLinkInTranscription 103

@interface ChangeAnnotationCell : VBXTableViewCell <VBXVariableHeightCell> {
    VBXAnnotation *annotation;
    
    UILabel *nameLabel;
    UILabel *bodyLabel;
    UILabel *timestampLabel;
}

@property (nonatomic, retain) VBXAnnotation *annotation;

@end

@implementation ChangeAnnotationCell 

@synthesize annotation;

- (id)initWithAnnotation:(VBXAnnotation *)anAnnotation reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.annotation = anAnnotation;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        nameLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        nameLabel.font = [UIFont boldSystemFontOfSize:14.0];
        nameLabel.numberOfLines = 1;
        nameLabel.lineBreakMode = UILineBreakModeTailTruncation | UILineBreakModeWordWrap;
        nameLabel.text = [NSString stringWithFormat:@"%@ %@", anAnnotation.firstName, anAnnotation.lastName];
        [self.contentView addSubview:nameLabel];
        
        timestampLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        timestampLabel.font = [UIFont systemFontOfSize:14.0];
        timestampLabel.numberOfLines = 1;
        timestampLabel.lineBreakMode = UILineBreakModeTailTruncation;
        timestampLabel.textAlignment = UITextAlignmentRight;
        timestampLabel.text = VBXDateToDateAndTimeString(VBXParseISODateString(anAnnotation.created));
        [self.contentView addSubview:timestampLabel];
        
        bodyLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        bodyLabel.font = [UIFont systemFontOfSize:14.0];
        bodyLabel.numberOfLines = 0;
        bodyLabel.lineBreakMode = UILineBreakModeTailTruncation | UILineBreakModeWordWrap;
        bodyLabel.contentMode = UIViewContentModeBottomLeft;
        bodyLabel.text = anAnnotation.description;        
        [self.contentView addSubview:bodyLabel];        
        
        [self applyConfig];
        
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize size = self.contentView.size;
    
    const NSInteger vertPadding = 4;
    const NSInteger horizPadding = 8;
    
    timestampLabel.width = 100;
    [timestampLabel sizeToFit];
    timestampLabel.right = size.width - horizPadding;
    
    nameLabel.left = horizPadding;
    nameLabel.top = vertPadding;
    [nameLabel sizeToFit];    
    nameLabel.width = timestampLabel.left - horizPadding - horizPadding;
    
    timestampLabel.bottom = nameLabel.bottom;
    
    bodyLabel.left = horizPadding;
    bodyLabel.top = nameLabel.bottom + vertPadding + vertPadding;
    bodyLabel.width = timestampLabel.right - (horizPadding / 2);
    [bodyLabel sizeToFit];
    bodyLabel.height = MIN(bodyLabel.height, self.contentView.height - vertPadding - bodyLabel.top);    
}

- (void)dealloc {
    self.annotation = nil;
    [super dealloc];
}

- (void)applyConfig {
    [super applyConfig];
    
    self.backgroundColor = ThemedColor(@"messageDetailChangeAnnotationBackgroundColor", RGBHEXCOLOR(0xf0f0f0));    
    nameLabel.backgroundColor = self.backgroundColor;
    timestampLabel.backgroundColor = self.backgroundColor;    
    bodyLabel.backgroundColor = self.backgroundColor;
    
    nameLabel.textColor = ThemedColor(@"messageDetailAnnotationNameTextColor", ThemedColor(@"primaryTextColor", [UIColor blackColor]));
    timestampLabel.textColor = ThemedColor(@"messageDetailAnnotationTimestampTextColor", ThemedColor(@"messageListTimestampTextColor", RGBHEXCOLOR(0x2470d8)));
    bodyLabel.textColor = ThemedColor(@"messageDetailAnnotationBodyTextColor", ThemedColor(@"secondaryTextColor", [UIColor grayColor]));
}

- (CGFloat)heightForCell {
    self.height = 9999;    
    return bodyLabel.bottom + 4;
}

@end

@interface NoteAnnotationCell : VBXTableViewCell <VBXVariableHeightCell> {
    VBXAnnotation *annotation;

    UILabel *nameLabel;
    UILabel *timestampLabel;
    UILabel *bodyLabel;
}

@property (nonatomic, retain) VBXAnnotation *annotation;

@end

@implementation NoteAnnotationCell 

@synthesize annotation;

- (id)initWithAnnotation:(VBXAnnotation *)anAnnotation reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.annotation = anAnnotation;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        nameLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        nameLabel.font = [UIFont boldSystemFontOfSize:14.0];
        nameLabel.numberOfLines = 1;
        nameLabel.lineBreakMode = UILineBreakModeTailTruncation | UILineBreakModeWordWrap;
        nameLabel.text = [NSString stringWithFormat:@"%@ %@", anAnnotation.firstName, anAnnotation.lastName];
        [self.contentView addSubview:nameLabel];
        
        timestampLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        timestampLabel.font = [UIFont systemFontOfSize:14.0];
        timestampLabel.numberOfLines = 1;
        timestampLabel.lineBreakMode = UILineBreakModeTailTruncation;
        timestampLabel.textAlignment = UITextAlignmentRight;
        timestampLabel.text = VBXDateToDateAndTimeString(VBXParseISODateString(anAnnotation.created));
        [self.contentView addSubview:timestampLabel];
        
        bodyLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        bodyLabel.font = [UIFont systemFontOfSize:14.0];
        bodyLabel.numberOfLines = 0;
        bodyLabel.lineBreakMode = UILineBreakModeTailTruncation | UILineBreakModeWordWrap;
        bodyLabel.contentMode = UIViewContentModeBottomLeft;
        bodyLabel.text = anAnnotation.description;
        [self.contentView addSubview:bodyLabel];
        
        [self applyConfig];
        
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize size = self.contentView.size;
    
    const NSInteger vertPadding = 4;
    const NSInteger horizPadding = 8;
    
    timestampLabel.width = 100;
    [timestampLabel sizeToFit];
    timestampLabel.right = size.width - horizPadding;
    
    nameLabel.left = horizPadding;
    nameLabel.top = vertPadding;
    [nameLabel sizeToFit];    
    nameLabel.width = timestampLabel.left - horizPadding - horizPadding;
    
    timestampLabel.bottom = nameLabel.bottom;
    
    bodyLabel.left = horizPadding;
    bodyLabel.top = nameLabel.bottom + vertPadding + vertPadding;
    bodyLabel.width = timestampLabel.right - (horizPadding / 2);
    [bodyLabel sizeToFit];
    bodyLabel.height = MIN(bodyLabel.height, self.contentView.height - vertPadding - bodyLabel.top);    
}

- (void)applyConfig {
    [super applyConfig];
    
    self.backgroundColor = ThemedColor(@"messageDetailNoteAnnotationBackgroundColor", ThemedColor(@"tableViewCellBackgroundColor", [UIColor whiteColor]));
    nameLabel.backgroundColor = self.backgroundColor;
    timestampLabel.backgroundColor = self.backgroundColor;    
    bodyLabel.backgroundColor = self.backgroundColor;
    
    nameLabel.textColor = ThemedColor(@"messageDetailAnnotationNameTextColor", ThemedColor(@"primaryTextColor", [UIColor blackColor]));
    timestampLabel.textColor = ThemedColor(@"messageDetailAnnotationTimestampTextColor", ThemedColor(@"messageListTimestampTextColor", RGBHEXCOLOR(0x2470d8)));
    bodyLabel.textColor = ThemedColor(@"messageDetailAnnotationBodyTextColor", ThemedColor(@"secondaryTextColor", [UIColor grayColor]));    
}

- (void)dealloc {
    self.annotation = nil;
    [super dealloc];
}

- (CGFloat)heightForCell {
    self.height = 9999;    
    return bodyLabel.bottom + 4;
}   

@end


@interface MessageAttributeCell : VBXTableViewCell {
    VBXMessageAttribute *_attribute;
}

@property (nonatomic, retain) VBXMessageAttribute *attribute;

- (id)initWithAttribute:(VBXMessageAttribute *)attribute_ reuseIdentifier:(NSString *)reuseIdentifier;

@end

@implementation MessageAttributeCell

@synthesize attribute = _attribute;

- (id)initWithAttribute:(VBXMessageAttribute *)attribute reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier]) {
        self.attribute = attribute;
        self.textLabel.text = [attribute name];
        self.detailTextLabel.text = [self.attribute titleForValue:[attribute value]];
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}

- (void)dealloc {
    self.attribute = nil;
    [super dealloc];
}

@end

@interface VBXMessageDetailController () <UIActionSheetDelegate, VBXAudioPlaybackControllerDelegate, VBXAudioControlDelegate, VBXMessageDetailAccessorDelegate, VBXDialerAccessorDelegate, UIWebViewDelegate>
- (void)didClickPhoneNumberInTranscription:(NSString *)phoneNumber;
@property (nonatomic, retain) NSString *newNoteText;
@end


@implementation VBXMessageDetailController

@synthesize userDefaults = _userDefaults;
@synthesize accessor = _accessor;
@synthesize dialerAccessor = _dialerAccessor;
@synthesize playbackController = _playbackController;
@synthesize messageListController = _messageListController;
@synthesize builder = _builder;
@synthesize bundle = _bundle;
@synthesize newNoteText = _newNoteText;


@synthesize headerView = _headerView;
@synthesize callerLabel = _callerLabel;
@synthesize destinationLabel = _destinationLabel;
@synthesize timeLabel = _timeLabel;
@synthesize audioControlsFrame = _audioControlsFrame;

@synthesize loadMoreCell = _loadMoreCell;

@synthesize refreshButton = _refreshButton;
@synthesize replyButton = _replyButton;
@synthesize dialerButton = _dialerButton;

- (void)toggleMediaRoute {
    if (self.navigationItem.rightBarButtonItem.style == UIBarButtonItemStyleBordered) {
        [_playbackController setOutputToSpeaker];
        self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStyleDone;
    } else {
        [_playbackController setOutputToEarpiece];
        self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStyleBordered;
    }
}

- (void)setupSpeakerToggleButton {
    UIBarButtonItemStyle style = 0;
    
    if ([_userDefaults boolForKey:VBXUserDefaultsSpeakerMode]) {
        style = UIBarButtonItemStyleDone;
    } else {
        style = UIBarButtonItemStyleBordered;
    }
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:LocalizedString(@"Speaker", @"Message Detail: Used to switch to speaker mode.")
                                                                               style:style
                                                                              target:self 
                                                                              action:@selector(toggleMediaRoute)] autorelease];    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _tableStyle = UITableViewStyleGrouped;
        
        _deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash 
                                                                       target:self 
                                                                       action:@selector(deleteMessage)];
    }
    return self;
}

- (void)dealloc {
    if ([_webView isLoading]) {
        [_webView stopLoading];
    }
    _webView.delegate = nil;
    
    [_accessor release];
    [_dialerAccessor release];
    [_playbackController release];
    [_bundle release];
    [_newNoteText release];    

    [_headerView release];
    [_callerLabel release];
    [_timeLabel release];
    [_audioControlsFrame release];

    [_refreshButton release];
    [_replyButton release];
    [_dialerButton release];
    
    [_messageView release];
    [_deleteButton release];
    
    [_webView release];
    [_phoneNumberClickedInMessage release];

    [super dealloc];
}

#pragma mark Message detail control

- (void)refreshHeader {
    VBXMessageDetail *detail = _accessor.model;
    _callerLabel.text = detail.caller;
    _timeLabel.text = detail.receivedTime;
    
    _destinationLabel.text = [detail.folder uppercaseString];
}

- (UITableViewCell *)audioPlayerCell {
    UIView *audioPlayerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 290, 50)] autorelease];
    audioPlayerView.backgroundColor = [UIColor clearColor];
    
    _audioControl = [[[VBXAudioControl alloc] init] autorelease];
    _audioControl.delegate = self;
    [audioPlayerView addSubview:_audioControl];
    [audioPlayerView addSubview:_playbackController.view];
    [_playbackController viewWillAppear:NO];
    [_playbackController viewDidAppear:NO];
    _playbackController.playbackDelegate = self;
    
    const NSInteger padding = 0;
    
    [_playbackController.view sizeToFit];
    [_audioControl sizeToFit];
    
    _audioControl.left = padding + round(_audioControl.width / 2);
    _audioControl.top = round((audioPlayerView.height / 2) - (_audioControl.height / 2));
    
    _playbackController.view.left = _audioControl.right + round(_audioControl.width / 2) + padding;
    _playbackController.view.width = audioPlayerView.width - padding - _playbackController.view.left;
    _playbackController.view.top = round((audioPlayerView.height / 2) - (_playbackController.view.height / 2));    
    
    return [[[VBXViewCell alloc] initWithView:audioPlayerView reuseIdentifier:nil] autorelease];    
}

- (void)rebuildSections {
    VBXMessageDetail *detail = _accessor.model;
            
    NSMutableArray *items = [NSMutableArray array];
    [items addObject:@""]; // empty header
    
    if (!detail.isSms) {
        [items addObject:[self audioPlayerCell]];
    }
    
    VBXViewCell *transcriptionCell = [[[VBXViewCell alloc] initWithView:_webView reuseIdentifier:nil] autorelease];
    // Add some extra padding at the end so that the boxed edges of our UIWebView don't obsure the rounded
    // edges of our grouped tableviewcell.
    // Also, if it's an SMS message, then the top corners of the transcription cell will be rounded.  In that
    // case, we push the web view down a little bit so the rounded edges of the tableview aren't obscured.
    transcriptionCell.contentInsets = UIEdgeInsetsMake(detail.isSms ? 9 : 0, 0, 9, 0);    
    
    [items addObject:transcriptionCell];
    [items addObject:@""]; // empty footer
    
    if (!detail.isSms) {
        [items addObjectsFromArray:[NSArray arrayWithObjects:
                                    @"", // empty header
                                    [[[MessageAttributeCell alloc] initWithAttribute:[VBXMessageAttribute ticketStatusAttributeForMessage:detail name:LocalizedString(@"Status", @"Message Detail: Title for table cell")]
                                                                     reuseIdentifier:nil] autorelease],
                                    [[[MessageAttributeCell alloc] initWithAttribute:[VBXMessageAttribute assignedUserAttributeForMessage:detail name:LocalizedString(@"Assigned to", @"Message Detail: Title for table cell")]
                                                                     reuseIdentifier:nil] autorelease],
                                    @"", // empty footter                                    
                                    nil]];

        _addNoteCell = [[[VBXTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil] autorelease];
        _addNoteCell.textLabel.text = @"Add Note";
        _addNoteCell.textLabel.textAlignment = UITextAlignmentCenter;
        
        [items addObject:@""]; // empty header
        [items addObject:_addNoteCell];
        
        for (VBXAnnotation *annotation in detail.annotations.items) {
            UITableViewCell *cell = nil;
            
            if ([annotation.type isEqualToString:@"changed"]) {
                cell = [[[ChangeAnnotationCell alloc] initWithAnnotation:annotation reuseIdentifier:nil] autorelease];
            } else if ([annotation.type isEqualToString:@"noted"]) {
                cell = [[[NoteAnnotationCell alloc] initWithAnnotation:annotation reuseIdentifier:nil] autorelease];
            } else {
                debug(@"Skipping annotation with type '%@' - I don't know how to render it.", annotation.type);
            }
            
            if (cell != nil) {
                [items addObject:cell];
            }
        }
        
        _loadMoreCell = [[[VBXLoadMoreCell alloc] initWithReuseIdentifier:nil] autorelease];
        _loadMoreCell.detailTextLabel.text = nil;
        
        if (detail.annotations.items.count < detail.annotations.total) {
            [items addObject:_loadMoreCell];
        }
        
        [items addObject:@""]; // empty footer        
    }
    

    _dataSource = [[VBXSectionedCellDataSource dataSourceWithArray:items] retain];
    
    self.tableView.dataSource = _dataSource;
    self.tableView.delegate = _dataSource;
    _dataSource.proxyToDelegate = self;
    
    [self.tableView reloadData];
}

- (void)enableControlsWithStatusMessage:(NSString *)message {
    _refreshButton.enabled = YES;
    _deleteButton.enabled = YES;
    _replyButton.enabled = YES;
    
    VBXMessageDetail *detail = _accessor.model;
    
    _replyButton.enabled = (detail.caller.length > 0);
    
    _messageView.parts = [NSArray arrayWithObject:[VBXStringPart partWithText:message font:[UIFont boldSystemFontOfSize:13]]];
}

- (void)enableControls {
    [self enableControlsWithStatusMessage:nil];
}

- (void)disableControls {
    _refreshButton.enabled = NO;
    _deleteButton.enabled = NO;
    _replyButton.enabled = NO;
}

- (void)deleteMessage {
    UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:LocalizedString(@"Permanently delete this message?", @"Message Details: Title on the action sheet when you click delete.")
                                                              delegate:self
                                                     cancelButtonTitle:LocalizedString(@"Cancel", nil)
                                                destructiveButtonTitle:LocalizedString(@"Delete Message", @"Message Detail: Label for Delete action in action sheet.")
                                                     otherButtonTitles:nil]
                                  autorelease];
    actionSheet.tag = kSheetTagArchive;
    [actionSheet showFromToolbar:self.navigationController.toolbar];    
}

- (void)accessorDidArchiveMessage:(VBXMessageDetailAccessor *)accessor {
    [self.messageListController didArchiveSelectedMessage];
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)accessor:(VBXMessageDetailAccessor *)accessor archiveDidFailWithError:(NSError *)error {
    [self unsetPromptAndUndim];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Error", @"Message Detail: Title on the alert view when archive fails.")
                                                    message:LocalizedString(@"There was a problem archiving this message.", @"Message Detail: Body of the alert view when archive fails.")
                                                   delegate:self 
                                          cancelButtonTitle:LocalizedString(@"OK", nil)
                                          otherButtonTitles:nil];
    [alert show];
    [alert release];    
}


- (void)showExtraControlsAfterGoodLoad {
    _refreshButton.enabled = YES;
    _deleteButton.enabled = YES;
    _replyButton.enabled = YES;
    
    self.toolbarItems = [NSArray arrayWithObjects:
                         _refreshButton, 
                         [UIBarButtonItem flexibleSpace], 
                         _deleteButton,
                         [UIBarButtonItem flexibleSpace], 
                         _replyButton,
                         nil];
}

- (void)showLoadedState:(BOOL)fromNetwork {
    [super showLoadedState];
    
    // Show the newly updated timestmap
    NSDate *lastUpdatedDate = [_accessor timestampOfCachedData];
    _messageView.parts = VBXStringPartsForUpdatedAtDate(lastUpdatedDate);
    
    if (fromNetwork) {
        // Then, after a moment, show more controls
        [self performSelector:@selector(showExtraControlsAfterGoodLoad) withObject:nil afterDelay:1.0];
    }
}

- (void)showLoadingState {
    [super showLoadingState];
    
    [self disableControls];

    _messageView.parts = [NSArray arrayWithObjects:nil];
}

- (void)showErrorState {
    [super showErrorState];
    
    self.refreshButton.enabled = YES;
}

- (void)showMessage:(NSString *)message {
    [self disableControls];

    _messageView.parts = [NSArray arrayWithObject:[VBXStringPart partWithText:message font:[UIFont boldSystemFontOfSize:13]]];
}

- (void)showRefreshingState {
    [super showRefreshingState];
    [self showMessage:LocalizedString(@"Updating...", @"Message Detail: Shows when the message content is refreshing.")];
}

- (void)showLoadMoreSpinny {
    [self disableControls];

    _messageView.parts = [NSArray arrayWithObjects:nil];
}

- (void)refreshView {
    [self enableControls];
    [self refreshHeader];
    [self rebuildSections];
}

- (void)applyConfig {
    [super applyConfig];

    _callerLabel.textColor = ThemedColor(@"messageDetailCallerTextColor", ThemedColor(@"primaryTextColor", [UIColor blackColor]));
    _timeLabel.textColor = ThemedColor(@"messageDetailTimestampTextColor", ThemedColor(@"primaryTextColor", [UIColor blackColor]));
    _destinationLabel.textColor = ThemedColor(@"messageDetailDestinationTextColor", ThemedColor(@"primaryTextColor", [UIColor blackColor]));

    _callerLabel.shadowOffset = CGSizeMake(0, 1);
    _callerLabel.shadowColor = ThemedColor(@"messageDetailCallerTextShadowColor", [[UIColor whiteColor] colorWithAlphaComponent:0.75]);

    _timeLabel.shadowOffset = CGSizeMake(0, 1);
    _timeLabel.shadowColor = ThemedColor(@"messageDetailTimestampTextShadowColor", [[UIColor whiteColor] colorWithAlphaComponent:0.75]);

    _destinationLabel.shadowOffset = CGSizeMake(0, 1);
    _destinationLabel.shadowColor = ThemedColor(@"messageDetailDestinationTextShadowColor", [[UIColor whiteColor] colorWithAlphaComponent:0.75]);
    
    // Some things we don't want to theme...
    _headerView.backgroundColor = VBXTableViewGroupedBackgroundColor();    
    _audioControlsFrame.backgroundColor = [UIColor clearColor];
    _audioControl.backgroundColor = [UIColor clearColor];
}

- (void)loadView {
    [super loadView];
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 300, 20)];
    _webView.dataDetectorTypes = UIDataDetectorTypeLink;
    _webView.delegate = self;

    // Hack to disable scrolling of the webview content.
    for (UIView *v in _webView.subviews) {
        if ([v isKindOfClass:[UIScrollView class]]) {
            [(UIScrollView *)v setBounces:NO];
            [(UIScrollView *)v setScrollEnabled:NO];
        }
    }
    
    _messageView = [[VBXStringPartLabel alloc] initWithFrame:CGRectMake(0, 0, 200, 18)];
    _messageView.textAlignment = UITextAlignmentCenter;
    _messageView.textColor = [UIColor whiteColor];
    _messageView.shadowColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.8];
    _messageView.shadowOffset = CGSizeMake(0, -1);
    
    self.toolbarItems = [NSArray arrayWithObjects:
                         _refreshButton,
                         [UIBarButtonItem flexibleSpace], 
                         [UIBarButtonItem itemWithCustomView:_messageView],
                         [UIBarButtonItem flexibleSpace], 
                         _replyButton,
                         nil];

    _callerLabel.backgroundColor = VBXTableViewGroupedBackgroundColor();
    _timeLabel.backgroundColor = VBXTableViewGroupedBackgroundColor();
    _destinationLabel.backgroundColor = VBXTableViewGroupedBackgroundColor();
    
    self.tableView.tableHeaderView = _headerView;
    
    if (!self.navigationItem.title) {
        self.navigationItem.title = LocalizedString(@"Details", @"Message Detail: Title of screen.");
    }

    if (self.playbackController.contentURL != nil && self.playbackController.contentURL.length > 0) {
        // It's a voicemail
        [self setupSpeakerToggleButton];
    }

    _accessor.delegate = self;
    
    VBXHSL barButtonNormalHsl = ThemedHSL(@"messageDetailReplyButtonNormalHSL", VBXHSLMake(211, 26, 11));
    VBXHSL barButtonHighlightedHsl = ThemedHSL(@"messageDetailReplyButtonHighlightedHSL", VBXHSLMake(211, 26, -20));    

    _actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _actionButton.backgroundColor = VBXTableViewGroupedBackgroundColor();
    [_actionButton setTitle:LocalizedString(@"REPLY", @"Message Detail: Title for reply button") forState:UIControlStateNormal];    
    [_actionButton setBackgroundImage:VBXAdjustImageWithPhotoshopHSLWithCache(_userDefaults, @"barbutton.png", @"normal", barButtonNormalHsl) forState:UIControlStateNormal];
    [_actionButton setBackgroundImage:VBXAdjustImageWithPhotoshopHSLWithCache(_userDefaults, @"barbutton.png", @"highlighted", barButtonHighlightedHsl) forState:UIControlStateHighlighted];    
    _actionButton.titleLabel.font = [UIFont boldSystemFontOfSize:13.0];
    _actionButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
    _actionButton.titleLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.2];
    
    [_actionButton sizeToFit];
    _actionButton.right = 312;
    _actionButton.top = round((_headerView.height / 2) - (_actionButton.height / 2)) + 5;    
    
    [_headerView addSubview:_actionButton];
    [_actionButton addTarget:self action:@selector(reply) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];

    // If newNoteText is not nil, then we're returning from the note text modal view, and we don't
    // want to call refreshView as it re-enables all our controls.  We'll take care of re-enabling
    // stuff after we've posted the note.
    if (_newNoteText == nil && _accessor.model != nil) {        
        [self refreshView];
    }
    
    if (_accessor.model) {
        [self showLoadedState:YES];
        [self.tableView reloadData];
    } else {
        [self showLoadingState];
        [_accessor loadUsingCache:YES];
    }    
}

- (void)viewWillDisappear:(BOOL)animated {
    [_playbackController stop];
    if ([_webView isLoading]) {
        [_webView stopLoading];
    }
    _webView.delegate = nil;
    [super viewWillDisappear:animated];
}

- (IBAction)refresh {
    [self showMessage:LocalizedString(@"Updating...", @"Message Detail: Shown when we're refreshing the message content from the server.")];
    [_accessor loadUsingCache:NO];
    [_playbackController refresh];
}

- (IBAction)loadMoreAnnotations {
    [self.tableView selectRowAtIndexPath:[self.tableView indexPathForCell:_loadMoreCell] animated:YES scrollPosition:UITableViewScrollPositionNone];
    
    _loadMoreCell.titleLabel.text = LocalizedString(@"Loading...", @"Message List: Text for full screen loading indicator, when there is no cache.");
    _loadMoreCell.titleLabel.textColor = [UIColor darkGrayColor];
    [_loadMoreCell.spinner startAnimating];
    
    [_accessor loadMoreAnnotations];
}

- (NSString *)wrapPhoneNumbersInLinks:(NSString *)text {
    
    NSMutableString *copy = [[[NSMutableString alloc] initWithString:text] autorelease];
    
    NSArray *patterns = [NSArray arrayWithObjects:
                         // Any string of 7 or more numbers
                         @"(\\d{7,}+)",
                         // (555) 555-5555
                         @"(\\(\\d{3}\\)\\s\\d{3}-\\d{4})",
                         nil];
    
    // ObjPCRE looks to have some support for back references, but it seems broken :-(
    // So, instead we do the replacement ourselves...
    for (NSString *pattern in patterns) {
        int offset = 0;
        for (;;) {
            // NSLog(@"Text: %@", [copy stringByReplacingCharactersInRange:NSMakeRange(offset, 0) withString:@"|"]);
            
            NSError *error = NULL;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
            NSUInteger numberOfMatches = [regex numberOfMatchesInString:copy options:0 range:NSMakeRange(offset, [copy length])];
            
            if (numberOfMatches > 0) {
                NSRange rangeOfFirstMatch = [regex rangeOfFirstMatchInString:copy options:0 range:NSMakeRange(offset, [copy length])];
                if (!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound, 0))) {

                    
                    NSString *match = [copy substringWithRange:rangeOfFirstMatch];
                    
                    // NSLog(@"Match: '%@' @ %d (%d)", match, location, length);
                    
                    NSString *replacementText = [NSString stringWithFormat:@"<a href=\"phonenumber:%@\">%@</a>", match, match];
                    
                    [copy replaceCharactersInRange:rangeOfFirstMatch withString:replacementText];
                    
                    // Adjust the offset so it's now just after the last replacement
                    // we just did.  That way we don't look at the same thing twice.
                    offset = rangeOfFirstMatch.location + replacementText.length;
                } else {
                    break;
                }
            } else {
                break;
            }
        }
    }
    
    return copy;
}

- (void)prepareTranscriptionText {
    if ([_webView isLoading]) {
        [_webView stopLoading];
    }
    
    NSString *summaryText = nil;
    NSString *fontStyle = nil;
    
    if (_accessor.model.summary == nil) {
        fontStyle = @"italic";
        summaryText = LocalizedString(@"No transcription available.", @"Message Detail: Text that appears in the message view when the body is empty.");
    } else {
        fontStyle = @"normal";
        summaryText = _accessor.model.summary;
    }

    NSString *color = [ThemedColor(@"messageDetailTranscriptionTextColor", ThemedColor(@"primaryTextColor", [UIColor blackColor])) hexValue];
    
    NSString *text = [self wrapPhoneNumbersInLinks:summaryText];
    
    NSString *html = [NSString stringWithFormat:@"<html><body style=\"background-color: transparent;\"><span id=\"content\" style=\"font-family: Helvetica; font-size: 15px; font-style: %@; color: #%@\">%@</span><br><br></body></html>", fontStyle, color, text];
    
    [_webView loadHTMLString:html baseURL:nil];
}

- (void)finishedPreparingTranscriptionText {
    [self refreshView];    
    [self showLoadedState:!_accessor.modelIsFromCache];
    
    if (_accessor.modelIsFromCache) {
        // We don't show this immediately because we want the user to have a chance to see
        // the timestamp for the cached data.
        [self performSelector:@selector(showRefreshingAfterDelay) withObject:nil afterDelay:1.0];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([request.URL.scheme isEqualToString:@"phonenumber"]) {
        // Remove the "phonenumber:" part        
        NSString *numberAsString = VBXStripNonDigitsFromString([[[request.URL absoluteString] substringFromIndex:(request.URL.scheme.length + 1)] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
        
        [self didClickPhoneNumberInTranscription:numberAsString];
        return NO;
    } else {
        return YES;
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
    _webView.height = [[_webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight;"] floatValue];
    [self finishedPreparingTranscriptionText];
}

- (void)showRefreshingAfterDelay {
    [self showRefreshingState];
}

- (void)accessorDidLoadData:(VBXMessageDetailAccessor *)accessor fromCache:(BOOL)fromCache {
    [self prepareTranscriptionText];
}

- (void)accessor:(VBXMessageDetailAccessor *)a loadDidFailWithError:(NSError *)error {
    debug(@"%@", [error detailedDescription]);
    if ([error isTwilioErrorWithCode:VBXErrorNoNetwork] && _accessor.model) {
        // We failed to load for lack of a network connection, but we have data already from cache. Don't bug the user with a popup.
        [self enableControlsWithStatusMessage:LocalizedString(@"No network; loaded data from cache", @"Message Detail: Message shown when we failed to update the message content from the server.")];
        return;
    } else if ([error isTwilioErrorWithCode:VBXErrorLoginRequired]) {
        return;
    }

    [UIAlertView showAlertViewWithTitle:LocalizedString(@"Could not load message", @"Message Detail: Shown when we failed to load the message and there is no cache data to pull from.") forError:error];
    [self refreshView];
}

#pragma mark Call-back and dialer methods

- (void)playbackDidPlayOrResume:(VBXAudioPlaybackController *)controller {
    [_audioControl showPauseButton];
}

- (void)playbackDidPauseOrFinish:(VBXAudioPlaybackController *)controller {
    [_audioControl showPlayButton];    
}

- (void)audioControlDidPressControl:(VBXAudioControl *)anAudioControl {
    [_playbackController playOrPause];
}

- (IBAction)reply {
    VBXMessageDetail *detail = _accessor.model;
    if (detail.caller.length == 0) return;
    
    NSString *callbackButtonTitle = [NSString stringWithFormat:LocalizedString(@"Call %@", @"Mesage Detail: Title for Call button in action sheet, param is phone number"), detail.caller];
    NSString *smsButtonTitle = [NSString stringWithFormat:LocalizedString(@"SMS %@", @"Mesage Detail: Title for SMS button in action sheet, param is phone number"), detail.caller];
    
    UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:nil 
                                                              delegate:self
                                                     cancelButtonTitle:LocalizedString(@"Cancel", nil) 
                                                destructiveButtonTitle:nil 
                                                     otherButtonTitles:callbackButtonTitle, smsButtonTitle, nil] autorelease];
    actionSheet.tag = kSheetTagCallback;
    [actionSheet showFromToolbar:self.navigationController.toolbar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == kSheetTagCallback) {
        if (buttonIndex == [actionSheet cancelButtonIndex]) {
            // do nothing
        } else if (buttonIndex == [actionSheet firstOtherButtonIndex]) {
            VBXMessageDetail *detail = _accessor.model;
            VBXNavigationController *controller = (VBXNavigationController *)self.navigationController;
            [controller showDialerWithState:[NSDictionary dictionaryWithObjectsAndKeys:
                                             detail.caller,
                                             @"to",
                                             detail.called,
                                             @"from",
                                             nil]
                                   animated:YES];
        } else if (buttonIndex == [actionSheet firstOtherButtonIndex] + 1) {
            VBXMessageDetail *detail = _accessor.model;
            VBXNavigationController *controller = (VBXNavigationController *)self.navigationController;
            [controller showSendTextWithState:[NSDictionary dictionaryWithObjectsAndKeys:
                                               detail.caller,
                                               @"to",
                                               detail.called,
                                               @"from",                                               
                                               nil]
                                     animated:YES];
        }
    } else if (actionSheet.tag == kSheetTagArchive) {
        if (buttonIndex == [actionSheet cancelButtonIndex]) {
            // do nothing
        } else {
            [_accessor archiveMessage];
            [self setPromptAndDimView:LocalizedString(@"Deleting message...", @"Message Detail: Navigation Bar Prompt that appears when deletion is in progress.")];
        }
    } else if (actionSheet.tag == kSheetTagContactFromLinkInTranscription) {
        if (buttonIndex == [actionSheet cancelButtonIndex]) {
            // do nothing
        } else if (buttonIndex == [actionSheet firstOtherButtonIndex]) {
            VBXNavigationController *controller = (VBXNavigationController *)self.navigationController;
            [controller showDialerWithState:[NSDictionary dictionaryWithObjectsAndKeys:
                                             _phoneNumberClickedInMessage,
                                             @"to",
                                             _accessor.model.called,
                                             @"from",
                                             nil]
                                   animated:YES];            
        } else if (buttonIndex == ([actionSheet firstOtherButtonIndex] + 1)) {
            VBXNavigationController *controller = (VBXNavigationController *)self.navigationController;
            [controller showSendTextWithState:[NSDictionary dictionaryWithObjectsAndKeys:
                                               _phoneNumberClickedInMessage,
                                               @"to",
                                               _accessor.model.called,
                                               @"from",                                               
                                               nil]
                                     animated:YES];
        }
    }
}

- (void)didClickPhoneNumberInTranscription:(NSString *)phoneNumber {
    
    NSString *formattedNumber = VBXFormatPhoneNumber(phoneNumber);
    
    NSString *callText = [NSString stringWithFormat:LocalizedString(@"Call %@", @"Message Detail: Title for Call button when phone number link is clicked in the message."), formattedNumber];
    NSString *smsText = [NSString stringWithFormat:LocalizedString(@"SMS %@", @"Message Detail: Title for SMS button when phone number link is clicked in the message."), formattedNumber];    
    
    UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:nil 
                                                              delegate:self
                                                     cancelButtonTitle:LocalizedString(@"Cancel", nil)
                                                destructiveButtonTitle:nil
                                                     otherButtonTitles:callText, smsText, nil]
                                  autorelease];
    actionSheet.tag = kSheetTagContactFromLinkInTranscription;
    [actionSheet showFromToolbar:self.navigationController.toolbar];
    
    [_phoneNumberClickedInMessage release];
    _phoneNumberClickedInMessage = [formattedNumber retain];
}

#pragma mark Adding annotations

- (VBXTextEntryController *)addNoteController {
    VBXTextEntryController *controller = [_builder textEntryController];
    controller.target = self;
    controller.navTitle = LocalizedString(@"Add Note", @"Message Detail: Title for add note button");
    controller.initialText = _newNoteText;
    return controller;
}

- (void)textEntryControllerFinishedWithText:(NSString *)text {
    [self setPromptAndDimView:LocalizedString(@"Saving note...", @"Message Detail: Navigation bar prompt that shows while a note is being added.")];
    [self disableControls];
    [self.navigationItem setHidesBackButton:YES animated:YES];
    
    self.newNoteText = text;
    [_accessor addNote:text];
}

- (void)accessor:(VBXMessageDetailAccessor *)a didAddNote:(VBXAnnotation *)annotation {
    self.newNoteText = nil;
    [self enableControls];
    [self.navigationItem setHidesBackButton:NO animated:YES];
    

    [self rebuildSections];
    [self unsetPromptAndUndim];
}

- (void)accessor:(VBXMessageDetailAccessor *)accessor addNoteDidFailWithError:(NSError *)error {
    debug(@"%@", [error detailedDescription]);
    [self unsetPromptAndUndim];
    [self enableControls];
    [UIAlertView showAlertViewWithTitle:LocalizedString(@"Could not add note", @"Message Detail: Message shown when we failed to add a note.") forError:error];
}

#pragma mark Table view methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:[MessageAttributeCell class]]) {
        MessageAttributeCell *attributeCell = (MessageAttributeCell *)cell;
        VBXMessageAttributeController *controller = [_builder messageAttributeControllerForAttribute:attributeCell.attribute];
        controller.navigationItem.title = attributeCell.attribute.name;
        [[self navigationController] pushViewController:controller animated:YES];
    } else if (cell == _addNoteCell) {
        [self presentModalViewController:[self addNoteController] animated:YES];
    } else if (cell == _loadMoreCell) {
        [self loadMoreAnnotations];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark State save and restore

- (NSDictionary *)saveState {
    NSMutableDictionary *state = [NSMutableDictionary dictionary];
    
    if (_newNoteText) [state setObject:_newNoteText forKey:@"newNoteText"];
    
    UIViewController *modalController = [self modalViewController];
    if ([modalController isKindOfClass:[VBXTextEntryController class]]) {
        VBXTextEntryController *textEntryController = (VBXTextEntryController *)modalController;
        if (textEntryController.target == self) {
            [state setObject:[textEntryController saveState] forKey:@"addNoteState"];
        }
    } else {
        VBXNavigationController *navController = (VBXNavigationController *)self.navigationController;
        
        [state setBool:navController.dialerIsShown forKey:@"dialerIsShown"];
        [state setBool:navController.sendTextIsShown forKey:@"sendTextIsShown"];
        
        if (navController.dialerIsShown) {
            [state setObject:[navController.dialerController saveState] forKey:@"dialerState"];
        } else if (navController.sendTextIsShown) {
            [state setObject:[navController.sendTextController saveState] forKey:@"sendTextState"];
        }
    }

    
    return state;
}

- (void)restoreState:(NSDictionary *)state {
    self.newNoteText = [state stringForKey:@"newNoteText"];
    
    if ([state containsKey:@"addNoteState"]) {
        VBXTextEntryController *addNoteController = [self addNoteController];
        [addNoteController restoreState:[state objectForKey:@"addNoteState"]];
        [self presentModalViewController:addNoteController animated:NO];
    }
    
    if ([state boolForKey:@"dialerIsShown"]) {
        VBXNavigationController *navController = (VBXNavigationController *)self.navigationController;
        [navController showDialerWithState:[state objectForKey:@"dialerState"] animated:NO];
    } else if ([state boolForKey:@"sendTextIsShown"]) {
        VBXNavigationController *navController = (VBXNavigationController *)self.navigationController;
        [navController showSendTextWithState:[state objectForKey:@"sendTextState"] animated:NO];
    }
}

@end
