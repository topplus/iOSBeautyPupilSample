//
//  ListViewControllerCell.h
//  beautifyPupil
//
//  Created by wangyue on 16/9/26.
//  Copyright © 2016年 ningzoone. All rights reserved.
//

#import "ListViewControllerCell.h"

#import "ListViewController.h"
@interface ListViewControllerCell ()
@property (strong, nonatomic) NSString *lensName;

@end

@implementation ListViewControllerCell
static int count = 0;
-(instancetype)initWithFrame:(CGRect)frame
{
    if ([super initWithFrame:frame]) {
        self.clipsToBounds = YES;
        self.personImageView = [[UIImageView alloc] init];
        [self addSubview:self.personImageView];
        self.lensNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, ScreenWidth - 20, ScreenWidth, 20)];
        self.lensNameLabel.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.lensNameLabel];
    }
    return self;
}

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    if (!backgroundImage) {
        self.personImageView.image = [UIImage imageNamed:@"person1.jpg"];
        return;
    }
    _backgroundImage = backgroundImage;
    self.personImageView.image = backgroundImage;
}


- (void)showWithLens:(NSString *)lensName beautityPupil:(beautifyPupil *)pupil
{
    @autoreleasepool {
    float eyeAlpha,eyeScale;
        
        NSUserDefaults *U_De = [NSUserDefaults standardUserDefaults];
        
    NSString *Alpha = [U_De objectForKey:@"eyeAlpha"];
        
    NSString *Scale = [U_De objectForKey:@"eyeScale"];
        
    if (Alpha) {
            eyeAlpha = [Alpha floatValue];
    }else{
        eyeAlpha = 0.5;
    }
        
    if (Scale) {
        eyeScale = [Scale floatValue];
    }else{
        eyeScale = 1.0;

    }
    UIImage *img = [[UIImage alloc] init];
    NSString *lensPath = lensName;
    if (!self.backgroundImage) {
        self.backgroundImage = [UIImage imageNamed:@"person1.jpg"];
    }
    BOOL ret = [pupil passInUIImage:self.backgroundImage andEyeImgPath:lensPath alpha:eyeAlpha andReceivedimg:&img andScale:eyeScale];
    NSLog(@"Jishu:%d%@",count,ret?@"试戴成功":@"试戴失败");
    count++;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.personImageView.image = img;
    });
    self.returnImage = [img copy];
    }
}

- (void)showWithLens:(NSString *)lensName beautityPupil:(beautifyPupil *)pupil completionBlock:(void(^)(BOOL ret))block
{
    //    self.lensName = lensName;
    UIImage *img = [[UIImage alloc] init];
    //    NSString *lensPath = [[NSBundle mainBundle] pathForResource:lensName ofType:@"bp"];
    NSString *lensPath = lensName;
    BOOL ret = [pupil passInUIImage:[UIImage imageNamed:@"person1.jpg"] andEyeImgPath:lensPath alpha:1.0f andReceivedimg:&img andScale:1.0f];
    NSLog(@"Jishu:%d%@",count,ret?@"试戴成功":@"试戴失败");
    count++;
    if (block) {
        block(ret);
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.personImageView.image = img;
    });
    
}


- (void)doUpdateLensWithBeautityPupil:(beautifyPupil *)pupil
{
    UIImage *img = [[UIImage alloc] init];
    NSString *lensPath = [[NSBundle mainBundle] pathForResource:self.lensName ofType:@"bp"];
    [pupil passInUIImage:[UIImage imageNamed:@"person1.jpg"] andEyeImgPath:lensPath alpha:1.0f andReceivedimg:&img andScale:1.0f];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.personImageView.image = img;
    });
}


@end
