//
//  TLConversationCell.m
//  TLChat
//
//  Created by 李伯坤 on 16/1/23.
//  Copyright © 2016年 李伯坤. All rights reserved.
//

#import "TLConversationCell.h"
#import "NSDate+TLChat.h"
#import "TLMacros.h"
#import "NSFileManager+TLChat.h"
#import "TLGroupDataLoader.h"

#define     CONV_SPACE_X            15.0f
#define     CONV_SPACE_Y            9.5f
#define     REDPOINT_WIDTH          18.0f

@interface TLConversationCell()

@property (nonatomic, strong) UIImageView *avatarImageView;

@property (nonatomic, strong) UILabel *usernameLabel;

@property (nonatomic, strong) UILabel *detailLabel;

@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) UILabel *firstCharacterLabel;

@property (nonatomic, strong) UIImageView *remindImageView;

@property (nonatomic, strong) UIView *redPointView;

@property (nonatomic, strong) UILabel *unreadLabel;

@end

@implementation TLConversationCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.leftSeparatorSpace = CONV_SPACE_X;
        
        [self.contentView addSubview:self.avatarImageView];
        [self.avatarImageView addSubview:self.firstCharacterLabel];
        [self.contentView addSubview:self.usernameLabel];
        [self.contentView addSubview:self.detailLabel];
        [self.contentView addSubview:self.timeLabel];
        [self.contentView addSubview:self.remindImageView];
        [self.contentView addSubview:self.redPointView];
        
        [self p_addMasonry];
    }
    return self;
}

#pragma mark - Public Methods
- (void)setConversation:(TLConversation *)conversation
{
    _conversation = conversation;
    
    switch (conversation.convType) {
        case TLConversationTypePersonal:
            [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:conversation.avatarURL] placeholderImage:[UIImage imageNamed:@"default_avatar"]];
            [self.firstCharacterLabel setHidden:YES];
            break;
        case TLConversationTypeGroup:
            [self.avatarImageView setImage:[[TLGroupDataLoader sharedGroupDataLoader] generateGroupAvatarWithGroupName:conversation.partnerName]];
            [self.firstCharacterLabel setText:[conversation.partnerName substringToIndex:1]];
            [self.firstCharacterLabel setHidden:NO];
            break;
        default:
            break;
    }
    
    [self.usernameLabel setText:conversation.partnerName];
    [self.detailLabel setText:conversation.content];
    [self.timeLabel setText:conversation.date.conversaionTimeInfo];
    switch (conversation.remindType) {
        case TLMessageRemindTypeNormal:
            [self.remindImageView setHidden:YES];
            break;
        case TLMessageRemindTypeClosed:
            [self.remindImageView setHidden:NO];
            [self.remindImageView setImage:[UIImage imageNamed:@"conv_remind_close"]];
            break;
        case TLMessageRemindTypeNotLook:
            [self.remindImageView setHidden:NO];
            [self.remindImageView setImage:[UIImage imageNamed:@"conv_remind_notlock"]];
            break;
        case TLMessageRemindTypeUnlike:
            [self.remindImageView setHidden:NO];
            [self.remindImageView setImage:[UIImage imageNamed:@"conv_remind_unlike"]];
            break;
        default:
            break;
    }
    [self.unreadLabel setText:[NSString stringWithFormat:@"%ld",(long)conversation.unreadCount]];
    self.conversation.isRead ? [self markAsRead] : [self markAsUnread];
}


/**
 *  标记为未读
 */
- (void)markAsUnread
{
    if (_conversation) {
//        switch (_conversation.clueType) {
//            case TLClueTypePointWithNumber:
//
//                break;
//            case TLClueTypePoint:
                [self.redPointView setHidden:NO];
//                break;
//            case TLClueTypeNone:
//
//                break;
//            default:
//                break;
//        }
    }
}

/**
 *  标记为已读
 */
- (void)markAsRead
{
    if (_conversation) {
//        switch (_conversation.clueType) {
//            case TLClueTypePointWithNumber:
//
//                break;
//            case TLClueTypePoint:
                [self.redPointView setHidden:YES];
//                break;
//            case TLClueTypeNone:
//
//                break;
//            default:
//                break;
//        }
    }
}

