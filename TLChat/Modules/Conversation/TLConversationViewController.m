//
//  TLConversationViewController.m
//  TLChat
//
//  Created by 李伯坤 on 16/1/23.
//  Copyright © 2016年 李伯坤. All rights reserved.
//

#import "TLConversationViewController.h"
#import "TLConversationViewController+Delegate.h"
#import "TLSearchController.h"
#import <AFNetworking/AFNetworking.h>
//#import "TLAppDelegate.h"
#import "TLFriendHelper.h"
#import "TLUserHelper.h"
#import "TLFriendDataLoader.h"
#import "TLGroupDataLoader.h"

#import "TLMessageManager+ConversationRecord.h"
#import "TLMacros.h"



@interface TLConversationViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIImageView *scrollTopView;

@property (nonatomic, strong) TLSearchController *searchController;

@property (nonatomic, strong) TLAddMenuView *addMenuView;

@end

@implementation TLConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self p_initUI];        // 初始化界面UI
    
    [[TLMessageManager sharedInstance] setConversationDelegate:self];
   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStatusChange:) name:AFNetworkingReachabilityDidChangeNotification object:nil];
    
    if ([TLUserHelper sharedHelper].isLogin) {
        [TLFriendHelper sharedFriendHelper]; // force a friend data load.
        [[HSNetworkAdapter adapter] fetchNotificationSettingForConversations];
    }
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kAKUserLoggedInNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [TLFriendHelper sharedFriendHelper]; // force a friend data load.
        [[HSNetworkAdapter adapter] fetchNotificationSettingForConversations];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kAKUserLoggedOutNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [[TLFriendHelper sharedFriendHelper] reset];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateConversationData) name:kAKFriendsAndGroupDataUpdateNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshAllConversations) name:UIApplicationWillEnterForegroundNotification object:nil];
    

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newChatMessageArrive:) name:@"NewChatMessageReceived" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newConversation:) name:@"UNI_FRIEND_LIST_CHANGED_NOTIFICATION" object:nil];
    
    //self.definesPresentationContext = YES;
}

- (void)newConversation:(NSNotification *)notification {
    if (notification.object) {
        NSString *userId = notification.object;
        TLUser *friend = [[TLFriendHelper sharedFriendHelper] getFriendInfoByUserID:userId];
        friend.date = [NSDate date];
        [[TLFriendDataLoader sharedFriendDataLoader] createFriendDialogWithLatestMessage:friend completionBlock:nil];
    }
}

- (void)newChatMessageArrive:(NSNotification*)notificaion {
    
    
    __weak TLConversationViewController * weakSelf = self;
    NSString * conversationKey = notificaion.object;
    if (conversationKey) {
        // friends
        NSArray * users = [conversationKey componentsSeparatedByString:@":"];
        if (users.count > 1) {
            NSArray * matches = [users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != %@", [TLUserHelper sharedHelper].userID]];
            if (matches.count > 0) {
                NSString * friendID = matches.firstObject;
                TLUser * friend = [[TLFriendHelper sharedFriendHelper] getFriendInfoByUserID:friendID];
                
                [[TLFriendDataLoader sharedFriendDataLoader] createFriendDialogWithLatestMessage:friend completionBlock:^{
                    
                    TLConversation * conversation = [[TLMessageManager sharedInstance].conversationStore conversationByKey:conversationKey];
                    if (conversation) {
                        [[TLMessageManager sharedInstance].conversationStore countUnreadMessages:conversation withCompletionBlock:^(NSInteger count) {
                            [weakSelf updateConversationData];
                        }];
                    }
                    

                }];
            }
        }else{
            
            // GROUP
            
            TLGroup * group = [[TLFriendHelper sharedFriendHelper] getGroupInfoByGroupID:conversationKey];
            
            
            [[TLGroupDataLoader sharedGroupDataLoader] createCourseDialogWithLatestMessage:group completionBlock:^{
                
                TLConversation * conversation = [[TLMessageManager sharedInstance].conversationStore conversationByKey:conversationKey];
                if (conversation) {
                    [[TLMessageManager sharedInstance].conversationStore countUnreadMessages:conversation withCompletionBlock:^(NSInteger count){
                        [weakSelf updateConversationData];
                    }];
                }
                
               
            }];
        }
    }
    
    [self updateConversationData];    

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [self updateConversationData];  // to update conversation lastes message whenver back to this screen

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.addMenuView.isShow) {
        [self.addMenuView dismiss];
    }
    

}

