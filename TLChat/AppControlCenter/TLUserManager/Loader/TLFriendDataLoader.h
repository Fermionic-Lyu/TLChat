//
//  TLFriendDataLoader.h
//  TLChat
//
//  Created by Frank Mao on 2017-12-05.
//  Copyright © 2017 李伯坤. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TLUser.h"

@interface TLFriendDataLoader : NSObject

+ (TLFriendDataLoader *)sharedFriendDataLoader;

- (void)p_loadFriendsDataWithCompletionBlock:(void(^)(NSArray<TLUser*> *friends))completionBlock;

- (void)recreateLocalDialogsForFriendsWithCompletionBlock:(void(^)())completionBlock;

- (void)createNewFriendDialogWithUserIdWithLatestMessage:(NSString *)userId completionBlock:(void (^)())completionBlock;
- (void)createFriendDialogWithLatestMessage:(TLUser *)friend completionBlock:(void(^)())completionBlock;
@end
