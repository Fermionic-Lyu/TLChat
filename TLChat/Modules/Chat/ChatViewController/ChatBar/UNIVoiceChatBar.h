//
//  UNIVoiceChatBar.h
//  UNI
//
//  Created by Can Lyu on 2018/2/12.
//  Copyright © 2018年 Mazoic Technologies Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UNIVoiceChatBar;

@protocol UNIVoiceChatBarDelegate <NSObject>

- (void)returnToNormalChatBar;

- (void)chatBarStartRecording:(UNIVoiceChatBar *)voiceBar;

- (void)chatBarWillCancelRecording:(UNIVoiceChatBar *)voiceBar cancel:(BOOL)cancel;

- (void)chatBarDidCancelRecording:(UNIVoiceChatBar *)voiceBar;

- (void)chatBarFinishedRecoding:(UNIVoiceChatBar *)voiceBar;

@end

@interface UNIVoiceChatBar : UIView

@property (nonatomic, assign) id<UNIVoiceChatBarDelegate> delegate;

@property (assign, nonatomic) BOOL isShow;

- (void)showInView:(UIView *)view withAnimation:(BOOL)animation;
- (void)dismissWithAnimation:(BOOL)animation withCompletionBlock:(void (^)())completionBlock;

@end
