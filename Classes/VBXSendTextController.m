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

#import "VBXSendTextController.h"
#import "VBXSectionedDataSource.h"
#import "VBXObjectBuilder.h"
#import "VBXCallerIdController.h"
#import "UIViewPositioningExtension.h"
#import "VBXViewCell.h"
#import "VBXGlobal.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import "VBXUserDefaultsKeys.h"
#import "VBXResourceRequest.h"
#import "VBXResourceLoader.h"
#import "UIExtensions.h"
#import "VBXConfiguration.h"
#import "VBXError.h"

@interface RemainingCharsView : UIView <VBXConfigurable> {
    NSInteger _number;
    UIColor *_color;
    UIColor *_selectedColor;
    BOOL _selected;
}

@property (nonatomic, assign) NSInteger number;
@property (nonatomic, retain) UIColor *color;
@property (nonatomic, retain) UIColor *selectedColor;

@end

@implementation RemainingCharsView

@synthesize number = _number;
@synthesize color = _color;
@synthesize selectedColor = _selectedColor;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.number = 0;
        self.backgroundColor = [UIColor clearColor];
        
        [[VBXConfiguration sharedConfiguration] addConfigObserver:self];
        [self applyConfig];
    }
    return self;
}

- (void)dealloc {
    [[VBXConfiguration sharedConfiguration] removeConfigObserver:self];
    [super dealloc];
}

- (void)applyConfig {
    self.color = ThemedColor(@"sendTextRemainingCharsBackgroundColor", [UIColor lightGrayColor]);
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();

    [_color set];
    
    CGContextAddRoundedRect(context, rect, 10);
    CGContextFillPath(context);
    
    [[UIColor blackColor] set];
    
    // By setting our blend mode to clear, we're just clearing these pixels
    CGContextSetBlendMode(context, kCGBlendModeClear);
    
    rect.origin.y += 1;
    [[NSString stringWithFormat:@"%d", _number] drawInRect:rect
                                                  withFont:[UIFont boldSystemFontOfSize:14.0] 
                                             lineBreakMode:UILineBreakModeMiddleTruncation 
                                                 alignment:UITextAlignmentCenter];
}

- (void)setColor:(UIColor *)color {
    if (_color != color) {
        [_color release];
        _color = [color retain];
        
        [self setNeedsDisplay];
    }
}

- (void)setNumber:(NSInteger)number {
    _number = number;
    [self setNeedsDisplay];
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize fitSize = [[NSString stringWithFormat:@"%d", _number] sizeWithFont:[UIFont boldSystemFontOfSize:14.0]];
    
    return CGSizeMake(MAX(30, fitSize.width + 16), 20);
}

@end


@interface BodyCell : UITableViewCell <VBXVariableHeightCell, UIScrollViewDelegate, VBXConfigurable> {
    UITextView *_bodyTextView;
    UIImageView *_shadowView;
    RemainingCharsView *_remainingCharsView;
}

@property (nonatomic, readonly) UITextView *bodyTextView;
@property (nonatomic, readonly) RemainingCharsView *remainingCharsView;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifer;

@end

@implementation BodyCell

@synthesize bodyTextView = _bodyTextView;
@synthesize remainingCharsView = _remainingCharsView;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifer {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifer]) {
        // The height is just tall enough to bring us down to the top of the keyboard
        _bodyTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 320, 120)];
        _bodyTextView.keyboardType = UIKeyboardTypeDefault;
        _bodyTextView.autocorrectionType = UITextAutocorrectionTypeYes;
        _bodyTextView.autocapitalizationType = UITextAutocapitalizationTypeSentences;            
        _bodyTextView.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:_bodyTextView];
        
        _shadowView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shadow.png"]] autorelease];
        [self.contentView addSubview:_shadowView];
        _shadowView.left = 0;
        _shadowView.top = 0;
        
        _remainingCharsView = [[[RemainingCharsView alloc] initWithFrame:CGRectZero] autorelease];
        _remainingCharsView.number = 160;
        [self.contentView addSubview:_remainingCharsView];        
        [_remainingCharsView sizeToFit];
        _remainingCharsView.right = 315;
        _remainingCharsView.bottom = 115;
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self applyConfig];
        [[VBXConfiguration sharedConfiguration] addConfigObserver:self];
    }
    return self;
}

