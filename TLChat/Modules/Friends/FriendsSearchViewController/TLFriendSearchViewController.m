//
//  TLFriendSearchViewController.m
//  TLChat
//
//  Created by 李伯坤 on 16/1/25.
//  Copyright © 2016年 李伯坤. All rights reserved.
//

#import "TLFriendSearchViewController.h"
#import "TLFriendCell.h"
#import "TLNewFriendViewController.h"
#import "TLGroupViewController.h"
#import "TLTagsViewController.h"
#import "TLPublicServerViewController.h"
#import "TLFriendDetailViewController.h"
#import <TLKit/TLKit.h>

@interface TLFriendSearchViewController ()

@property (nonatomic, strong) NSMutableArray *data;

@end

@implementation TLFriendSearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.data = [[NSMutableArray alloc] init];;
    [self.tableView registerClass:[TLFriendCell class] forCellReuseIdentifier:@"FriendCell"];
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tableView.y = NAVBAR_HEIGHT + STATUSBAR_HEIGHT;
    self.tableView.height = SCREEN_HEIGHT - self.tableView.y;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.data.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"联系人";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TLFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendCell"];
    
    TLUser *user = [self.data objectAtIndex:indexPath.row];
    [cell setUser:user];
    [cell setTopLineStyle:(indexPath.row == 0 ? TLCellLineStyleFill : TLCellLineStyleNone)];
    [cell setBottomLineStyle:(indexPath.row == self.data.count - 1 ? TLCellLineStyleFill : TLCellLineStyleDefault)];
    return cell;
}

#pragma mark - Delegate -
//MARK: UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return HEIGHT_FRIEND_CELL;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TLUser *user = [self.data objectAtIndex:indexPath.row];
 
    TLFriendDetailViewController *detailVC = [[TLFriendDetailViewController alloc] init];
    [detailVC setUser:user];
    [self setHidesBottomBarWhenPushed:YES];
    [self.presentingViewController.navigationController pushViewController:detailVC animated:YES];
    [self setHidesBottomBarWhenPushed:NO];
 
}

//MARK: UISearchResultsUpdating
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchText = [searchController.searchBar.text lowercaseString];
    [self.data removeAllObjects];
    for (TLUser *user in self.friendsData) {
        if ([user.remarkName containsString:searchText] || [user.username containsString:searchText] || [user.nikeName containsString:searchText] || [user.pinyin containsString:searchText] || [user.pinyinInitial containsString:searchText]) {
            [self.data addObject:user];
        }
    }
    [self.tableView reloadData];
}

@end
