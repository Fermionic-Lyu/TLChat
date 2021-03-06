//
//  TLChatBaseViewController+Proxy.m
//  TLChat
//
//  Created by 李伯坤 on 16/3/17.
//  Copyright © 2016年 李伯坤. All rights reserved.
//

#import "TLChatBaseViewController+Proxy.h"
#import "TLChatBaseViewController+MessageDisplayView.h"
#import "TLUserHelper.h"

@implementation TLChatBaseViewController (Proxy)

- (void)sendMessage:(TLMessage *)message
{
    message.ownerTyper = TLMessageOwnerTypeSelf;
    message.userID = [TLUserHelper sharedHelper].userID;
    message.fromUser = (id<TLChatUserProtocol>)[TLUserHelper sharedHelper].user;
    message.date = [NSDate date];
    message.showName = NO;
    
    if ([self.partner chat_userType] == TLChatUserTypeUser) {
        message.partnerType = TLPartnerTypeUser;
        message.friendID = [self.partner chat_userID];
    }
    else if ([self.partner chat_userType] == TLChatUserTypeGroup) {
        message.partnerType = TLPartnerTypeGroup;
        message.groupID = [self.partner chat_userID];
    }
    
    if (message.messageType != TLMessageTypeVoice) {
        [self addToShowMessage:message];    // 添加到列表
    }
    else {
        [self.messageDisplayView updateMessage:message];
    }
    if ([message isKindOfClass:[TLTextMessage class]]) {
        [Answers logCustomEventWithName:@"Send Message" customAttributes:@{@"Type":@"Text"}];
    } else if ([message isKindOfClass:[TLVoiceMessage class]]){
        [Answers logCustomEventWithName:@"Send Message" customAttributes:@{@"Type":@"Voice"}];
    } else if ([message isKindOfClass:[TLImageMessage class]]) {
        [Answers logCustomEventWithName:@"Send Message" customAttributes:@{@"Type":@"Image"}];
    }
    
    [[TLMessageManager sharedInstance] sendMessage:message progress:^(TLMessage * message, CGFloat pregress) {
        
    } success:^(TLMessage * message) {
        NSLog(@"send success");
    } failure:^(TLMessage * message) {
        NSLog(@"send failure");
    }];
    
    [[TLMessageManager sharedInstance].conversationStore updateLastReadDateForConversationByUid:[self.partner chat_userID] key:self.conversationKey];
}

- (void)receivedMessage:(TLMessage *)message
{
    if ([self.partner chat_userType] == TLChatUserTypeUser) {
        message.partnerType = TLPartnerTypeUser;
        message.friendID = [self.partner chat_userID];
    }
    else if ([self.partner chat_userType] == TLChatUserTypeGroup) {
        message.partnerType = TLPartnerTypeGroup;
        message.groupID = [self.partner chat_userID];
    }
    message.showName = message.partnerType == TLPartnerTypeGroup && message.ownerTyper != TLMessageOwnerTypeSelf && message.ownerTyper != TLMessageOwnerTypeSystem;

    [self addToShowMessage:message];    // 添加到列表
 
    [[TLMessageManager sharedInstance] sendMessage:message progress:^(TLMessage * message, CGFloat pregress) {

    } success:^(TLMessage * message) {
        NSLog(@"send success");
    } failure:^(TLMessage * message) {
        NSLog(@"send failure");
    }];
    
    [[TLMessageManager sharedInstance].conversationStore updateLastReadDateForConversationByUid:[self.user chat_userID] key:self.conversationKey];

}

@end
