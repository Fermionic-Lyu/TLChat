//
//  TLVoiceMessageCell.m
//  TLChat
//
//  Created by 李伯坤 on 16/5/6.
//  Copyright © 2016年 李伯坤. All rights reserved.
//

#import "TLVoiceMessageCell.h"
#import "TLVoiceImageView.h"
#import <Masonry/Masonry.h>

//#define     MSG_SPACE_TOP       10
//#define     MSG_SPACE_BTM       10
//#define     MSG_SPACE_LEFT      15
//#define     MSG_SPACE_RIGHT     15

@interface TLVoiceMessageCell ()

@property (nonatomic, strong) UILabel *voiceTimeLabel;

@property (nonatomic, strong) TLVoiceImageView *voiceImageView;

@end

@implementation TLVoiceMessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.voiceTimeLabel];
        [self.messageBackgroundView addSubview:self.voiceImageView];
        
        UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapMsgBGView)];
        [self.messageBackgroundView addGestureRecognizer:tapGR];
    }
    return self;
}

- (void)setMessage:(TLVoiceMessage *)message
{
    TLMessageOwnerType lastOwnType = self.message ? self.message.ownerTyper : -1;
    [super setMessage:message];
    
    [self.voiceTimeLabel setText:[NSString stringWithFormat:@"%.0lf\"\n", message.time]];
    
    if (lastOwnType != message.ownerTyper) {
        if (message.ownerTyper == TLMessageOwnerTypeSelf) {
            [self.voiceImageView setIsFromMe:YES];
            [self.messageBackgroundView setBackgroundColor:[UIColor colorWithHexString:@"60DEDA"]];
            if (@available(iOS 11.0, *)) {
                [self.messageBackgroundView.layer setMaskedCorners:(kCALayerMaxXMaxYCorner|kCALayerMinXMinYCorner|kCALayerMinXMaxYCorner)];
            } else {
                // Fallback on earlier versions
            }
            
            [self.voiceTimeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(self.messageBackgroundView.mas_left).mas_offset(-3);
                make.top.mas_equalTo(self.messageBackgroundView.mas_centerY).mas_offset(-8);
            }];
            [self.voiceImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(-13);
                make.centerY.mas_equalTo(self.messageBackgroundView.mas_centerY);
            }];
        }
        else if (message.ownerTyper == TLMessageOwnerTypeFriend){
            [self.voiceImageView setIsFromMe:NO];
            [self.messageBackgroundView setBackgroundColor:[UIColor colorWithHexString:@"F5F5F0"]];
            if (@available(iOS 11.0, *)) {
                [self.messageBackgroundView.layer setMaskedCorners:(kCALayerMaxXMaxYCorner|kCALayerMaxXMinYCorner|kCALayerMinXMaxYCorner)];
            } else {
                // Fallback on earlier versions
            }
            
            [self.voiceTimeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.messageBackgroundView.mas_right).mas_offset(3);
                make.top.mas_equalTo(self.messageBackgroundView.mas_centerY).mas_offset(-8);
            }];
            [self.voiceImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(13);
                make.centerY.mas_equalTo(self.messageBackgroundView.mas_centerY);
            }];
        }
    }
    [self.messageBackgroundView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(message.messageFrame.contentSize.width, message.messageFrame.contentSize.height - 20.0f));
    }];
    
    if (message.msgStatus == TLVoiceMessageStatusRecording) {
        [self.voiceTimeLabel setHidden:YES];
        [self.voiceImageView setHidden:YES];
        [self p_startRecordingAnimation];
    }
    else {
        [self.voiceTimeLabel setHidden:NO];
        [self.voiceImageView setHidden:NO];
        [self p_stopRecordingAnimation];
        [self.messageBackgroundView setAlpha:1.0];
    }
    message.msgStatus == TLVoiceMessageStatusPlaying ? [self.voiceImageView startPlayingAnimation] : [self.voiceImageView stopPlayingAnimation];
}

- (void)updateMessage:(TLVoiceMessage *)message
{
    [super setMessage:message];
    
    [self.voiceTimeLabel setText:[NSString stringWithFormat:@"%.0lf\"\n", message.time]];
    if (message.msgStatus == TLVoiceMessageStatusRecording) {
        [self.voiceTimeLabel setHidden:YES];
        [self.voiceImageView setHidden:YES];
        [self p_startRecordingAnimation];
    }
    else {
        [self.voiceTimeLabel setHidden:NO];
        [self.voiceImageView setHidden:NO];
        [self p_stopRecordingAnimation];
    }
    message.msgStatus == TLVoiceMessageStatusPlaying ? [self.voiceImageView startPlayingAnimation] : [self.voiceImageView stopPlayingAnimation];

    [UIView animateWithDuration:0.5 animations:^{
        [self.messageBackgroundView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(message.messageFrame.contentSize.width, message.messageFrame.contentSize.height - 20.0f));
        }];
        [self layoutIfNeeded];
    }];
}

#pragma mark - # Event Response
- (void)didTapMsgBGView
{
    [self.voiceImageView startPlayingAnimation];
    if (self.delegate && [self.delegate respondsToSelector:@selector(messageCellTap:)]) {
        [self.delegate messageCellTap:self.message];
    }
}

#pragma mark - # Private Methods
static bool isStartAnimation = NO;
static float bgAlpha = 1.0;
- (void)p_startRecordingAnimation
{
    isStartAnimation = YES;
    bgAlpha = 0.4;
    [self p_repeatAnimation];
}

- (void)p_repeatAnimation
{
    [UIView animateWithDuration:1.0 animations:^{
        [self.messageBackgroundView setAlpha:bgAlpha];
    } completion:^(BOOL finished) {
        if (finished) {
            bgAlpha = bgAlpha > 0.9 ? 0.4 : 1.0;
            if (isStartAnimation) {
                [self p_repeatAnimation];
            }
            else {
                [self.messageBackgroundView setAlpha:1.0];
            }
        }
    }];
}

- (void)p_stopRecordingAnimation
{
    isStartAnimation = NO;
}


#pragma mark - # Getter
- (UILabel *)voiceTimeLabel
{
    if (_voiceTimeLabel == nil) {
        _voiceTimeLabel = [[UILabel alloc] init];
        [_voiceTimeLabel setTextColor:[UIColor grayColor]];
        [_voiceTimeLabel setFont:[UIFont systemFontOfSize:14.0f]];
    }
    return _voiceTimeLabel;
}

- (TLVoiceImageView *)voiceImageView
{
    if (_voiceImageView == nil) {
        _voiceImageView = [[TLVoiceImageView alloc] init];
    }
    return _voiceImageView;
}

@end