#pragma mark - Event Response
- (void)rightBarButtonDown:(UIBarButtonItem *)sender
{
    if (self.addMenuView.isShow) {
        [self.addMenuView dismiss];
    }
    else {
        [self.addMenuView showInView:self.navigationController.view];
    }
}

// 网络情况改变
- (void)networkStatusChange:(NSNotification *)noti
{
    AFNetworkReachabilityStatus status = [noti.userInfo[@"AFNetworkingReachabilityNotificationStatusItem"] longValue];
    switch (status) {
        case AFNetworkReachabilityStatusReachableViaWiFi:
        case AFNetworkReachabilityStatusReachableViaWWAN:
        case AFNetworkReachabilityStatusUnknown:
            [self.navigationItem setTitle:NSLocalizedString(@"MESSAGE", nil)];
            break;
        case AFNetworkReachabilityStatusNotReachable:
            [self.navigationItem setTitle:NSLocalizedString(@"MESSAGE_UNCONNECTED", nil)];
            break;
        default:
            break;
    }
}

#pragma mark - Private Methods -
- (void)p_initUI
{
    [self.view addSubview:self.tableView];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationController.view setBackgroundColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    
    if (@available(iOS 11.0, *)) {
        self.navigationController.navigationBar.prefersLargeTitles = YES;
        [self.navigationController.navigationBar setLargeTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor], NSFontAttributeName:[UIFont fontWithName:@"Helvetica-Bold" size:30.0f]}];
    } else {
        // Fallback on earlier versions
    }
    self.title = NSLocalizedString(@"MESSAGE", nil);
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[HSTableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height - 113.0f)];
        [self registerCellClass];
        [_tableView setBackgroundColor:[UIColor whiteColor]];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        [_tableView setTableFooterView:[UIView new]];
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
        [_tableView setBackgroundColor:[UIColor colorWithHexString:@"EFEFF4"]];
        WS(weakSelf);
        [_tableView addRefreshActionHandler:^{
            [weakSelf refreshAllConversations];
        }];
        
    }
    return _tableView;
}

- (void)refreshAllConversations {
    [[TLMessageManager sharedInstance] conversationRecord:^(NSArray *data) {
        for (TLConversation *conversation in data) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NewChatMessageReceived" object:conversation.key];
        }
        
    }];
}

#pragma mark - Getter -
- (TLSearchController *) searchController
{
    if (_searchController == nil) {
        _searchController = [[TLSearchController alloc] initWithSearchResultsController:self.searchVC];
        [_searchController setSearchResultsUpdater:self.searchVC];
        [_searchController.searchBar setPlaceholder:@"搜索"];
        [_searchController.searchBar setDelegate:self];
        [_searchController setShowVoiceButton:YES];
        _searchController.hidesNavigationBarDuringPresentation = NO;
    }
    return _searchController;
}

- (TLFriendSearchViewController *) searchVC
{
    if (_searchVC == nil) {
        _searchVC = [[TLFriendSearchViewController alloc] init];
    }
    return _searchVC;
}

- (UIImageView *)scrollTopView
{
    if (_scrollTopView == nil) {
        _scrollTopView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nav_menu_radar"]];
    }
    return _scrollTopView;
}

- (TLAddMenuView *)addMenuView
{
    if (_addMenuView == nil) {
        _addMenuView = [[TLAddMenuView alloc] init];
        [_addMenuView setDelegate:self];
    }
    return _addMenuView;
    //return nil;
}

@end
