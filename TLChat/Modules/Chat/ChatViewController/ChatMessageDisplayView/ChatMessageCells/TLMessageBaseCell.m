//
//  TLMessageBaseCell.m
//  TLChat
//
//  Created by 李伯坤 on 16/3/1.
//  Copyright © 2016年 李伯坤. All rights reserved.
//

#import "TLMessageBaseCell.h"
#import "NSDate+TLChat.h"
#import "NSFileManager+TLChat.h"
#import "TLMacros.h"

#define     TIMELABEL_HEIGHT    20.0f
#define     TIMELABEL_SPACE_Y   15.0f

#define     NAMELABEL_HEIGHT    14.0f
#define     NAMELABEL_SPACE_X   10.0f
#define     NAMELABEL_SPACE_Y   1.0f

#define     AVATAR_WIDTH        30.0f
#define     AVATAR_SPACE_X      20.0f
#define     AVATAR_SPACE_Y      12.0f

#define     MSGBG_SPACE_X       10.0f
#define     MSGBG_SPACE_Y       1.0f

@interface TLMessageBaseCell ()

@end

@implementation TLMessageBaseCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self.contentView addSubview:self.timeLabel];
        [self.contentView addSubview:self.avatarButton];
        [self.contentView addSubview:self.usernameLabel];
        [self.contentView addSubview:self.messageBackgroundView];
        [self.contentView addSubview:self.failureView];
        [self p_addMasonry];
    }
    return self;
}

- (void)setMessage:(TLMessage *)message
{    
    
//    if (_message && [_message.messageID isEqualToString:message.messageID]) {
//        return;
//    }
    message.showName = message.partnerType == TLPartnerTypeGroup && message.ownerTyper != TLMessageOwnerTypeSelf && message.ownerTyper != TLMessageOwnerTypeSystem;
    [self.timeLabel setText:[NSString stringWithFormat:@"  %@  ", message.date.chatTimeInfo]];
    [self.usernameLabel setText:[message.fromUser chat_username]];
    if ([message.fromUser chat_avatarPath].length > 0) {
        NSString *path = [NSFileManager pathUserAvatar:[message.fromUser chat_avatarPath]];
        [self.avatarButton setImage:[UIImage imageNamed:path] forState:UIControlStateNormal];
        
    }
    else if ([message.fromUser chat_avatarURL].length > 0) {
        [self.avatarButton tt_setImageWithURL:TLURL([message.fromUser chat_avatarURL]) forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"default_avatar"]];
    }else {
        [self.avatarButton setImage:[UIImage imageNamed:DEFAULT_AVATAR_PATH] forState:UIControlStateNormal];
    }
    
    // 时间
//    if (!_message || _message.showTime != message.showTime) {
        [self.timeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(message.showTime ? TIMELABEL_HEIGHT : 0);
            make.top.mas_equalTo(self.contentView).mas_offset(message.showTime ? TIMELABEL_SPACE_Y : 0);
        }];
//    }
    
//    if (!message || _message.ownerTyper != message.ownerTyper) {
        // 头像
        [self.avatarButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.and.height.mas_equalTo(AVATAR_WIDTH);
            make.top.mas_equalTo(self.timeLabel.mas_bottom).mas_offset(AVATAR_SPACE_Y);
            if(message.ownerTyper == TLMessageOwnerTypeSelf) {
                make.right.mas_equalTo(self.contentView).mas_offset(-AVATAR_SPACE_X);
            }
            else {
                make.left.mas_equalTo(self.contentView).mas_offset(AVATAR_SPACE_X);
            }
        }];
        
        // 用户名
        [self.usernameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.avatarButton).mas_equalTo(-NAMELABEL_SPACE_Y);
            if (message.ownerTyper == TLMessageOwnerTypeSelf) {
                make.right.mas_equalTo(self.avatarButton.mas_left).mas_offset(- NAMELABEL_SPACE_X);
            }
            else {
                make.left.mas_equalTo(self.avatarButton.mas_right).mas_equalTo(NAMELABEL_SPACE_X);
            }
            make.width.mas_lessThanOrEqualTo(250.0f);
        }];
        
        // 背景
        [self.messageBackgroundView mas_remakeConstraints:^(MASConstraintMaker *make) {
            message.ownerTyper == TLMessageOwnerTypeSelf ? make.right.mas_equalTo(self.avatarButton.mas_left).mas_offset(-MSGBG_SPACE_X) : make.left.mas_equalTo(self.avatarButton.mas_right).mas_offset(MSGBG_SPACE_X);
            make.top.mas_equalTo(self.usernameLabel.mas_bottom).mas_offset(message.showName ? 1 : -MSGBG_SPACE_Y);
        }];
        
        [self.failureView mas_remakeConstraints:^(MASConstraintMaker *make) {
            message.ownerTyper == TLMessageOwnerTypeSelf ? make.right.mas_equalTo(self.messageBackgroundView.mas_left).mas_offset(-5.0f) : make.left.mas_equalTo(self.messageBackgroundView.mas_right).mas_offset(5.0f);
            make.centerY.mas_equalTo(self.messageBackgroundView.mas_centerY);
            make.size.width.and.height.mas_equalTo(25.0f);
        }];
