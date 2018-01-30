//
//  TLUIManager.m
//  UNI
//
//  Created by Frank Mao on 2017-12-14.
//  Copyright © 2017 Mazoic Technologies Inc. All rights reserved.
//

#import "TLUIManager.h"
#import "TLUserHelper.h"
#import "TLChatViewController.h"
#import "TLFriendDetailViewController.h"
#import "TLGroupDataLoader.h"
#import "TLFriendDataLoader.h"

@implementation TLUIManager

static TLUIManager *uiManager = nil;

+ (TLUIManager *)sharedUIManager
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        uiManager = [[TLUIManager alloc] init];
    });
    return uiManager;
}

- (void)openChatDialogWithUser:(NSString *)userId fromNavigationController:(UINavigationController *)navigationController {
    TLChatViewController * chatVC = [navigationController findViewController:@"TLChatViewController"];
    if (chatVC) {
        if ([userId isEqualToString:[chatVC.partner chat_userID]]) {
            [navigationController popToViewControllerWithClassName:@"TLChatViewController" animated:YES];
            return;
        }
        
    }
    
    TLChatViewController * vc = [TLChatViewController new];
    TLUser * partner = [[TLFriendHelper sharedFriendHelper] getFriendInfoByUserID:userId];
    vc.partner = (id<TLChatUserProtocol>)partner;
    
    [navigationController pushViewController:vc animated:YES];
}

- (void)openChatDialog:(NSString *)dialogKey navigationController:(UINavigationController*)navigationController {
    
    TLChatViewController * chatVC = [navigationController findViewController:@"TLChatViewController"];
    if (chatVC) {
        if ([dialogKey isEqualToString:chatVC.conversationKey]) {
            [navigationController popToViewControllerWithClassName:@"TLChatViewController" animated:YES];
            return;
        }
        
    }
    
    
    TLChatViewController * vc = [TLChatViewController new];
    
    NSArray * users = [dialogKey componentsSeparatedByString:@":"];
    if (users.count > 1) {
        NSArray * matches = [users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != %@", [TLUserHelper sharedHelper].userID]];
        if (matches.count > 0) {
            NSString * friendID = matches.firstObject;
            TLUser * friend = [[TLFriendHelper sharedFriendHelper] getFriendInfoByUserID:friendID];
            [vc setPartner:(id<TLChatUserProtocol>)friend];
            [navigationController pushViewController:vc animated:YES];
            [[TLFriendDataLoader sharedFriendDataLoader] createFriendDialogWithLatestMessage:friend completionBlock:nil];
        }
    } else {
        
        TLGroup * group = [[TLFriendHelper sharedFriendHelper] getGroupInfoByGroupID:dialogKey];
        vc.courseInfo = [[TLFriendHelper sharedFriendHelper] getCourseInfoByGroupID:group.groupID];
        [vc setPartner:(id<TLChatUserProtocol>)group];
        [navigationController pushViewController:vc animated:YES];
        [[TLGroupDataLoader sharedGroupDataLoader] createCourseDialogWithLatestMessage:group completionBlock:nil];
    }
    
    
    
}

- (void)openUserDetails:(TLUser *)user navigationController:(UINavigationController*)navigationController {
    
    TLFriendDetailViewController *detailVC = [[TLFriendDetailViewController alloc] init];
    [detailVC setUser:user];
    [detailVC setHidesBottomBarWhenPushed:YES];
    [navigationController pushViewController:detailVC animated:YES];
}

@end
