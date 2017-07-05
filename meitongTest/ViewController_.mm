//
//  ViewController.m
//  testOpenCV
//
//  Created by Jeavil on 15/12/14.
//  Copyright © 2015年 topplusvision. All rights reserved.
//
#define DOCUMENT_PATH   NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject
#define WIDTH  [UIScreen mainScreen].bounds.size.width
#define HEIGHT  [UIScreen mainScreen].bounds.size.height
#define eye_btn_width WIDTH / 8
#define album_camera_btn_width WIDTH / 6
#import "ViewController.h"
#import "beautifyPupil.h"
#import "SVProgressHUD.h"

@interface ViewController ()
{

}

@property(nonatomic, assign)CGFloat currentScale;
@end
static BOOL isMove = YES;
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

#pragma mark -- 滑动条
- (void)changeAlpha:(UISlider *)sender{
    if (currentEyePath) {
        eyeAlpha = sender.value;
        UIImage *img = [[UIImage alloc] init];
        BOOL isOK;
        isOK = [pupil passInUIImage:image andEyeImgPath:currentEyePath alpha:eyeAlpha andReceivedimg:&img andScale:eyeScale];
        if (!isOK) {
            [SVProgressHUD showErrorWithStatus:@"未检测到瞳孔，请选择正脸清晰的照片"];
        }
        imageView.image = img;
    }
}
- (void)changeScale:(UISlider *)sender{
    if (currentEyePath)
    {
        eyeScale = sender.value;
            UIImage *img = [[UIImage alloc] init];
            BOOL isOK;
            isOK =  isOK = [pupil passInUIImage:image andEyeImgPath:currentEyePath alpha:eyeAlpha andReceivedimg:&img andScale:eyeScale];
            if (!isOK) {
                [SVProgressHUD showErrorWithStatus:@"未检测到瞳孔，请选择正脸清晰的照片"];
            }
            imageView.image = img;
    }
}

- (void)addGestureToImageView{
    //捏合手势
    UIPinchGestureRecognizer *pin = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinchClick:)];
    [imageView addGestureRecognizer:pin];
    _currentScale = 1;
}

#pragma mark 手势操作
//捏合手势
- (void)pinchClick:(UIPinchGestureRecognizer *)paramSender{
    
    if (paramSender.state == UIGestureRecognizerStateEnded) {
        self.currentScale = paramSender.scale;
        lastPointOffset = scrollView.contentOffset;
    }else if(paramSender.state == UIGestureRecognizerStateBegan && self.currentScale != 0.0f){
        paramSender.scale = self.currentScale;
    }
    if (paramSender.scale !=NAN && paramSender.scale != 0.0) {
        if (paramSender.scale < 1) {
            paramSender.scale = 1;
        }
        if (paramSender.scale > 5) {
            paramSender.scale = 5;
        }
        
        float originWidth =  paramSender.view.frame.size.width;
        
        float originHeight =  paramSender.view.frame.size.height;
        
        paramSender.view.transform = CGAffineTransformMakeScale(paramSender.scale, paramSender.scale);
        
        scrollView.contentSize = CGSizeMake(paramSender.view.frame.size.width, paramSender.view.frame.size.height);
        
        float width = paramSender.view.frame.size.width;
        
        float height = paramSender.view.frame.size.height;
        
        imageView.center = CGPointMake(width / 2, height / 2);
        
          scrollView.contentOffset = CGPointMake(lastPointOffset.x + (width - originWidth) / 2,lastPointOffset.y + (height - originHeight) / 2);
        
        NSLog(@"x=%f,y=%f,width = %f scale = %f",lastPointOffset.x,lastPointOffset.y,paramSender.view.frame.size.width,paramSender.scale);
    }
}



- (void)selectImg:(UIButton *)sender {
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        NSLog(@"支持相机");
    }
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        NSLog(@"支持图库");
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
    {
        NSLog(@"支持相片库");
    }
    
    if (!_picker) {
        _picker = [[UIImagePickerController alloc]init];
        UIImagePickerControllerSourceType sourcheType;
        // picker.view.backgroundColor = [UIColor orangeColor];
        if(sender.tag==100)
        {
            sourcheType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        else if(sender.tag==101)
        {
            sourcheType = UIImagePickerControllerSourceTypeCamera;
        }
        
        _picker.sourceType = sourcheType;
        _picker.delegate = self;
    }
    //picker.allowsEditing = YES;
    [self presentViewController:_picker animated:NO completion:nil];
    
    
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{

    UIImage *tempImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
   
}

- (NSString *)typeForImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
        case 0x4D:
            return @"image/tiff";
            
    }
    return nil;
    
}

#pragma mark -- 移动图片到屏幕中心
- (void)MoveEyeToCenter:(NSArray *)points :(CGSize)imgFrame{
    CGSize imageViewSize = scrollView.frame.size;
    float imgeTempScale = imgFrame.width / imageViewSize.width;
    
    float l_x = [points[0] floatValue];
    float l_y = [points[1] floatValue];
    float r_x = [points[2] floatValue];
    float r_y = [points[3] floatValue];
    
    float eyeCenter_x = (r_x + l_x) / 2;//双眼中心 x轴的坐标
    float eyeCenter_y = (r_y + l_y) / 2;//双眼中心 y轴的坐标
    
    float imageCenter_x = imgFrame.width / 2;//图片中心 x轴坐标
    float imageCenter_y = imgFrame.height / 2;//图片中心 y轴坐标
    
    float Intervl_width = (eyeCenter_x - imageCenter_x) / imgeTempScale ;
    float Intervl_height = (imageCenter_y - eyeCenter_y) / imgeTempScale ;;
    
    //NSLog(@"inte_width = %f\n inte_height = %f\n scale = %f",Intervl_width,Intervl_height,imgeTempScale);
    float tranformScale;
    if (ABS(Intervl_width / imageViewSize.width) > ABS(Intervl_height / imageViewSize.height)) {
        tranformScale = 1.3 + ABS(Intervl_width / imageViewSize.width) ;
    }else{
        tranformScale = 1.3 + ABS(Intervl_height / imageViewSize.height) ;
    }
    self.currentScale = tranformScale;
    [UIView animateWithDuration:1.0 animations:^{
        imageView.transform = CGAffineTransformMakeScale(tranformScale, tranformScale);
        scrollView.contentSize = CGSizeMake(imageView.frame.size.width, imageView.frame.size.height);
        float width = imageView.frame.size.width;
        float height = imageView.frame.size.height;
        imageView.center = CGPointMake(width / 2, height / 2);
        scrollView.contentOffset = CGPointMake(Intervl_width + (tranformScale - 1) * imageViewSize.width / 2, Intervl_width + (tranformScale - 1) * imageViewSize.width / 2);
        //NSLog(@"图片中心坐标 x = %f y= % f\n,双眼中心坐标 x = %f y = %f\nscale = %f,tS=%f",imageCenter_x,imageCenter_y,eyeCenter_x,eyeCenter_y,tranformScale,imgeTempScale);
    }];
    
    isMove = NO;
}


@end
