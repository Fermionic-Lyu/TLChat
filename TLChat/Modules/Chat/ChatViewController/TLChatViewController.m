//
//  TLChatViewController.m
//  TLChat
//
//  Created by 李伯坤 on 16/2/15.
//  Copyright © 2016年 李伯坤. All rights reserved.
//

#import "TLChatViewController.h"
#import "TLChatViewController+Delegate.h"
#import "TLChatDetailViewController.h"
#import "TLChatGroupDetailViewController.h"
#import "TLMoreKBHelper.h"
#import "TLEmojiKBHelper.h"
#import "TLUserHelper.h"
#import "TLChatNotificationKey.h"
#import "TLMacros.h"

#import "HSCourseInfo.h"

static TLChatViewController *chatVC;

@interface TLChatViewController()

@property (nonatomic, strong) TLMoreKBHelper *moreKBhelper;

@property (nonatomic, strong) TLEmojiKBHelper *emojiKBHelper;

@property (nonatomic, strong) UIBarButtonItem *rightBarButton;

@end

@implementation TLChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //    [self.navigationItem setRightBarButtonItem:self.rightBarButton]; //TODO: implement right bar logic 
    
    self.user = (id<TLChatUserProtocol>)[TLUserHelper sharedHelper].user;
    self.moreKBhelper = [[TLMoreKBHelper alloc] init];
    [self setChatMoreKeyboardData:self.moreKBhelper.chatMoreKeyboardData];
    self.emojiKBHelper = [TLEmojiKBHelper sharedKBHelper];
    TLWeakSelf(self);
    [self.emojiKBHelper emojiGroupDataByUserID:[TLUserHelper sharedHelper].userID complete:^(NSMutableArray *emojiGroups) {
        [weakself setChatEmojiKeyboardData:emojiGroups];
    }];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:[UIFont systemFontOfSize:17.0f]}];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetChatVC) name:NOTI_CHAT_VIEW_RESET object:nil];
    if (@available(iOS 11.0, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    } else {
        // Fallback on earlier versions
    }
//    if ([self.partner chat_userType] == TLChatUserTypeGroup) {
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"group_info"] style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonDown:)];
//    }
    //[self.view setBackgroundColor:[UIColor whiteColor]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
//    [MobClick beginLogPageView:@"ChatVC"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [MobClick endLogPageView:@"ChatVC"];
}

- (void)dealloc
{
#ifdef DEBUG_MEMERY
    NSLog(@"dealloc ChatVC");
#endif
}

#pragma mark - # Public Methods
- (void)setPartner:(id<TLChatUserProtocol>)partner
{
    [super setPartner:partner];
    if ([partner chat_userType] == TLChatUserTypeUser) {
        [self.rightBarButton setImage:[UIImage imageNamed:@"nav_chat_single"]];
    }
    else if ([partner chat_userType] == TLChatUserTypeGroup) {
        [self.rightBarButton setImage:[UIImage imageNamed:@"nav_chat_multi"]];
    }
}

#pragma mark - # Event Response
- (void)rightBarButtonDown:(UINavigationBar *)sender
{
    if ([self.partner chat_userType] == TLChatUserTypeUser) {
        TLChatDetailViewController *chatDetailVC = [[TLChatDetailViewController alloc] init];
        [chatDetailVC setUser:(TLUser *)self.partner];
        [self setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:chatDetailVC animated:YES];
    }
    else if ([self.partner chat_userType] == TLChatUserTypeGroup) {
        TLChatGroupDetailViewController *chatGroupDetailVC = [[TLChatGroupDetailViewController alloc] init];
        [chatGroupDetailVC setGroup:(TLGroup *)self.partner];
        [self setHidesBottomBarWhenPushed:YES];
        [self.navigationController pushViewController:chatGroupDetailVC animated:YES];
    }
}

#pragma mark - # Getter
- (UIBarButtonItem *)rightBarButton
{
    if (_rightBarButton == nil) {
        _rightBarButton = [[UIBarButtonItem alloc] initWithImage:nil style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonDown:)];
    }
    return _rightBarButton;
}
@end
