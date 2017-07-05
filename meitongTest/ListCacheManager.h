//
//  ListCacheManager.h
//  beautifyPupil
//
//  Created by wangyue on 16/9/26.
//  Copyright © 2016年 ningzoone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ListCacheManager : NSObject

//美瞳试戴存储
+ (BOOL)savePupilImageToCache:(UIImage *)image;
//获取美瞳试戴路径
+ (UIImage *)pupilImageInCache;

@end
