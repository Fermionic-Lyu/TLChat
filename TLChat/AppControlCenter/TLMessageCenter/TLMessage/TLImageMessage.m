//
//  TLImageMessage.m
//  TLChat
//
//  Created by libokun on 16/3/28.
//  Copyright © 2016年 李伯坤. All rights reserved.
//

#import "TLImageMessage.h"
#import "TLMacros.h"
#import <MJExtension/MJExtension.h>

@implementation TLImageMessage
@synthesize imagePath = _imagePath;
@synthesize imageURL = _imageURL;
@synthesize thumbnailImageURL = _thumbnailImageURL;
@synthesize thumbnailImagePath = _thumbnailImagePath;

- (id)init
{
    if (self = [super init]) {
        [self setMessageType:TLMessageTypeImage];
    }
    return self;
}

#pragma mark -
- (NSString *)thumbnailImagePath
{
    if (_thumbnailImagePath == nil) {
        _thumbnailImagePath = [self.content objectForKey:@"path"];
    }
    return _thumbnailImagePath;
}

- (NSString *)imagePath
{
    if (_imagePath == nil) {
        _imagePath = [self.content objectForKey:@"path"];
    }
    return _imagePath;
}
- (void)setImagePath:(NSString *)imagePath
{
    _imagePath = imagePath;
    [self.content setObject:imagePath forKey:@"path"];
}



- (NSString *)imageURL
{
    if (_imageURL == nil) {
        _imageURL = [self.content objectForKey:@"url"];
    }
    return _imageURL;
}

- (NSString *)thumbnailImageURL
{
    if (_thumbnailImageURL == nil) {
        _thumbnailImageURL = [self.content objectForKey:@"thumbURL"];
    }
    
    return _thumbnailImageURL;
}
- (void)setImageURL:(NSString *)imageURL
{
    _imageURL = imageURL;
    [self.content setObject:imageURL forKey:@"url"];
}

- (void)setThumbnailImageURL:(NSString *)thumbnailImageURL
{
    _thumbnailImageURL = thumbnailImageURL;
    [self.content setObject:thumbnailImageURL forKey:@"thumbURL"];
}

- (CGSize)imageSize
{
    CGFloat width = [[self.content objectForKey:@"w"] doubleValue];
    CGFloat height = [[self.content objectForKey:@"h"] doubleValue];
    return CGSizeMake(width, height);
}
- (void)setImageSize:(CGSize)imageSize
{
    [self.content setObject:[NSNumber numberWithDouble:imageSize.width] forKey:@"w"];
    [self.content setObject:[NSNumber numberWithDouble:imageSize.height] forKey:@"h"];
}

#pragma mark -
- (TLMessageFrame *)messageFrame
{
    if (kMessageFrame == nil) {
        kMessageFrame = [[TLMessageFrame alloc] init];
        kMessageFrame.height = 20 + (self.showTime ? 30 : 0) + (self.showName ? 15 : 0);

        CGSize imageSize = self.imageSize;
        if (CGSizeEqualToSize(imageSize, CGSizeZero)) {
            kMessageFrame.contentSize = CGSizeMake(100, 100);
        }
        else if (imageSize.width > imageSize.height) {
            CGFloat height = MAX_MESSAGE_IMAGE_WIDTH * imageSize.height / imageSize.width;
            height = height < MIN_MESSAGE_IMAGE_WIDTH ? MIN_MESSAGE_IMAGE_WIDTH : height;
            kMessageFrame.contentSize = CGSizeMake(MAX_MESSAGE_IMAGE_WIDTH, height);
        }
        else {
            CGFloat width = MAX_MESSAGE_IMAGE_WIDTH * imageSize.width / imageSize.height;
            width = width < MIN_MESSAGE_IMAGE_WIDTH ? MIN_MESSAGE_IMAGE_WIDTH : width;
            kMessageFrame.contentSize = CGSizeMake(width, MAX_MESSAGE_IMAGE_WIDTH);
        }
        
        kMessageFrame.height += kMessageFrame.contentSize.height;
    }
    return kMessageFrame;
}

- (NSString *)conversationContent
{
    return [NSString stringWithFormat:@"[%@]",NSLocalizedString(@"PHOTO_MESSAGE", nil)];
}

- (NSString *)messageCopy
{
    return [self.content mj_JSONString];
}

@end
