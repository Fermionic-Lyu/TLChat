//
//  TLGroupDataLoader.h
//  TLChat
//
//  Created by Frank Mao on 2017-12-05.
//  Copyright © 2017 李伯坤. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TLGroup.h"
#import <UIKit/UIKit.h>

@interface TLGroupDataLoader : NSObject

@property (strong, nonatomic) NSArray<PFObject *> *courses;

+ (TLGroupDataLoader *)sharedGroupDataLoader;
    
+ (NSString *)makeCourseDialogKey:(PFObject *)course;

- (void)reloadCourses;

- (void)resetCourses;

- (NSArray<TLUser *> *)loadGroupsData;

- (HSCourseInfo *)getCourseInfoByGroupID:(NSString *)groupID;

- (NSInteger)getCourseColorWithCourseId:(NSString *)courseId;

- (void)recreateLocalDialogsForGroupsWithCompletionBlock:(void(^)(void))completionBlcok;

- (UIImage *)generateGroupAvatarWithGroupName:(NSString *)groupName;

- (void)createCourseDialogWithLatestMessage:(TLGroup *)group completionBlock:(void(^)(void))completionBlock;

@end
