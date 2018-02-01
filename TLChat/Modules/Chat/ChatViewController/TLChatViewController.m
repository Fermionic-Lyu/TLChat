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
#import "HSCourseStudentListVC.h"

static TLChatViewController *chatVC;

@interface TLChatViewController()

@property (nonatomic, strong) TLMoreKBHelper *moreKBhelper;

@property (nonatomic, strong) TLEmojiKBHelper *emojiKBHelper;

@property (nonatomic, strong) UIView *notifiButtonView;
@property (nonatomic, strong) UIButton *notifiButton;

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

    [self.navigationController.view setBackgroundColor:[UIColor whiteColor]];
    
    
    _notifiButtonView = [[UIView alloc] initWithFrame:CGRectMake(0.0f,0.0f, 25.0f, 40.0f)];
    _notifiButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _notifiButton.frame = CGRectMake(0.0f, 5.0f, 25.0f, 25.0f);
    [_notifiButton addTarget:self action:@selector(notifiButtonDown:) forControlEvents:UIControlEventTouchUpInside];
    [_notifiButtonView addSubview:_notifiButton];
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
    
    if ([partner chat_userType] == TLChatUserTypeGroup) {

        UIView *groupInfoView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 30.0f, 40.0f)];
        UIButton *groupInfoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        groupInfoBtn.frame = CGRectMake(5.0f, 5.0f, 25.0f, 25.0f);
        [groupInfoBtn setImage:[UIImage imageNamed:@"group_info"] forState:UIControlStateNormal];
        [groupInfoBtn addTarget:self action:@selector(groupInfoButtonDown:) forControlEvents:UIControlEventTouchUpInside];
        [groupInfoView addSubview:groupInfoBtn];
        
        self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:groupInfoView],[[UIBarButtonItem alloc] initWithCustomView:_notifiButtonView]];

    } else {
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_notifiButtonView];
        
    }
    [self setNotifiButtonImage];
}

- (void)notifiButtonDown:(id)sender {
    self.noDisturb = !self.noDisturb;
    [[TLMessageManager sharedInstance].conversationStore updateNoDisturbForConversation:self.noDisturb Uid:[self.user chat_userID] key:self.conversationKey];
    if (self.noDisturb) {
        [[Hud defaultInstance] showMessage:NSLocalizedString(@"TURN_OFF_NOTIFICATION", nil)];
    } else {
        [[Hud defaultInstance] showMessage:NSLocalizedString(@"TURN_ON_NOTIFICATION", nil)];
    }
    [self setNotifiButtonImage];
}

- (void)groupInfoButtonDown:(id)sender {

    HSCourseStudentListVC *nextVC = [[HSCourseStudentListVC alloc] initWithCourse:_courseInfo];
    [self.navigationController pushViewController:nextVC animated:YES hideBottomTabBar:YES];
}

- (void)setNotifiButtonImage {
    [_notifiButton setImage:[UIImage imageNamed:self.noDisturb ? @"notifi_off" : @"notifi_on"] forState:UIControlStateNormal];
}

@end
