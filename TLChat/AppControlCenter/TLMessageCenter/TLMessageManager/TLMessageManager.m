//
//  TLMessageManager.m
//  TLChat
//
//  Created by 李伯坤 on 16/3/13.
//  Copyright © 2016年 李伯坤. All rights reserved.
//

#import "TLMessageManager.h"
#import "TLMessageManager+ConversationRecord.h"
#import "TLUserHelper.h"
#import "NSFileManager+TLChat.h"

#import "TLMacros.h"

static TLMessageManager *messageManager;

@implementation TLMessageManager

+ (TLMessageManager *)sharedInstance
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        messageManager = [[TLMessageManager alloc] init];
    });
    return messageManager;
}

+ (TLTextMessage *)handleTextMessage:(PFObject *)message {
    
    NSDictionary * dict = [message[@"message"] mj_JSONObject];
    
    TLTextMessage *textMessage = [[TLTextMessage alloc] init];
    textMessage.SavedOnServer = YES;
    textMessage.messageID = message.objectId;
    textMessage.date = message.createdAt;
    
    TLUser * friend = [[TLFriendHelper sharedFriendHelper] getFriendInfoByUserID:message[@"sender"]];
    textMessage.fromUser = (id<TLChatUserProtocol>)friend;
    textMessage.userID = [TLUserHelper sharedHelper].userID;
    
    if ([friend.userID isEqualToString:textMessage.userID]) {
        textMessage.ownerTyper = TLMessageOwnerTypeSelf;
    }else{
        textMessage.ownerTyper = TLMessageOwnerTypeFriend;
    }

    textMessage.text = dict[@"text"];
    return textMessage;
}

+ (TLVoiceMessage *)handleVoiceMessage:(PFObject *)message {
    NSDictionary * dict = [message[@"message"] mj_JSONObject];
    
    TLVoiceMessage *voiceMessage = [[TLVoiceMessage alloc] init];
    voiceMessage.SavedOnServer = YES;
    voiceMessage.messageID = message.objectId;
    voiceMessage.date = message.createdAt;
    
    TLUser * friend = [[TLFriendHelper sharedFriendHelper] getFriendInfoByUserID:message[@"sender"]];
    voiceMessage.fromUser = (id<TLChatUserProtocol>)friend;
    voiceMessage.userID = [TLUserHelper sharedHelper].userID;
    
    if ([friend.userID isEqualToString:voiceMessage.userID]) {
        voiceMessage.ownerTyper = TLMessageOwnerTypeSelf;
    }else{
        voiceMessage.ownerTyper = TLMessageOwnerTypeFriend;
    }
    
    
    NSString *fileName = dict[@"path"];
    NSString *filePath = [NSFileManager pathUserChatVoice:fileName];
    
    
    voiceMessage.recFileName = fileName;
    voiceMessage.time = [dict[@"time"] floatValue];
    voiceMessage.msgStatus = TLVoiceMessageStatusNormal;
    
    PFFile * file = message[@"attachment"];
    
    if (file && ![file isKindOfClass:[NSNull class]]) {
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (!error) {
                
                if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                    [[NSFileManager defaultManager] createFileAtPath:filePath contents:data attributes:nil];
                }
                
            } else {
                
            }
        }];
    }
    return voiceMessage;
}

+ (TLImageMessage *)handleImageMessage:(PFObject *)message {
    
    NSDictionary * dict = [message[@"message"] mj_JSONObject];
    TLImageMessage *imageMessage = [[TLImageMessage alloc] init];
    imageMessage.SavedOnServer = YES;
    imageMessage.messageID = message.objectId;
    imageMessage.date = message.createdAt;
    
    TLUser * friend = [[TLFriendHelper sharedFriendHelper] getFriendInfoByUserID:message[@"sender"]];
    imageMessage.fromUser = (id<TLChatUserProtocol>)friend;
    imageMessage.userID = [TLUserHelper sharedHelper].userID;
    
    if ([friend.userID isEqualToString:imageMessage.userID]) {
        imageMessage.ownerTyper = TLMessageOwnerTypeSelf;
    }else{
        imageMessage.ownerTyper = TLMessageOwnerTypeFriend;
    }
    
    PFFile * file = message[@"thumbnail"];
    if (dict[@"w"] && dict[@"h"]) {
        imageMessage.imageSize = CGSizeMake([dict[@"w"] floatValue], [dict[@"h"] floatValue]);
    }
    
    imageMessage.thumbnailImageURL = file.url;
    //    message1.thumbnailImagePath = imageName; //no path needed here, cell will prefix it when rendering
    PFFile * attachment =  message[@"attachment"];
    imageMessage.imageURL = attachment.url;
    
    return imageMessage;
}

- (void)sendMessage:(TLMessage *)message
           progress:(void (^)(TLMessage *, CGFloat))progress
            success:(void (^)(TLMessage *))success
            failure:(void (^)(TLMessage *))failure
{
    BOOL ok = [self.messageStore addMessage:message];
    if (!ok) {
        DDLogError(@"存储Message到DB失败");
        
        failure(message);
        return;
    }
    else {      // 存储到conversation
        ok = [self addConversationByMessage:message];
        if (!ok) {
            DDLogError(@"存储Conversation到DB失败");
            failure(message);
            return;
        }
    }
    
    success(message);
    // move server saving code here.
}


#pragma mark - Getter -
- (TLDBMessageStore *)messageStore
{
    if (_messageStore == nil) {
        _messageStore = [[TLDBMessageStore alloc] init];
    }
    return _messageStore;
}

- (TLDBConversationStore *)conversationStore
{
    if (_conversationStore == nil) {
        _conversationStore = [[TLDBConversationStore alloc] init];
    }
    return _conversationStore;
}

- (NSString *)userID
{
    return [TLUserHelper sharedHelper].userID;
}

@end