- (void)dealloc {
    [[VBXConfiguration sharedConfiguration] removeConfigObserver:self];    
    [super dealloc];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (CGFloat)heightForCell {
    // Be tall enough to get us down to the edge of the screen.
    return _bodyTextView.height + KEYBOARD_HEIGHT;
}

- (void)applyConfig {
    UIView *bgView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    bgView.backgroundColor = ThemedColor(@"sendTextBodyBackgroundColor", [UIColor whiteColor]);
    [self setBackgroundView:bgView];

    _bodyTextView.backgroundColor = self.contentView.backgroundColor;
    _bodyTextView.textColor = ThemedColor(@"sendTextBodyTextColor", [UIColor blackColor]);
}

@end


@interface ToCell : UITableViewCell <VBXVariableHeightCell, VBXConfigurable> {
    UILabel *_label;
    UITextField *_textField;
}

@property (nonatomic, readonly) UILabel *label;
@property (nonatomic, readonly) UITextField *textField;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifer;

@end

@implementation ToCell

@synthesize label = _label;
@synthesize textField = _textField;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifer {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifer]) {
        _label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        _label.backgroundColor = [UIColor clearColor];
        _label.text = LocalizedString(@"To:", @"Send Text: Label for the To: field.");
        _label.font = [UIFont systemFontOfSize:15.0];        
        _label.numberOfLines = 1;
        _label.lineBreakMode = UILineBreakModeTailTruncation;
        
        _textField = [[[UITextField alloc] initWithFrame:CGRectZero] autorelease];
        _textField.font = [UIFont systemFontOfSize:15.0];
        _textField.textAlignment = UITextAlignmentLeft;
        _textField.borderStyle = UITextBorderStyleNone;
        _textField.keyboardType = UIKeyboardTypePhonePad;
        _textField.backgroundColor = [UIColor clearColor];
        _textField.text = @"";
        
        [self.contentView addSubview:_label];
        [self.contentView addSubview:_textField];
  
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        
        [self applyConfig];
        [[VBXConfiguration sharedConfiguration] addConfigObserver:self];
    }
    return self;
}

- (void)dealloc {
    [[VBXConfiguration sharedConfiguration] removeConfigObserver:self];    
    [super dealloc];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_label sizeToFit];
        
    _label.left = 8;
    _label.top = 10;
        
    [_textField sizeToFit];
    _textField.left = _label.right + 10;
    _textField.top = 10;
    _textField.width = self.contentView.width - _textField.left - _label.left;
    _textField.height = 20;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    // We don't draw a selected background.
    
    if (selected) {
        [_textField becomeFirstResponder];
    }
    
    [super setSelected:NO animated:animated];
}

- (CGFloat)heightForCell {
    return 40;
}

- (void)applyConfig {
    UIView *bgView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    bgView.backgroundColor = ThemedColor(@"sendTextToBackgroundColor", [UIColor whiteColor]);
    [self setBackgroundView:bgView];

    _label.textColor = ThemedColor(@"sendTextToLabelTextColor", [UIColor darkGrayColor]);
    _textField.textColor = ThemedColor(@"sendTextToNumberTextColor", [UIColor blackColor]);
}

@end

@interface CallerIdCell : UITableViewCell <VBXVariableHeightCell, VBXConfigurable> {
    UILabel *_label;
    UILabel *_valueField;
}

@property (nonatomic, readonly) UILabel *label;
@property (nonatomic, readonly) UILabel *valueField;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifer;

@end

@implementation CallerIdCell

@synthesize label = _label;
@synthesize valueField = _valueField;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifer {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifer]) {
        _label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        _label.backgroundColor = [UIColor clearColor];
        _label.text = LocalizedString(@"From:", @"Send Text: Label for the From: field.");
        _label.font = [UIFont systemFontOfSize:15.0];
        _label.numberOfLines = 1;
        _label.lineBreakMode = UILineBreakModeTailTruncation;
        
        _valueField = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        _valueField.font = [UIFont systemFontOfSize:15.0];
        _valueField.textAlignment = UITextAlignmentLeft;
        _valueField.text = @"";
        _valueField.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:_label];
        [self.contentView addSubview:_valueField];
        
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        [self applyConfig];
        [[VBXConfiguration sharedConfiguration] addConfigObserver:self];
    }
    return self;
}

- (void)dealloc {
    [[VBXConfiguration sharedConfiguration] removeConfigObserver:self];    
    [super dealloc];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_label sizeToFit];
    
    _label.left = 8;
    _label.top = 10;
    
    [_valueField sizeToFit];
    _valueField.left = _label.right + 10;
    _valueField.top = 10;
    _valueField.width = self.contentView.width - _valueField.left - _label.left;
    _valueField.height = 20;
}

- (CGFloat)heightForCell {
    return 40;
}

- (void)applyConfig {
    UIView *bgView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    bgView.backgroundColor = ThemedColor(@"sendTextFromBackgroundColor", [UIColor whiteColor]);
    [self setBackgroundView:bgView];

    _valueField.textColor = ThemedColor(@"sendTextFromNumberTextColor", [UIColor blackColor]);
    _valueField.highlightedTextColor = ThemedColor(@"sendTextFromNumberHighlightedTextColor", [UIColor whiteColor]);    
    _label.textColor = ThemedColor(@"sendTextFromLabelTextColor", [UIColor darkGrayColor]);
    _label.highlightedTextColor = ThemedColor(@"sendTextFromLabelHighlightedTextColor", [UIColor whiteColor]);
}