//    }
    
    [self.failureView setHidden:message.sendState != TLMessageSendFail];
    [self.usernameLabel setHidden:!message.showName];
    [self.usernameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(message.showName ? NAMELABEL_HEIGHT : 0);
    }];
    
    _message = message;
}

- (void)updateMessage:(TLMessage *)message
{
    [self setMessage:message];
}

- (void)updateSendStatus {
    [self.failureView setHidden:_message.sendState != TLMessageSendFail];
}

#pragma mark - Private Methods -
- (void)p_addMasonry
{
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).mas_offset(TIMELABEL_SPACE_Y);
        make.centerX.mas_equalTo(self.contentView);
    }];
    
    [self.usernameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.avatarButton).mas_equalTo(-NAMELABEL_SPACE_Y);
        make.right.mas_equalTo(self.avatarButton.mas_left).mas_offset(- NAMELABEL_SPACE_X);
    }];
    
    // Default - self
    [self.avatarButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView).mas_offset(-AVATAR_SPACE_X);
        make.width.and.height.mas_equalTo(AVATAR_WIDTH);
        make.top.mas_equalTo(self.timeLabel.mas_bottom).mas_offset(AVATAR_SPACE_Y);
    }];
    
    [self.messageBackgroundView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.avatarButton.mas_left).mas_offset(-MSGBG_SPACE_X);
        make.top.mas_equalTo(self.usernameLabel.mas_bottom).mas_offset(-MSGBG_SPACE_Y);
    }];
    
}

#pragma mark - Event Response -
- (void)avatarButtonDown:(UIButton *)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(messageCellDidClickAvatarForUser:)]) {
        [_delegate messageCellDidClickAvatarForUser:self.message.fromUser];
    }
}

- (void)longPressMsgBGView:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    [self.messageBackgroundView setHighlighted:YES];
    if (_delegate && [_delegate respondsToSelector:@selector(messageCellLongPress:rect:)]) {
        CGRect rect = self.messageBackgroundView.frame;
        rect.size.height -= 10;     // 北京图片底部空白区域
        [_delegate messageCellLongPress:self.message rect:rect];
    }
}

- (void)doubleTabpMsgBGView
{
    if (_delegate && [_delegate respondsToSelector:@selector(messageCellDoubleClick:)]) {
        [_delegate messageCellDoubleClick:self.message];
    }
}

#pragma mark - Getter -
- (UILabel *)timeLabel
{
    if (_timeLabel == nil) {
        _timeLabel = [[UILabel alloc] init];
        [_timeLabel setFont:[UIFont systemFontOfSize:12.0f]];
        [_timeLabel setTextColor:[UIColor colorWithHexString:@"9B9B9B"]];
        [_timeLabel setBackgroundColor:[UIColor clearColor]];
        [_timeLabel setAlpha:0.7f];
        [_timeLabel.layer setMasksToBounds:YES];
        [_timeLabel.layer setCornerRadius:5.0f];
    }
    return _timeLabel;
}

- (UIButton *)avatarButton
{
    if (_avatarButton == nil) {
        _avatarButton = [[UIButton alloc] init];
        //[_avatarButton.layer setMasksToBounds:YES];
        [_avatarButton setClipsToBounds:YES];
        [_avatarButton.layer setCornerRadius:AVATAR_WIDTH/2.0f];
        //[_avatarButton.layer setBorderWidth:BORDER_WIDTH_1PX];
        //[_avatarButton.layer setBorderColor:[UIColor colorWithWhite:0.7 alpha:1.0].CGColor];
        [_avatarButton.imageView setContentMode:UIViewContentModeScaleAspectFill];
        [_avatarButton addTarget:self action:@selector(avatarButtonDown:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _avatarButton;
}

- (UILabel *)usernameLabel
{
    if (_usernameLabel == nil) {
        _usernameLabel = [[UILabel alloc] init];
        [_usernameLabel setTextColor:[UIColor colorWithHexString:@"9B9B9B"]];
        [_usernameLabel setFont:[UIFont systemFontOfSize:11.0f]];
    }
    return _usernameLabel;
}

- (UIImageView *)messageBackgroundView
{
    if (_messageBackgroundView == nil) {
        _messageBackgroundView = [[UIImageView alloc] init];
        [_messageBackgroundView setClipsToBounds:YES];
        [_messageBackgroundView.layer setCornerRadius:10.0f];
        [_messageBackgroundView setUserInteractionEnabled:YES];
        
        UILongPressGestureRecognizer *longPressGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressMsgBGView:)];
        [_messageBackgroundView addGestureRecognizer:longPressGR];
        
        UITapGestureRecognizer *doubleTapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTabpMsgBGView)];
        [doubleTapGR setNumberOfTapsRequired:2];
        [_messageBackgroundView addGestureRecognizer:doubleTapGR];
    }
    return _messageBackgroundView;
}

- (UIImageView *)failureView {
    if (!_failureView) {
        _failureView = [[UIImageView alloc] init];
        [_failureView setImage:[UIImage imageNamed:@"failure"]];
    }
    return _failureView;
}

@end
