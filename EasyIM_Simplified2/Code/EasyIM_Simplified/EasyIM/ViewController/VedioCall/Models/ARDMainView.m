/*
 *  Copyright 2015 The WebRTC Project Authors. All rights reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import "ARDMainView.h"

#import <WebRTCAvConf_iOS/WebRTCAvConf_iOS.h>

//#import "UIImage+ARDUtilities.h"

static CGFloat const kRoomTextFieldHeight = 40;
static CGFloat const kSubViewMargin = 8;

// Helper view that contains a text field and a clear button.
@interface ARDRoomTextField : UIView<UITextFieldDelegate>
@property(nonatomic, readonly) NSString* roomText;
@end

@implementation ARDRoomTextField {
    UITextField* _roomText;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _roomText = [[UITextField alloc] initWithFrame:CGRectZero];
        _roomText.borderStyle = UITextBorderStyleNone;
        _roomText.font = [UIFont systemFontOfSize:12];
        _roomText.placeholder = @"Room name";
        _roomText.autocorrectionType = UITextAutocorrectionTypeNo;
        _roomText.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _roomText.clearButtonMode = UITextFieldViewModeAlways;
        _roomText.delegate = self;
        [self addSubview:_roomText];

        _roomText.keyboardType = UIKeyboardTypeNumberPad;

        // Give rounded corners and a light gray border.
        self.layer.borderWidth = 1;
        self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        self.layer.cornerRadius = 2;
    }
    return self;
}

- (void)layoutSubviews {
    _roomText.frame =
        CGRectMake(kSubViewMargin, 0,
                   CGRectGetWidth(self.bounds) - kSubViewMargin,
                   kRoomTextFieldHeight);
}

- (CGSize)sizeThatFits:(CGSize)size {
    size.height = kRoomTextFieldHeight;
    return size;
}

- (NSString*)roomText {
    return _roomText.text;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    // There is no other control that can take focus, so manually resign focus
    // when return (Join) is pressed to trigger |textFieldDidEndEditing|.
    [textField resignFirstResponder];
    return YES;
}

@end

@implementation ARDMainView {
    ARDRoomTextField* _roomText;
    UIButton* _startRegularCallButton;
    UITableViewCell* _recordCell;
    UILabel* _version;
}

@synthesize delegate = _delegate;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _roomText = [[ARDRoomTextField alloc] initWithFrame:CGRectZero];
        [self addSubview:_roomText];

        UIFont* controlFont = [UIFont boldSystemFontOfSize:18.0];
        UIColor* controlFontColor = [UIColor whiteColor];

        _startRegularCallButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _startRegularCallButton.titleLabel.font = controlFont;
        [_startRegularCallButton setTitleColor:controlFontColor
                                      forState:UIControlStateNormal];
        _startRegularCallButton.backgroundColor =
            [UIColor colorWithRed:66.0 / 255.0
                            green:200.0 / 255.0
                             blue:90.0 / 255.0
                            alpha:1.0];
        [_startRegularCallButton setTitle:@"Video call"
                                 forState:UIControlStateNormal];
        [_startRegularCallButton addTarget:self
                                    action:@selector(onStartRegularCall:)
                          forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_startRegularCallButton];

        _recordCell = [[UITableViewCell alloc] initWithFrame:CGRectZero];
        _recordCell.selectionStyle = UITableViewCellSelectionStyleNone;
        UISwitch* recordSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        [recordSwitch addTarget:self
                       action:@selector(recordSwitchChanged:)
             forControlEvents:UIControlEventValueChanged];
        _recordCell.accessoryView = recordSwitch;
        _recordCell.textLabel.text = @"Record this call";
        [self addSubview:_recordCell];

        _version = [[UILabel alloc] initWithFrame:CGRectZero];
        _version.text =
            [NSString stringWithFormat:@"ver %@", CFAvConfShared_VERSION_NAME];
        _version.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_version];

        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)layoutSubviews {
    CGRect bounds = self.bounds;
    CGFloat roomTextWidth = bounds.size.width - 2 * kSubViewMargin;
    CGFloat roomTextHeight = [_roomText sizeThatFits:bounds.size].height;
    _roomText.frame = CGRectMake(kSubViewMargin, kSubViewMargin, roomTextWidth,
                                 roomTextHeight);

    CGFloat buttonHeight = 120;
    CGFloat buttonWidth = (bounds.size.width - 4 * kSubViewMargin) / 3;

    _startRegularCallButton.frame = CGRectMake(
        kSubViewMargin, CGRectGetMaxY(_roomText.frame) + kSubViewMargin,
        buttonWidth, buttonHeight);

    CGFloat switchHeight = 40;

    _recordCell.frame = CGRectMake(
        kSubViewMargin, CGRectGetMaxY(_startRegularCallButton.frame) + kSubViewMargin,
        bounds.size.width - 2 * kSubViewMargin, switchHeight);

    CGRect versionFrame =
        CGRectMake(kSubViewMargin, CGRectGetMaxY(_recordCell.frame) + 24,
                   bounds.size.width - 2 * kSubViewMargin, switchHeight);
    _version.frame = versionFrame;
}

#pragma mark - Private

- (void)onStartRegularCall:(id)sender {
    [_delegate mainView:self didInputRoom:_roomText.roomText];
}

- (void)recordSwitchChanged:(UISwitch *)sender {
    self.record = sender.isOn;
}

@end
