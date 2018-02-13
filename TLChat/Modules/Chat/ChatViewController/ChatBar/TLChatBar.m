//
//  TLChatBar.m
//  TLChat
//
//  Created by 李伯坤 on 16/2/15.
//  Copyright © 2016年 李伯坤. All rights reserved.
//

#import "TLChatBar.h"
#import "TLChatMacros.h"
#import "TLTalkButton.h"
#import "UIColor+TLChat.h"
#import <TLKit/TLKit.h>
#import "TLMacros.h"

@interface TLChatBar () <UITextViewDelegate>

@property (nonatomic, strong) UIButton *voiceButton;

@property (nonatomic, strong) UITextView *textView;

@property (nonatomic, strong) UIButton *galleryButton;

@property (nonatomic, strong) UIButton *cameraButton;

@property (nonatomic, strong) UIButton *sendButton;

@end

@implementation TLChatBar

- (id)init
{
    if (self = [super init]) {
        [self initView];
        self.status = TLChatBarStatusInit;
    }
    return self;
}

- (void)dealloc
{
#ifdef DEBUG_MEMERY
    NSLog(@"dealloc ChatBar");
#endif
}

- (void)initView {
    [self setBackgroundColor:[UIColor whiteColor]];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, 0.5f)];
    [lineView setBackgroundColor:[UIColor colorWithHexString:@"C7C7CD"]];
    [self addSubview:lineView];
    
    [self addSubview:self.textView];
    [self addSubview:self.galleryButton];
    [self addSubview:self.cameraButton];
    [self addSubview:self.voiceButton];
    [self addSubview:self.sendButton];
    
    [self p_addMasonry];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setNeedsDisplay];
}

#pragma mark - Public Methods
- (void)sendCurrentText
{
    if (self.textView.text.length > 0) {     // send Text
        if (_delegate && [_delegate respondsToSelector:@selector(chatBar:sendText:)]) {
            [_delegate chatBar:self sendText:self.textView.text];
        }
    }
    [self.sendButton setEnabled:NO];
    [self.textView setText:@""];
    [self p_reloadTextViewWithAnimation:YES];
}

- (void)addEmojiString:(NSString *)emojiString
{
    NSString *str = [NSString stringWithFormat:@"%@%@", self.textView.text, emojiString];
    [self.textView setText:str];
    [self p_reloadTextViewWithAnimation:YES];
}

- (void)deleteLastCharacter
{
    if([self textView:self.textView shouldChangeTextInRange:NSMakeRange(self.textView.text.length - 1, 1) replacementText:@""]){
        [self.textView deleteBackward];
    }
}

- (void)setActivity:(BOOL)activity
{
//    _activity = activity;
//    if (activity) {
//        [self.textView setTextColor:[UIColor blackColor]];
//    }
//    else {
//        [self.textView setTextColor:[UIColor grayColor]];
//    }
}

- (BOOL)isFirstResponder
{
    if (self.status == TLChatBarStatusEmoji || self.status == TLChatBarStatusKeyboard || self.status == TLChatBarStatusMore) {
        return YES;
    }
    return NO;
}

- (BOOL)resignFirstResponder
{
    if (self.status == TLChatBarStatusKeyboard) {
        [self.textView resignFirstResponder];
        self.status = TLChatBarStatusInit;
        if (self.delegate && [self.delegate respondsToSelector:@selector(chatBar:changeStatusFrom:to:)]) {
            [self.delegate chatBar:self changeStatusFrom:self.status to:TLChatBarStatusInit];
        }
    }
    
    return [super resignFirstResponder];
}

#pragma mark - Delegate -

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if (self.status != TLChatBarStatusKeyboard) {
        if (_delegate && [_delegate respondsToSelector:@selector(chatBar:changeStatusFrom:to:)]) {
            [self.delegate chatBar:self changeStatusFrom:self.status to:TLChatBarStatusKeyboard];
        }
        self.status = TLChatBarStatusKeyboard;
    }
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        [self setTextViewPlaceHolder];
    }
    [self p_reloadTextViewWithAnimation:YES];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:NSLocalizedString(@"TEXT_MESSAGE_PLACEHOLDER", nil)]) {
        [self.textView setText:@""];
        [self.textView setTextColor:[UIColor blackColor]];
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""] || [textView.text isEqualToString:NSLocalizedString(@"TEXT_MESSAGE_PLACEHOLDER", nil)]) {
        [self.sendButton setEnabled:NO];
    } else {
        [self.sendButton setEnabled:YES];
    }
    [self p_reloadTextViewWithAnimation:YES];
}

