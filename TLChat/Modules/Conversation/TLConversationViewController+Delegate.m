//
//  TLConversationViewController+Delegate.m
//  TLChat
//
//  Created by 李伯坤 on 16/3/17.
//  Copyright © 2016年 李伯坤. All rights reserved.
//

#import "TLConversationViewController+Delegate.h"
#import "TLConversation+TLUser.h"
#import "TLConversationCell.h"
#import "TLFriendHelper.h"
#import "TLMessage.h"
#import "TLUserHelper.h"
#import "TLMessageManager.h"
#import <TLKit/TLKit.h>
#import "TLMacros.h"
#import "TLGroupDataLoader.h"


@interface TLConversationViewController (Delegate)

@end
@implementation TLConversationViewController (Delegate)

#pragma mark - Public Methods -
- (void)registerCellClass
{
    [self.tableView registerClass:[TLConversationCell class] forCellReuseIdentifier:@"TLConversationCell"];
}

#pragma mark - Delegate -
//MARK: TLMessageManagerConvVCDelegate
- (void)updateConversationData
{
    [[TLMessageManager sharedInstance] refreshConversationRecord];
    
    [[TLMessageManager sharedInstance] conversationRecord:^(NSArray *data) {
        
        NSInteger totalUnreadCount = 0;
        for (TLConversation *conversation in data) {
            if (conversation.convType == TLConversationTypePersonal) {
                TLUser *user = [[TLFriendHelper sharedFriendHelper] getFriendInfoByUserID:conversation.partnerID];
                [conversation updateUserInfo:user];
            }
            else if (conversation.convType == TLConversationTypeGroup) {
                TLGroup *group = [[TLFriendHelper sharedFriendHelper] getGroupInfoByGroupID:conversation.partnerID];
                [conversation updateGroupInfo:group];
            }
            
            totalUnreadCount = totalUnreadCount + (conversation.noDisturb ? 0 : conversation.unreadCount);
        }
        self.data = [[NSMutableArray alloc] initWithArray:data];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSInteger numberRows = [self.tableView numberOfRowsInSection:0];
            if (numberRows != [self.data count]) {
                needReloadData = YES;
            }
            for (int i = 0; i < [self.data count]; i++) {
                TLConversationCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                TLConversation *conversation = self.data[i];
                if ([cell.conversation.partnerID isEqualToString:conversation.partnerID]) {
                    [cell setConversationWithOutReloadingAvatar:conversation];
                } else {
                    [cell setConversation:conversation];
                }
            }
            if (needReloadData) {
                [self.tableView reloadData];
                needReloadData = NO;
            }
        });
        
        DLog(@"calculated totle unread count: %ld", totalUnreadCount);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateTabbarBadgeValueNotifi"
                                                            object:@{@"unreadMessagesCount":[NSNumber numberWithInteger:totalUnreadCount]}];

    }];
    
}

//MARK: UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TLConversation *conversation = [self.data objectAtIndex:indexPath.row];
    TLConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TLConversationCell"];
    [cell setConversation:conversation];
    [cell setBottomLineStyle:indexPath.row == self.data.count - 1 ? TLCellLineStyleFill : TLCellLineStyleDefault];
    return cell;
}

//MARK: UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return HEIGHT_CONVERSATION_CELL;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    TLChatViewController *chatVC = [[TLChatViewController alloc] init];
    
    TLConversation *conversation = [self.data objectAtIndex:indexPath.row];
 
    
    
    chatVC.conversationKey = conversation.key;
    chatVC.noDisturb = conversation.noDisturb;
    
    if (conversation.convType == TLConversationTypePersonal) {
        TLUser *user = [[TLFriendHelper sharedFriendHelper] getFriendInfoByUserID:conversation.partnerID];
        if (user == nil) {
            [TLUIUtility showAlertWithTitle:@"Error" message:@"You don't have this friend."];
            return;
        }
        [chatVC setPartner:user];
    }
    else if (conversation.convType == TLConversationTypeGroup){
        TLGroup *group = [[TLFriendHelper sharedFriendHelper] getGroupInfoByGroupID:conversation.partnerID];
        if (group == nil) {
            [TLUIUtility showAlertWithTitle:@"Error" message:@"You don't have this group chat."];
            return;
        }
        [chatVC setPartner:group];
        chatVC.courseInfo = [[TLGroupDataLoader sharedGroupDataLoader] getCourseInfoByGroupID:group.groupID];
    }
    [self setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:chatVC animated:YES];
    [self setHidesBottomBarWhenPushed:NO];
    
    // 标为已读
    [(TLConversationCell *)[self.tableView cellForRowAtIndexPath:indexPath] markAsRead];
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TLConversation *conversation = [self.data objectAtIndex:indexPath.row];
    __weak typeof(self) weakSelf = self;
    UITableViewRowAction *delAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault
                                                                         title:NSLocalizedString(@"DELETE", nil)
                                                                       handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                       {
                                           [weakSelf.data removeObjectAtIndex:indexPath.row];
                                           BOOL ok = [[TLMessageManager sharedInstance] deleteConversationByPartnerID:conversation.partnerID];
                                           if (!ok) {
                                               [TLUIUtility showAlertWithTitle:@"错误" message:@"从数据库中删除会话信息失败"];
                                           }
                                           [weakSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                                           if (self.data.count > 0 && indexPath.row == self.data.count) {
                                               NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];
                                               TLConversationCell *cell = [self.tableView cellForRowAtIndexPath:lastIndexPath];
                                               [cell setBottomLineStyle:TLCellLineStyleFill];
                                           }
                                       }];
    return @[delAction];
}

@end
