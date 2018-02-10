
//
//  TLUser.m
//  TLChat
//
//  Created by 李伯坤 on 16/1/23.
//  Copyright © 2016年 李伯坤. All rights reserved.
//

#import "TLUser.h"
#import "NSString+PinYin.h"
#import <MJExtension/MJExtension.h>

@implementation TLUser

- (id)init
{
    if (self = [super init]) {
        [TLUser mj_setupObjectClassInArray:^NSDictionary *{
            return @{ @"detailInfo" : @"TLUserDetail",
                      @"userSetting" : @"TLUserSetting",
                      @"chatSetting" : @"TLUserChatSetting",};
        }];
    }
    return self;
}

- (void)setUsername:(NSString *)username
{
    if ([username isEqualToString:_username]) {
        return;
    }
    _username = username;
}

- (void)setNikeName:(NSString *)nikeName
{
    if ([nikeName isEqualToString:_nikeName]) {
        return;
    }
    _nikeName = nikeName;
}

- (void)setRemarkName:(NSString *)remarkName
{
    if ([remarkName isEqualToString:_remarkName]) {
        return;
    }
    _remarkName = remarkName;
}

#pragma mark - Getter
- (NSString *)showName
{
    return self.username;
}

- (TLUserDetail *)detailInfo
{
    if (_detailInfo == nil) {
        _detailInfo = [[TLUserDetail alloc] init];
    }
    return _detailInfo;
}

@end