@end



@interface VBXSendTextController (Private) <UITextViewDelegate, UITextFieldDelegate, ABPeoplePickerNavigationControllerDelegate>
@end

@implementation VBXSendTextController

@synthesize userDefaults = _userDefaults;
@synthesize sendTextPoster = _sendTextPoster;

- (void)cancel {
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)send {    
    NSString *toNumber = VBXStripNonDigitsFromString(_toCell.textField.text);
    NSString *fromNumber = VBXStripNonDigitsFromString(_callerIdCell.valueField.text);
    NSString *body = _bodyCell.bodyTextView.text;
    
    if (toNumber.length > 0 && toNumber.length != 10 && ![[toNumber substringToIndex:1] isEqualToString:@"+"]) {    
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Invalid To: Number", @"Send Text: Title for alert when to: number isn't 10 digits long")
                                                        message:LocalizedString(@"The phone number in the To: field must be a valid 10 digit phone number.", @"Send Text: Body for alert when to: number isn't 10 digits long.")
                                                       delegate:nil 
                                              cancelButtonTitle:LocalizedString(@"OK", nil) 
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    } else if (fromNumber.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Empty From: Number", @"Send Text: Title for alert when From: number is empty")
                                                        message:LocalizedString(@"You must pick a number to SMS from.", @"Send Text: Body for alert when from: number is empty.")
                                                       delegate:nil 
                                              cancelButtonTitle:LocalizedString(@"OK", nil) 
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    } else if (body.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Empty Message", @"Send Text: Title for alert when message is empty.")
                                                        message:LocalizedString(@"You must enter at least something to send.", @"Send Text: Body for alert when message is empty.")
                                                       delegate:nil 
                                              cancelButtonTitle:LocalizedString(@"OK", nil) 
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];        
    } else {
        [self setPromptAndDimView:LocalizedString(@"Sending message...", @"Send Text: Navigation bar prompt shown when message is sending.")];
        self.navigationItem.leftBarButtonItem.enabled = NO;
        self.navigationItem.rightBarButtonItem.enabled = NO;    
        
        VBXResourceRequest *request = [VBXResourceRequest requestWithResource:@"messages/sms" method:@"POST"];
        [request.params setObject:_toCell.textField.text forKey:@"to"];
        [request.params setObject:_callerIdCell.valueField.text forKey:@"from"];
        [request.params setObject:_bodyCell.bodyTextView.text forKey:@"content"];
        
        [_sendTextPoster setTarget:self successAction:@selector(loader:didSendText:)
                       errorAction:@selector(loader:sendTextWithError:)];
        [_sendTextPoster loadRequest:request];        
    }
}

- (void)dismissAfterDelay {
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)loader:(VBXResourceLoader *)loader didSendText:(NSDictionary *)response {
    self.navigationItem.prompt = LocalizedString(@"Message sent!", @"Send Text: Navigation bar prompt shown when message is successfully sent.");
    
    [self performSelector:@selector(dismissAfterDelay) withObject:nil afterDelay:1.5];
}

- (void)loader:(VBXResourceLoader *)loader sendTextWithError:(NSError *)error {
    [self unsetPromptAndUndim];
    self.navigationItem.leftBarButtonItem.enabled = YES;
    self.navigationItem.rightBarButtonItem.enabled = YES;    
    
    NSString *title = LocalizedString(@"Message could not be sent.", @"Send Text: Title of failure alert view.");
    NSString *description = [[error userInfo] objectForKey:VBXErrorServerErrorMessageKey];
    
    [UIAlertView showAlertViewWithTitle:title message:description];
}

- (id)initWithPhone:(NSString *)phone {
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        self.title = LocalizedString(@"New Text", @"Send Text: Title for screen.");
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                                                                              target:self 
                                                                                              action:@selector(cancel)];
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:LocalizedString(@"Send", @"Send Text: Label for send button in nav bar.")
                                                                                  style:UIBarButtonItemStylePlain 
                                                                                 target:self 
                                                                                 action:@selector(send)];
        self.navigationItem.rightBarButtonItem.enabled = YES;
        
        // This doesn't get us what we want on this screen.
        self.autoRefocusOnSelectedCell = NO;        
        
        _initialPhoneNumber = [phone retain];
        
        // We don't want the back button for our screen to take up too much space
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:LocalizedString(@"Back", nil)
                                                                                  style:UIBarButtonItemStyleBordered 
                                                                                 target:nil 
                                                                                 action:nil] autorelease];
    }
    return self;
}

