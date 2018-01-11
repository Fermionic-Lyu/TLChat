//
//  TLChatViewController+Delegate.m
//  TLChat
//
//  Created by 李伯坤 on 16/3/17.
//  Copyright © 2016年 李伯坤. All rights reserved.
//

#import "TLChatViewController+Delegate.h"
#import "TLExpressionViewController.h"
#import "TLMyExpressionViewController.h"
#import "TLFriendDetailViewController.h"
#import <MWPhotoBrowser/MWPhotoBrowser.h>
#import "NSFileManager+TLChat.h"
#import "TLUIManager.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface TLChatViewController ()

@end

@implementation TLChatViewController (Delegate)

#pragma mark - Delegate -
//MARK: TLMoreKeyboardDelegate
- (void)moreKeyboard:(id)keyboard didSelectedFunctionItem:(TLMoreKeyboardItem *)funcItem
{
    if (funcItem.type == TLMoreKeyboardItemTypeCamera || funcItem.type == TLMoreKeyboardItemTypeImage) {
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        if (funcItem.type == TLMoreKeyboardItemTypeCamera) {
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                [imagePickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
            }
            else {
                [TLUIUtility showAlertWithTitle:NSLocalizedString(@"ERROR", nil) message:NSLocalizedString(@"CAMERA_INITIALIZATION_FAILED", nil)];
                return;
            }
        }
        else {
            [imagePickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        }
        [self presentViewController:imagePickerController animated:YES completion:nil];
        __weak typeof(self) weakSelf = self;
        [imagePickerController.rac_imageSelectedSignal subscribeNext:^(id x) {
            [imagePickerController dismissViewControllerAnimated:YES completion:^{
                UIImage *image = [x objectForKey:UIImagePickerControllerOriginalImage];
                [weakSelf sendImageMessage:image];
            }];
        } completed:^{
            [imagePickerController dismissViewControllerAnimated:YES completion:nil];
        }];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"选中”%@“ 按钮", funcItem.title] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }
}

//MARK: TLEmojiKeyboardDelegate
- (void)emojiKeyboardEmojiEditButtonDown
{
    TLExpressionViewController *expressionVC = [[TLExpressionViewController alloc] init];
    UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController:expressionVC];
    [self presentViewController:navC animated:YES completion:nil];
}

- (void)emojiKeyboardMyEmojiEditButtonDown
{
    TLMyExpressionViewController *myExpressionVC = [[TLMyExpressionViewController alloc] init];
    UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController:myExpressionVC];
    [self presentViewController:navC animated:YES completion:nil];
}

//MARK: TLChatViewControllerProxy
- (void)didClickedUserAvatar:(TLUser *)user
{
    [[HSNetworkAdapter adapter] getUserDetailInfoWithUserId:user.userID finishBlock:^(HSStudentUserInfo *studUserInfo) {
        if ([self.partner chat_userType] == TLChatUserTypeUser) {
            [HSUIManager openUserDetailsFromPersonalChat:studUserInfo navigationController:self.navigationController];
        } else {
            [HSUIManager openUserDetails:studUserInfo navigationController:self.navigationController];
        }
    } failed:^(NSError *error) {
        
    }];
    
}

- (void)didClickedImageMessages:(NSArray *)imageMessages atIndex:(NSInteger)index
{
    NSMutableArray *data = [[NSMutableArray alloc] init];
    for (TLMessage *message in imageMessages) {
        NSURL *url;
        if ([(TLImageMessage *)message imagePath]) {
            NSString *imagePath = [NSFileManager pathUserChatImage:[(TLImageMessage *)message imagePath]];
            url = [NSURL fileURLWithPath:imagePath];
        }
        else {
            url = TLURL([(TLImageMessage *)message imageURL]);
        }
  
        MWPhoto *photo = [MWPhoto photoWithURL:url];
        [data addObject:photo];
    }
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithPhotos:data];
    [browser setDisplayNavArrows:YES];
    [browser setCurrentPhotoIndex:index];
    UINavigationController *broserNavC = [[UINavigationController alloc] initWithRootViewController:browser];
    [self presentViewController:broserNavC animated:NO completion:nil];
}
@end