#pragma mark - Private Methods -
- (void)p_addMasonry
{
//    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(CONV_SPACE_X);
//        make.top.mas_equalTo(CONV_SPACE_Y);
//        make.bottom.mas_equalTo(- CONV_SPACE_Y);
//        make.width.mas_equalTo(self.avatarImageView.mas_height);
//    }];
    
//    [self.usernameLabel setContentCompressionResistancePriority:100 forAxis:UILayoutConstraintAxisHorizontal];
//    [self.usernameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(self.avatarImageView.mas_right).mas_offset(CONV_SPACE_X);
//        make.top.mas_equalTo(self.avatarImageView).mas_offset(2.0);
//        make.right.mas_lessThanOrEqualTo(self.timeLabel.mas_left).mas_offset(-5);
//    }];
    
//    [self.detailLabel setContentCompressionResistancePriority:110 forAxis:UILayoutConstraintAxisHorizontal];
//    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.mas_equalTo(self.avatarImageView).mas_offset(-2.0);
//        make.left.mas_equalTo(self.usernameLabel);
//        make.right.mas_lessThanOrEqualTo(self.remindImageView.mas_left);
//    }];
    
    [self.timeLabel setContentCompressionResistancePriority:300 forAxis:UILayoutConstraintAxisHorizontal];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.usernameLabel);
        make.right.mas_equalTo(self.contentView).mas_offset(-CONV_SPACE_X);
    }];
    
    [self.remindImageView setContentCompressionResistancePriority:310 forAxis:UILayoutConstraintAxisHorizontal];
    [self.remindImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.timeLabel);
        make.centerY.mas_equalTo(self.detailLabel);
    }];
    
//    [self.redPointView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(self.usernameLabel.mas_right).mas_offset(3);
//        make.top.mas_equalTo(self.avatarImageView.top).mas_offset(-4);
//        make.width.and.height.mas_equalTo(REDPOINT_WIDTH);
//    }];
}

#pragma mark - Getter
- (UIImageView *)avatarImageView
{
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0f, 15.0f, 50.0f, 50.0f)];
        [_avatarImageView.layer setMasksToBounds:YES];
        [_avatarImageView.layer setCornerRadius:25.0f];
        [_avatarImageView setContentMode:UIViewContentModeScaleAspectFill];
    }
    return _avatarImageView;
}

- (UILabel *)firstCharacterLabel {
    if (!_firstCharacterLabel) {
        _firstCharacterLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 50.0f, 50.0f)];
        [_firstCharacterLabel setTextAlignment:NSTextAlignmentCenter];
        [_firstCharacterLabel setTextColor:[UIColor whiteColor]];
        [_firstCharacterLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:30.0f]];
    }
    return _firstCharacterLabel;
}

- (UILabel *)usernameLabel
{
    if (!_usernameLabel) {
        _usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(75.0f, 20.0f, [UIScreen mainScreen].bounds.size.width - 160.0f, 20.0f)];
        [_usernameLabel setFont:[UIFont fontWithName:@"Helvetica-Regular" size:16.0f]];
        [_usernameLabel setTextColor:[UIColor colorWithHexString:@"4A4A4A"]];
    }
    return _usernameLabel;
}

- (UILabel *)detailLabel
{
    if (_detailLabel == nil) {
        _detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(75.0f, 40.0f, [UIScreen mainScreen].bounds.size.width - 85.0f, 20.0f)];
        [_detailLabel setFont:[UIFont systemFontOfSize:13.0f]];
        [_detailLabel setTextColor:[UIColor colorWithHexString:@"9B9B9B"]];
    }
    return _detailLabel;
}

- (UILabel *)timeLabel
{
    if (_timeLabel == nil) {
        _timeLabel = [[UILabel alloc] init];
        [_timeLabel setFont:[UIFont fontConversationTime]];
        [_timeLabel setTextColor:[UIColor colorTextGray1]];
    }
    return _timeLabel;
}

- (UIImageView *)remindImageView
{
    if (_remindImageView == nil) {
        _remindImageView = [[UIImageView alloc] init];
        [_remindImageView setAlpha:0.4];
    }
    return _remindImageView;
}

- (UIView *)redPointView
{
    if (_redPointView == nil) {
        _redPointView = [[UIView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 38.0f, 41.0f, REDPOINT_WIDTH, REDPOINT_WIDTH)];
        [_redPointView setBackgroundColor:kEmerald];
        
        [_redPointView.layer setMasksToBounds:YES];
        [_redPointView.layer setCornerRadius:REDPOINT_WIDTH / 2.0];
        [_redPointView setHidden:YES];
        [_redPointView addSubview:self.unreadLabel];
    }
    return _redPointView;
}

- (UILabel *)unreadLabel {
    if (!_unreadLabel) {
        _unreadLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 18.0f, 18.0f)];
        [_unreadLabel setFont:[UIFont systemFontOfSize:12.0f]];
        [_unreadLabel setTextColor:[UIColor whiteColor]];
        [_unreadLabel setTextAlignment:NSTextAlignmentCenter];
    }
    return _unreadLabel;
}

@end
