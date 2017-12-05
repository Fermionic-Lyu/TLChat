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
        for (TLConversation *conversation in data) {
            if (conversation.convType == TLConversationTypePersonal) {
                TLUser *user = [[TLFriendHelper sharedFriendHelper] getFriendInfoByUserID:conversation.partnerID];
                [conversation updateUserInfo:user];
            }
            else if (conversation.convType == TLConversationTypeGroup) {
                TLGroup *group = [[TLFriendHelper sharedFriendHelper] getGroupInfoByGroupID:conversation.partnerID];
                [conversation updateGroupInfo:group];
            }
        }
        self.data = [[NSMutableArray alloc] initWithArray:data];
        [self.tableView reloadData];
        
        [self p_initLiveQuery];
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
    
    if (conversation.convType == TLConversationTypePersonal) {
        TLUser *user = [[TLFriendHelper sharedFriendHelper] getFriendInfoByUserID:conversation.partnerID];
        if (user == nil) {
            [TLUIUtility showAlertWithTitle:@"错误" message:@"您不存在此好友"];
            return;
        }
        [chatVC setPartner:user];
    }
    else if (conversation.convType == TLConversationTypeGroup){
        TLGroup *group = [[TLFriendHelper sharedFriendHelper] getGroupInfoByGroupID:conversation.partnerID];
        if (group == nil) {
            [TLUIUtility showAlertWithTitle:@"错误" message:@"您不存在该讨论组"];
            return;
        }
        [chatVC setPartner:group];
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
                                                                         title:@"删除"
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
    UITableViewRowAction *moreAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault
                                                                          title:conversation.isRead ? @"标为未读" : @"标为已读"
                                                                        handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                        {
                                            TLConversationCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                                            conversation.isRead ? [cell markAsUnread] : [cell markAsRead];
                                            [tableView setEditing:NO animated:YES];
                                        }];
    moreAction.backgroundColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0];
    return @[delAction, moreAction];
}

//MARK: UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [self.searchVC setFriendsData:[TLFriendHelper sharedFriendHelper].friendsData];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self.tabBarController.tabBar setHidden:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [self.tabBarController.tabBar setHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"语音搜索按钮" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
}

//MARK: TLAddMenuViewDelegate
// 选中了addMenu的某个菜单项
- (void)addMenuView:(TLAddMenuView *)addMenuView didSelectedItem:(TLAddMenuItem *)item
{
    if (item.className.length > 0) {
        id vc = [[NSClassFromString(item.className) alloc] init];
        [self setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:vc animated:YES];
        [self setHidesBottomBarWhenPushed:NO];
    }
    else {
        [TLUIUtility showAlertWithTitle:item.title message:@"功能暂未实现"];
    }
}

- (void)p_initLiveQuery
{
    self.client = [[PFLiveQueryClient alloc] init];
    
    self.query = [PFQuery queryWithClassName:kParseClassNameMessage];
    
    NSArray * keys = [self.data valueForKeyPath:@"key"];
    [self.query whereKey:@"dialogKey" containedIn:keys];
    
    
    self.subscription = [self.client  subscribeToQuery:self.query];
    
    
    self.subscription = [self.subscription addSubscribeHandler:^(PFQuery<PFObject *> * _Nonnull query) {
        NSLog(@"Subscribed");
    }];
    
    self.subscription = [self.subscription addUnsubscribeHandler:^(PFQuery<PFObject *> * _Nonnull query) {
        NSLog(@"unsubscribed");
    }];
    
    self.subscription = [self.subscription addEnterHandler:^(PFQuery<PFObject *> * _Nonnull query, PFObject * _Nonnull object) {
        NSLog(@"enter");
    }];
    
    self.subscription = [self.subscription addEventHandler:^(PFQuery<PFObject *> * _Nonnull query, PFLiveQueryEvent * _Nonnull event) {
        NSLog(@"event: %@", event);
    }];
    
    self.subscription = [self.subscription addDeleteHandler:^(PFQuery<PFObject *> * _Nonnull query, PFObject * _Nonnull message) {
        NSLog(@"message deleted: %@ %@",message.createdAt, message.objectId);
    }];
    
    
    __weak TLConversationViewController * weakSelf = self;
    self.subscription = [self.subscription addCreateHandler:^(PFQuery<PFObject *> * _Nonnull query, PFObject * _Nonnull message) {
        
        
        [weakSelf processMessageFromServer:message bypassMine:YES];
        
        
    }];
}


- (void)processMessageFromServer:(PFObject *)message bypassMine:(BOOL)bypassMine{
    
    NSLog(@"message received: %@ %@ %@", message.objectId, message[@"message"], message[@"sender"]);
    

    NSArray * matches = [self.data filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"key == %@", message[@"dialogKey"]]];
    if (matches.count > 0) {
        TLConversation * conv = matches.firstObject;
        
        NSInteger idx = [self.data indexOfObject:conv];
        
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
        
        
        NSString * content = [TLMessage conversationContentForMessage:message[@"message"]];

        NSString * lastMsg = [[TLFriendHelper sharedFriendHelper] formatLastMessage:content fid:message[@"sender"]];
        
        
        conv.content = lastMsg;
        conv.date = message.createdAt;
        
        dispatch_async(dispatch_get_main_queue(), ^{
             [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        });
       
    }
    
}

@end
