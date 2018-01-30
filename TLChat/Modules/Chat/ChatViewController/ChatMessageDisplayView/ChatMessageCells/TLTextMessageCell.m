//
//  TLTextMessageCell.m
//  TLChat
//
//  Created by 李伯坤 on 16/3/1.
//  Copyright © 2016年 李伯坤. All rights reserved.
//

#import "TLTextMessageCell.h"
#import <Masonry/Masonry.h>
#import "UIFont+TLChat.h"

#define     MSG_SPACE_TOP       10
#define     MSG_SPACE_BTM       10
#define     MSG_SPACE_LEFT      15
#define     MSG_SPACE_RIGHT     15

@interface TLTextMessageCell ()

@property (nonatomic, strong) UILabel *messageLabel;

@end

@implementation TLTextMessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.messageLabel];
    }
    return self;
}

- (void)setMessage:(TLTextMessage *)message
{
    if (message.ownerTyper == TLMessageOwnerTypeSystem) {
        [self.timeLabel setText:message.text];
        [self.messageLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        [self.avatarButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        [self.usernameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        [self.messageBackgroundView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        return;
    }
    
    if (self.message && [self.message.messageID isEqualToString:message.messageID]) {
        return;
    }

    [super setMessage:message];
    
    [self.messageLabel setAttributedText:[message attrText]];
    
    [self.messageLabel setContentCompressionResistancePriority:500 forAxis:UILayoutConstraintAxisHorizontal];
    [self.messageBackgroundView setContentCompressionResistancePriority:100 forAxis:UILayoutConstraintAxisHorizontal];
    
    
    switch (message.ownerTyper) {
        case TLMessageOwnerTypeSelf: {
            [self.messageBackgroundView setBackgroundColor:[UIColor colorWithHexString:@"60DEDA"]];
            if (@available(iOS 11.0, *)) {
                [self.messageBackgroundView.layer setMaskedCorners:(kCALayerMaxXMaxYCorner|kCALayerMinXMinYCorner|kCALayerMinXMaxYCorner)];
            } else {
                // Fallback on earlier versions
            }

            [self.messageLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(self.messageBackgroundView).mas_offset(-MSG_SPACE_RIGHT);
                make.top.mas_equalTo(self.messageBackgroundView).mas_offset(MSG_SPACE_TOP);
            }];
            [self.messageBackgroundView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.messageLabel).mas_offset(-MSG_SPACE_LEFT);
                make.bottom.mas_equalTo(self.messageLabel).mas_offset(MSG_SPACE_BTM);
            }];
            break;
        }
        case TLMessageOwnerTypeFriend: {
            [self.messageBackgroundView setBackgroundColor:[UIColor colorWithHexString:@"F5F5F0"]];
            if (@available(iOS 11.0, *)) {
                [self.messageBackgroundView.layer setMaskedCorners:(kCALayerMaxXMaxYCorner|kCALayerMaxXMinYCorner|kCALayerMinXMaxYCorner)];
            } else {
                // Fallback on earlier versions
            }
            [self.messageLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.messageBackgroundView).mas_offset(MSG_SPACE_LEFT);
                make.top.mas_equalTo(self.messageBackgroundView).mas_offset(MSG_SPACE_TOP);
            }];
            [self.messageBackgroundView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(self.messageLabel).mas_offset(MSG_SPACE_RIGHT);
                make.bottom.mas_equalTo(self.messageLabel).mas_offset(MSG_SPACE_BTM);
            }];
            break;
        }
        default:
            break;
    }
    
    [self.messageLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(message.messageFrame.contentSize);
    }];
}

#pragma mark - Getter -
- (UILabel *)messageLabel
{
    if (_messageLabel == nil) {
        _messageLabel = [[UILabel alloc] init];
        [_messageLabel setFont:[UIFont fontTextMessageText]];
        [_messageLabel setNumberOfLines:0];
    }
    return _messageLabel;
}

@end
