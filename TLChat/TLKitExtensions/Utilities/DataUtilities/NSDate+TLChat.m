//
//  NSDate+TLChat.m
//  TLChat
//
//  Created by 李伯坤 on 16/3/3.
//  Copyright © 2016年 李伯坤. All rights reserved.
//

#import "NSDate+TLChat.h"
#import <TLKit/TLKit.h>
@implementation NSDate (TLChat)

- (NSString *)chatTimeInfo
{
    if ([self isToday]) {       // 今天
        return self.formatHM;
    }
    else if ([self isYesterday]) {      // 昨天
        return [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"YESTERDAY", nil),self.formatHM];
    }
    else if ([self isThisWeek]){        // 本周
        return [NSString stringWithFormat:@"%@ %@", self.formatWeekday, self.formatHM];
    }
    else {
        return [NSString stringWithFormat:@"%@ %@", self.formatYMD, self.formatHM];
    }
}

- (NSString *)conversaionTimeInfo
{
    if ([self isToday]) {       // 今天
        return self.formatHM;
    }
    else if ([self isYesterday]) {      // 昨天
        return NSLocalizedString(@"YESTERDAY", nil);
    }
    else if ([self isThisWeek]){        // 本周
        return self.formatWeekday;
    }
    else {
        return [self formatYMDWithSeparate:@"/"];
    }
}

- (NSString *)chatFileTimeInfo
{
    if ([self isThisWeek]) {
        return @"本周";
    }
    else if ([self isThisMonth]) {
        return @"这个月";
    }
    else {
        return [NSString stringWithFormat:@"%ld年%ld月", (long)self.year, (long)self.month];
    }
}

@end
