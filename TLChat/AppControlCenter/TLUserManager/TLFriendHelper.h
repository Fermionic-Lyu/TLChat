//
//  TLFriendHelper.h
//  TLChat
//
//  Created by 李伯坤 on 16/1/27.
//  Copyright © 2016年 李伯坤. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TLUserGroup.h"
#import "TLGroup.h"
#import "HSCourseInfo.h"

@class TLMessage;

@interface TLFriendHelper : NSObject

/// 好友列表默认项
@property (nonatomic, strong) TLUserGroup *defaultGroup;


#pragma mark - # 好友

/// 好友数据(原始)
@property (nonatomic, strong) NSMutableArray *friendsData;

/// 格式化的好友数据（二维数组，列表用）
@property (nonatomic, strong) NSMutableArray *data;

/// 格式化好友数据的分组标题
@property (nonatomic, strong) NSMutableArray *sectionHeaders;

///  好友数量
@property (nonatomic, assign, readonly) NSInteger friendCount;

@property (nonatomic, strong) void(^dataChangedBlock)(NSMutableArray *friends, NSMutableArray *headers, NSInteger friendCount);


#pragma mark - # 群
/// 群数据
@property (nonatomic, strong) NSMutableArray<TLGroup*> *groupsData;


#pragma mark - # 标签
/// 标签数据
@property (nonatomic, strong) NSMutableArray *tagsData;


+ (TLFriendHelper *)sharedFriendHelper;

- (void)reloadUsers;

- (PFUser *)getPFUserByUserId:(NSString *)userId;

- (TLUser *)getFriendInfoByUserID:(NSString *)userID;

- (TLGroup *)getGroupInfoByGroupID:(NSString *)groupID;

- (NSString *)makeDialogNameForFriend:(NSString *)fid myId:(NSString *)uid;

- (NSString *)formatLastMessage:(NSString *)content fid:(NSString *)fid;
- (NSString *)formatLastMessage:(TLMessage *)message;

- (void)reset; // when user log out.

- (void)reloadGroupData;

- (void)deleteFriend:(NSString *)fid;
@end
