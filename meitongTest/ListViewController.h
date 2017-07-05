//
//  ListViewCntroller.h
//  beautifyPupil
//
//  Created by wangyue on 16/9/26.
//  Copyright © 2016年 ningzoone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "beautifyPupil.h"
@interface ListViewController : UIViewController
//用户设置图片/本地图片
@property(nonatomic,strong)UIImage *usingImage;

@property (nonatomic, strong)beautifyPupil *pupil;
@end