- (void)voiceButtonDown {
    [self.textView resignFirstResponder];
    [self.delegate didClickVoiceMessage:self];
}

#pragma mark - Private Methods
- (void)p_reloadTextViewWithAnimation:(BOOL)animation
{
    CGFloat textHeight = [self.textView sizeThatFits:CGSizeMake(self.textView.width, MAXFLOAT)].height;
    CGFloat height = textHeight > HEIGHT_CHATBAR_TEXTVIEW ? textHeight : HEIGHT_CHATBAR_TEXTVIEW;
    height = (textHeight <= HEIGHT_MAX_CHATBAR_TEXTVIEW ? textHeight : HEIGHT_MAX_CHATBAR_TEXTVIEW);
    [self.textView setScrollEnabled:textHeight > height];
    if (height != self.textView.height) {
        if (animation) {
            [UIView animateWithDuration:0.2 animations:^{
                [self.textView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(height);
                }];
                if (self.superview) {
                    [self.superview layoutIfNeeded];
                }
                if (self.delegate && [self.delegate respondsToSelector:@selector(chatBar:didChangeTextViewHeight:)]) {
                    [self.delegate chatBar:self didChangeTextViewHeight:self.textView.height];
                }
            } completion:^(BOOL finished) {
                if (textHeight > height) {
                    [self.textView setContentOffset:CGPointMake(0, textHeight - height) animated:YES];
                }
                if (self.delegate && [self.delegate respondsToSelector:@selector(chatBar:didChangeTextViewHeight:)]) {
                    [self.delegate chatBar:self didChangeTextViewHeight:height];
                }
            }];
        }
        else {
            [self.textView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(height);
            }];
            if (self.superview) {
                [self.superview layoutIfNeeded];
            }
            if (self.delegate && [self.delegate respondsToSelector:@selector(chatBar:didChangeTextViewHeight:)]) {
                [self.delegate chatBar:self didChangeTextViewHeight:height];
            }
            if (textHeight > height) {
                [self.textView setContentOffset:CGPointMake(0, textHeight - height) animated:YES];
            }
        }
    }
    else if (textHeight > height) {
        if (animation) {
            CGFloat offsetY = self.textView.contentSize.height - self.textView.height;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.textView setContentOffset:CGPointMake(0, offsetY) animated:YES];
            });
        }
        else {
            [self.textView setContentOffset:CGPointMake(0, self.textView.contentSize.height - self.textView.height) animated:NO];
        }
    }
}

- (void)p_addMasonry
{
    
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).mas_offset(10.0f);
        make.left.mas_equalTo(self).mas_offset(20.0f);
        make.right.mas_equalTo(self).mas_offset(-20.0f);
        make.height.mas_equalTo(HEIGHT_CHATBAR_TEXTVIEW);
    }];
    
    [self.galleryButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.textView.mas_bottom).mas_offset(20.0f);
        make.bottom.mas_equalTo(self).mas_offset(-15.0f - SAFEAREA_INSETS.bottom);
        make.left.mas_equalTo(self).mas_offset(20.0f);
        make.height.mas_equalTo(20.0f);
        make.width.mas_equalTo(25.0f);
    }];
    
    [self.cameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.textView.mas_bottom).mas_offset(20.0f);
        make.left.mas_equalTo(self.galleryButton.mas_right).mas_offset(25.0f);
        make.height.mas_equalTo(20.0f);
        make.width.mas_equalTo(25.0f);
    }];
    
    [self.voiceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.textView.mas_bottom).mas_offset(20.0f);
        make.left.mas_equalTo(self.cameraButton.mas_right).mas_offset(25.0f);
        make.height.mas_equalTo(20.0f);
        make.width.mas_equalTo(25.0f);
    }];
    
    [self.sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(20.0f);
        make.width.mas_equalTo(35.0f);
        make.right.mas_equalTo(self).mas_offset(-20.0f);
        make.bottom.mas_equalTo(self).mas_offset(-15.0f - SAFEAREA_INSETS.bottom);
    }];
}

