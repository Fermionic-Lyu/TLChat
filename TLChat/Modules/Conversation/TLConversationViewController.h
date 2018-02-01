//
//  TLConversationViewController.h
//  TLChat
//
//  Created by 李伯坤 on 16/1/23.
//  Copyright © 2016年 李伯坤. All rights reserved.
//

#import "TLTableViewController.h"
#import "TLMessageManager+ConversationRecord.h"
#import "TLFriendSearchViewController.h"
#import "HSTableView.h"

@import Parse;
@import ParseLiveQuery;
@import Parse.PFQuery;

@interface TLConversationViewController : UIViewController {
    NSArray * _currentKeys;
    BOOL needReloadData;
}

@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, strong) HSTableView *tableView;

@end
