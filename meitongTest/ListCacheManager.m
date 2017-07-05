//
//  ListCacheManager.m
//  beautifyPupil
//
//  Created by LucienLi on 16/9/20.
//  Copyright © 2016年 ningzoone. All rights reserved.
//

#import "ListCacheManager.h"

@implementation ListCacheManager

#pragma mark - 保存美瞳图片到本地
+ (BOOL)savePupilImageToCache:(UIImage *)image {
    //创建美瞳存储路径
    NSString *pupilPath = [NSString stringWithFormat:@"%@/com.kede.user/3DTryOn/pupil/", NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES).firstObject];
    if ([[NSFileManager defaultManager] fileExistsAtPath:pupilPath]) {
        NSLog(@"美瞳存在 移除 ----");
        [[NSFileManager defaultManager] removeItemAtPath:pupilPath error:nil];
    }
    
    if ([[NSFileManager defaultManager] createDirectoryAtPath:pupilPath withIntermediateDirectories:YES attributes:nil error:nil]) {
        NSString *cachePath = [pupilPath stringByAppendingPathComponent:@"tmpImage"];
        NSData *data = UIImageJPEGRepresentation(image, 1.0f);
        if (data.length > 0) {
            NSLog(@"美瞳保存本地有内容 --- ");
        }
        return [data writeToFile:cachePath atomically:YES];
    }
    return NO;
}

+ (UIImage *)pupilImageInCache {
    NSString *pupilPath = [NSString stringWithFormat:@"%@/com.kede.user/3DTryOn/pupil/", NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES).firstObject];
    NSString *cachePath = [pupilPath stringByAppendingPathComponent:@"tmpImage"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
        UIImage *image = [UIImage imageWithContentsOfFile:cachePath];
        return image;
    }
    NSLog(@"美瞳空的缓存图片");
    return nil;
}


@end
