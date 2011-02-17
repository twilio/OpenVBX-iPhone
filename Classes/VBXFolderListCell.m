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

#import "VBXFolderListCell.h"
#import "UIViewPositioningExtension.h"
#import "VBXFolderSummary.h"
#import "VBXMaskedImageView.h"
#import "VBXConfiguration.h"
#import "VBXGlobal.h"

@interface RoundedNumberView : UIView <VBXConfigurable> {
    NSInteger _number;
    UIColor *_color;
    UIColor *_selectedColor;
    BOOL _selected;
}

@property (nonatomic, assign) NSInteger number;
@property (nonatomic, retain) UIColor *color;
@property (nonatomic, retain) UIColor *selectedColor;

@end

@implementation RoundedNumberView

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
    self.color = ThemedColor(@"folderListUnreadCountColor", RGBHEXCOLOR(0x8b98b3));
    self.selectedColor = ThemedColor(@"folderListUnreadCountHighlightedColor", [UIColor whiteColor]);
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (_selected) {
        [_selectedColor set];
    } else {
        [_color set];
    }
    
    CGContextAddRoundedRect(context, rect, 10);
    CGContextFillPath(context);
    
    [[UIColor blackColor] set];

    // By setting our blend mode to clear, we're just clearing these pixels
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[NSString stringWithFormat:@"%d", _number] drawInRect:rect 
                 withFont:[UIFont boldSystemFontOfSize:16.0] 
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

- (void)setSelectedColor:(UIColor *)color {
    if (_selectedColor != color) {
        [_selectedColor release];
        _selectedColor = [color retain];
        
        [self setNeedsDisplay];
    }
}

- (void)setNumber:(NSInteger)number {
    _number = number;
    [self setNeedsDisplay];
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize fitSize = [[NSString stringWithFormat:@"%d", _number] sizeWithFont:[UIFont boldSystemFontOfSize:16.0]];
    
    return CGSizeMake(MAX(30, fitSize.width + 16), 20);
}

- (void)setSelected:(BOOL)selected {
    _selected = selected;
    [self setNeedsDisplay];
}

@end

@interface VBXFolderListCell (Private) <VBXConfigurable>
@end


@implementation VBXFolderListCell

@synthesize label = _label;
@synthesize icon = _icon;
@synthesize configuration = _configuration;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        _label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        _label.font = [UIFont boldSystemFontOfSize:19.0];
        _label.textColor = [UIColor blackColor];
        _label.numberOfLines = 1;
        _label.lineBreakMode = UILineBreakModeTailTruncation;
        _label.textAlignment = UITextAlignmentLeft;
        _label.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_label];
        
        _icon = [[[VBXMaskedImageView alloc] initWithFrame:CGRectZero] autorelease];
        _icon.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_icon];
        
        _numberView = [[[RoundedNumberView alloc] initWithFrame:CGRectZero] autorelease];
        [self.contentView addSubview:_numberView];
        
        self.selectionStyle = UITableViewCellSelectionStyleBlue;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        [self applyConfig];        
    }
    return self;
}

- (void)applyConfig {
    [super applyConfig];
    
    if (self.isSelected || self.isHighlighted) {
        _icon.startColor = _icon.endColor = ThemedColor(@"folderListIconHighlightedColor", ThemedColor(@"tableViewCellHighlightedTextColor", [UIColor whiteColor]));
        _label.textColor = [UIColor whiteColor];
    } else {
        _icon.startColor = _icon.endColor = ThemedColor(@"folderListIconColor", RGBHEXCOLOR(0x707070));
        _label.textColor = ThemedColor(@"primaryTextColor", [UIColor blackColor]);
    }
    
    [_icon setNeedsDisplay];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    [_numberView setSelected:highlighted];
    [self applyConfig];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [_numberView setSelected:selected];
    [self applyConfig];
}

- (void)dealloc {
    self.label = nil;
    self.icon = nil;
    [super dealloc];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize size = self.contentView.size;
    
    // Center images on this line
    const NSInteger iconCenterX = 29;
    
    // Start labels on this line
    const NSInteger labelOffsetX = 55;
    
    // Spacing between numbers and title
    const NSInteger numberSpacing = 5;
    
    _icon.left = round(iconCenterX - (_icon.width / 2));
    _icon.top = round((size.height / 2) - (_icon.height / 2));
    
    [_numberView sizeToFit];
    _numberView.right = 295;
    _numberView.top = round((size.height / 2) - (_numberView.height / 2));
    
    [_label sizeToFit];    
    _label.left = labelOffsetX;
    _label.width = (_numberView.left - numberSpacing - labelOffsetX);
    _label.top = round((size.height / 2) - (_label.height / 2));
}

- (void)showFolderSummary:(VBXFolderSummary *)folderSummary {
    _label.text = folderSummary.name;
    _number = folderSummary.new;
    _numberView.number = _number;
    _numberView.hidden = (_number == 0 ? YES : NO);
    
    if ([folderSummary.name isEqualToString:@"Inbox"]) {
        _icon.image = [UIImage imageNamed:@"inbox-icon-mask.png"];
    } else {
        _icon.image = [UIImage imageNamed:@"folder-icon-mask.png"];
    }
    [_icon sizeToFit];
    
    [self setNeedsLayout];    
    
    [self applyConfig];
}

@end
