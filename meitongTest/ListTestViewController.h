//
//  ListTestViewController.h
//  beautifyPupil
//
//  Created by wangyue on 16/9/27.
//  Copyright © 2016年 ningzoone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "beautifyPupil.h"
@interface ListTestViewController : UIViewController
@property (strong, nonatomic) UIImage *cachePupilImage;

@property(strong,nonatomic)UIImage *originalImage;

@property (strong, nonatomic)beautifyPupil *pupil;
@end