- (UITextView *)textView
{
    if (_textView == nil) {
        _textView = [[UITextView alloc] init];
        [_textView setFont:[UIFont systemFontOfSize:16.0f]];
        [_textView setDelegate:self];
        [_textView setScrollsToTop:NO];
        [self setTextViewPlaceHolder];
    }
    return _textView;
}

- (void)setTextViewPlaceHolder {
    [self.textView setText:NSLocalizedString(@"TEXT_MESSAGE_PLACEHOLDER", nil)];
    [self.textView setTextColor:[UIColor lightGrayColor]];
}

- (UIButton *)galleryButton {
    if (!_galleryButton) {
        _galleryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_galleryButton setImage:[UIImage imageNamed:@"chat_toolbar_gallery"] imageHL:[UIImage imageNamed:@"chat_toolbar_gallery_HL"]];
        [_galleryButton addTarget:self action:@selector(chatBarButtonDown:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _galleryButton;
}

- (UIButton *)cameraButton {
    if (!_cameraButton) {
        _cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cameraButton setImage:[UIImage imageNamed:@"chat_toolbar_camera"] imageHL:[UIImage imageNamed:@"chat_toolbar_camera_HL"]];
        [_cameraButton addTarget:self action:@selector(chatBarButtonDown:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cameraButton;
}

- (UIButton *)voiceButton
{
    if (_voiceButton == nil) {
        _voiceButton = [[UIButton alloc] init];
        [_voiceButton setImage:[UIImage imageNamed:@"chat_toolbar_voice"] imageHL:[UIImage imageNamed:@"chat_toolbar_voice_HL"]];
        [_voiceButton addTarget:self action:@selector(voiceButtonDown) forControlEvents:UIControlEventTouchUpInside];
    }
    return _voiceButton;
}

- (UIButton *)sendButton {
    if (!_sendButton) {
        _sendButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_sendButton setAttributedTitle:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"SEND", nil) attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica-Bold" size:14.0f], NSForegroundColorAttributeName:kEmerald}] forState:UIControlStateNormal];
        [_sendButton setAttributedTitle:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"SEND", nil) attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica-Bold" size:14.0f], NSForegroundColorAttributeName:[UIColor colorWithHexString:@"EFEFF4"]}] forState:UIControlStateDisabled];
        [_sendButton addTarget:self action:@selector(sendCurrentText) forControlEvents:UIControlEventTouchUpInside];
        [_sendButton setEnabled:NO];
    }
    return _sendButton;
}


- (NSString *)curText
{
    return self.textView.text;
}


- (void)chatBarButtonDown:(UIButton *)button {
    if (button == self.galleryButton) {
        [self.delegate didClickGallery:self];
    } else if (button == self.cameraButton) {
        [self.delegate didClickCamera:self];
    }
}

- (void)showInView:(UIView *)view withAnimation:(BOOL)animation {
    if (_isShow) {
        return;
    }
    
    _isShow = YES;
    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(view);
        make.bottom.mas_equalTo(view).mas_offset(self.frame.size.height);
    }];
    [view layoutIfNeeded];
    
    if (animation) {
        [UIView animateWithDuration:0.3 animations:^{
            [self mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(view);
            }];
            [view layoutIfNeeded];
        } completion:^(BOOL finished) {
            
        }];
    } else {
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(view);
        }];
        [view layoutIfNeeded];
    }
}

- (void)dismissWithAnimation:(BOOL)animation withCompletionBlock:(void (^)())completionBlock {
    if (!_isShow) {
        if (!animation) {
            [self removeFromSuperview];
        }
        return;
    }
    _isShow = NO;
    if (animation) {
        [UIView animateWithDuration:0.3 animations:^{
            [self mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(self.superview).mas_offset(self.frame.size.height);
            }];
            [self.superview layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
            if (completionBlock) {
                completionBlock();
            }
        }];
    } else {
        [self removeFromSuperview];
        if (completionBlock) {
            completionBlock();
        }
    }
    
}

@end
