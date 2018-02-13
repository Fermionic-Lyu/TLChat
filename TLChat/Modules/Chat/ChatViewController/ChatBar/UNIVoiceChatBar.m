//
//  UNIVoiceChatBar.m
//  UNI
//
//  Created by Can Lyu on 2018/2/12.
//  Copyright © 2018年 Mazoic Technologies Inc. All rights reserved.
//

#import "UNIVoiceChatBar.h"
#import "TLTalkButton.h"

#define UNIVoiceChatBarHeight 60.0f

@interface UNIVoiceChatBar ()

@property (strong, nonatomic) UIButton *keyboardButton;

@property (strong, nonatomic) TLTalkButton *talkButton;

@end

@implementation UNIVoiceChatBar

- (id)init {
    if (self = [super init]) {
        [self initView];
    }
    return self;
}

- (void)initView {
    [self setBackgroundColor:[UIColor whiteColor]];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.width, 0.5f)];
    [lineView setBackgroundColor:[UIColor colorWithHexString:@"C7C7CD"]];
    [self addSubview:lineView];
    
    [self addSubview:self.keyboardButton];
    [self addSubview:self.talkButton];
    
    [self p_addMasonry];
}

- (void)p_addMasonry {
    
    [self.keyboardButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).mas_offset(20.0f);
        make.left.mas_equalTo(self).mas_offset(20.0f);
        make.bottom.mas_equalTo(self).mas_offset(-20.0f - SAFEAREA_INSETS.bottom);
        make.height.mas_equalTo(20.0f);
        make.width.mas_equalTo(25.0f);
    }];
    
    [self.talkButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).mas_offset(10.0f);
        make.left.mas_equalTo(self.keyboardButton.mas_right).mas_offset(20.0f);
        make.right.mas_equalTo(self).mas_offset(-20.0f);
        make.height.mas_equalTo(40.0f);
    }];
}

- (UIButton *)keyboardButton {
    if (!_keyboardButton) {
        _keyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_keyboardButton setImage:[UIImage imageNamed:@"chat_toolbar_keyboard"] imageHL:[UIImage imageNamed:@"chat_toolbar_keyboard_HK"]];
        [_keyboardButton addTarget:self action:@selector(keyboardButtonDown:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _keyboardButton;
}

- (TLTalkButton *)talkButton
{
    if (_talkButton == nil) {
        _talkButton = [[TLTalkButton alloc] init];
        __weak typeof(self) weakSelf = self;
        [_talkButton setTouchBeginAction:^{
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(chatBarStartRecording:)]) {
                [weakSelf.delegate chatBarStartRecording:weakSelf];
            }
        } willTouchCancelAction:^(BOOL cancel) {
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(chatBarWillCancelRecording:cancel:)]) {
                [weakSelf.delegate chatBarWillCancelRecording:weakSelf cancel:cancel];
            }
        } touchEndAction:^{
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(chatBarFinishedRecoding:)]) {
                [weakSelf.delegate chatBarFinishedRecoding:weakSelf];
            }
        } touchCancelAction:^{
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(chatBarDidCancelRecording:)]) {
                [weakSelf.delegate chatBarDidCancelRecording:weakSelf];
            }
        }];
    }
    return _talkButton;
}

- (void)keyboardButtonDown:(UIButton *)button {
    [self.delegate returnToNormalChatBar];
}

- (void)showInView:(UIView *)view withAnimation:(BOOL)animation {
    if (_isShow) {
        return;
    }
    
    _isShow = YES;
    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.mas_equalTo(view);
        make.height.mas_equalTo(UNIVoiceChatBarHeight + SAFEAREA_INSETS.bottom);
        make.bottom.mas_equalTo(view).mas_offset(UNIVoiceChatBarHeight + SAFEAREA_INSETS.bottom);
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
                make.bottom.mas_equalTo(self.superview).mas_offset(UNIVoiceChatBarHeight + SAFEAREA_INSETS.bottom);
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
