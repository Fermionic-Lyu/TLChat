//
//  TLChatViewController.h
//  TLChat
//
//  Created by 李伯坤 on 16/2/15.
//  Copyright © 2016年 李伯坤. All rights reserved.
//

#import "TLChatBaseViewController.h"
#import "HSCourseInfo.h"

@interface TLChatViewController : TLChatBaseViewController

@property (strong, nonatomic) HSCourseInfo *courseInfo;

@property (assign, nonatomic) BOOL noDisturb;

@end