- (void)dealloc {
    [_initialPhoneNumber release];
    [_dataSource release];
    [super dealloc];
}

- (void)loadView {
    [super loadView];
    
    _callerIdCell = [[[CallerIdCell alloc] initWithReuseIdentifier:nil] autorelease];     
    _toCell = [[[ToCell alloc] initWithReuseIdentifier:nil] autorelease];
    _toCell.textField.delegate = self;
    _toCell.textField.text = _initialPhoneNumber;
    
    _bodyCell = [[[BodyCell alloc] initWithReuseIdentifier:nil] autorelease];
    _bodyCell.bodyTextView.delegate = self;
    
    _dataSource = [VBXSectionedCellDataSource dataSourceWithHeadersCellsAndFooters:
                   @"", // empty header
                   _callerIdCell,
                   _toCell,
                   _bodyCell,
                   @"", // empty footer
                   nil];
    [_dataSource retain];
    _dataSource.proxyToDelegate = self;
    
    self.tableView.delegate = _dataSource;
    self.tableView.dataSource = _dataSource;
    self.tableView.tableFooterView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    self.tableView.scrollEnabled = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [_toCell.textField becomeFirstResponder];
    
    // Default to whatever our last used caller id was...
    _callerIdCell.valueField.text = [_userDefaults stringForKey:VBXUserDefaultsCallerId];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];    
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:YES];
    
    if (_callerIdPickerIsOpen) {
        _callerIdPickerIsOpen = NO;
        _callerIdCell.valueField.text = [_userDefaults stringForKey:VBXUserDefaultsCallerId];
    }
    
    // Focus on the body if the to field is already populated.
    if (_toCell.textField.text.length > 0) {
        [_bodyCell.bodyTextView becomeFirstResponder];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell == _toCell) {
        ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
        picker.peoplePickerDelegate = self;
        picker.displayedProperties = [NSArray arrayWithObject:[NSNumber numberWithInt:kABPersonPhoneProperty]];
        [self.navigationController presentModalViewController:picker animated:YES];
        [picker release];        
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell == _callerIdCell) {
        VBXObjectBuilder *builder = [VBXObjectBuilder sharedBuilder];
        [self.navigationController pushViewController:[builder callerIdController] animated:YES];
        _callerIdPickerIsOpen = YES;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (textView.text.length >= 160 && range.length == 0) {
        // that's it!
        return NO;
    } else {
        return YES;
    }    
}

- (void)textViewDidChange:(UITextView *)textView {
    static CGFloat lastHeight = CGFLOAT_MIN;
    
    if (lastHeight != CGFLOAT_MIN && textView.contentSize.height != lastHeight) {
        [textView flashScrollIndicators];
    }
    
    lastHeight = textView.contentSize.height;
    
    _bodyCell.remainingCharsView.number = (160 - textView.text.length);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {    
    NSString *newString = VBXFormatPhoneNumber([textField.text stringByReplacingCharactersInRange:range withString:string]);
    
    if (VBXStripNonDigitsFromString(newString).length <= 10) {
        [textField setText:newString];
    }
    
    return NO;
}

- (void)textFieldDidChange:(UITextField *)textField {
}

#pragma mark PeoplePicker delegate methods

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
    [self.navigationController dismissModalViewControllerAnimated:YES];
}


- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    
    // We return YES so the details on this person is displayed.
    return YES;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier {
    
    ABMultiValueRef phoneProperty = ABRecordCopyValue(person, property);
	NSString *phone = (NSString *)ABMultiValueCopyValueAtIndex(phoneProperty, identifier);	
    
    _toCell.textField.text = VBXStripNonDigitsFromString(phone);
    
    [self.navigationController dismissModalViewControllerAnimated:YES];
    
    // Don't do the default action - we'll handle closing the picker
    return NO;
}

- (NSDictionary *)saveState {
    NSMutableDictionary *state = [NSMutableDictionary dictionary];
    [state setValue:_toCell.textField.text forKey:@"to"];
    [state setValue:_callerIdCell.valueField.text forKey:@"from"];
    [state setValue:_bodyCell.bodyTextView.text forKey:@"body"];
    return state;
}

- (void)restoreState:(NSDictionary *)state {
    // Make our view load early
    [self view];
    
    NSString *toValue = [state objectForKey:@"to"];
    NSString *fromValue = [state objectForKey:@"from"];
    NSString *bodyValue = [state objectForKey:@"body"];
    
    if (toValue) {
        _toCell.textField.text = toValue;
    }
    
    if (fromValue) {
        _callerIdCell.valueField.text = fromValue;
    }
    
    if (bodyValue) {
        _bodyCell.bodyTextView.text = bodyValue;
    }
}

@end
