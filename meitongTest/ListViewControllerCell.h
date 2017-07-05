//
//  ListViewControllerCell.h
//  beautifyPupil
//
//  Created by wangyue on 16/9/26.
//  Copyright © 2016年 ningzoone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "beautifyPupil.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
@interface ListViewControllerCell : UICollectionViewCell

@property (strong, nonatomic)  UIImageView *personImageView;

@property (strong, nonatomic)  UILabel *lensNameLabel;

@property (strong, nonatomic) UIImage *backgroundImage;
//返回给详情界面，带美瞳的图片
@property (nonatomic, strong) UIImage *returnImage;

- (void)showWithLens:(NSString *)lensName beautityPupil:(beautifyPupil *)pupil;

- (void)showWithLens:(NSString *)lensName beautityPupil:(beautifyPupil *)pupil completionBlock:(void(^)(BOOL ret))block;

- (void)doUpdateLensWithBeautityPupil:(beautifyPupil *)pupil;

@end
