//
//  ViewController.m
//  testOpenCV
//
//  Created by Jeavil on 15/12/14.
//  Copyright © 2015年 topplusvision. All rights reserved.
//
#define DOCUMENT_PATH   NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject
#define WIDTH           [UIScreen mainScreen].bounds.size.width
#define HEIGHT          [UIScreen mainScreen].bounds.size.height
#define Scroll_Width    WIDTH
#define Scroll_height   HEIGHT / 3 * 2
#define ShowView_Height     (WIDTH / 3) * 4

#define eye_btn_width WIDTH / 8
#define album_camera_btn_width WIDTH / 6
#import "ViewController.h"
#import "beautifyPupil.h"
#import "SVProgressHUD.h"
#import "ListViewController.h"

@interface ViewController ()<UIScrollViewDelegate>
{

    NSString *currentEyePath;
    NSString *currentEyePath_mask;
    
    float eyeAlpha;
    float eyeScale;
    
    UIImage *image;
    
    UIScrollView *scrollView;
    CGPoint lastPointOffset;
    
    UISlider *aSlider;
    UISlider *ScaleSlider;
    NSUserDefaults *U_De;
}

@property(nonatomic, assign)CGFloat currentScale;

@property (nonatomic, strong)UIImageView *showView;//显示视图

@property (nonatomic, strong)NSMutableArray *bpArray;

@property (nonatomic, strong)UIButton *OpenGlassesButton;

@property (nonatomic, strong)UIView *boardViewForPupils;

@property (nonatomic, strong)UIImagePickerController *pickerC;
@property (weak, nonatomic) IBOutlet UILabel *hintLabel;

@property (nonatomic, strong)beautifyPupil *pupil;

@property (nonatomic, strong)UILabel *alphaLabel;
@end
static BOOL isMove = YES;
static BOOL haveBackImage = NO;
@implementation ViewController

- (NSMutableArray *)bpArray{
    if (!_bpArray) {
        _bpArray = [[NSMutableArray alloc]init];
        NSFileManager *fm = [NSFileManager defaultManager];
        NSString *Bpres_path = [[NSBundle mainBundle]pathForResource:@"BPRes" ofType:@"bundle"];
        NSArray *contens = [fm contentsOfDirectoryAtPath:Bpres_path error:nil];
        for (NSString *itemName in contens) {
            if ([[itemName pathExtension] isEqualToString:@"bp"]) {
                NSString *item_path = [NSString stringWithFormat:@"%@/%@",Bpres_path,itemName];
                [_bpArray addObject:item_path];
            }
        }
        
        if (_bpArray.count > 8) {
            for (int i = 0; i < 4; i++) {
                int ArrCount = _bpArray.count-1;
                NSString *tempStr = _bpArray[ArrCount];
                [_bpArray removeObjectAtIndex:ArrCount];
                [_bpArray insertObject:tempStr atIndex:0];
            }
        }
    }
    return _bpArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    U_De = [NSUserDefaults standardUserDefaults];
    _pupil = [[beautifyPupil alloc]init];
    [self creatListButton];
    [_pupil SDKInit];
    [_pupil enableHD:YES];
    
#if RELEASE == 1
    [_pupil saveLogToFile:nil];
#endif

#ifdef Top
    [_pupil setHighLight:false];
#else
    [_pupil setHighLight:true];
#endif
    [self InitBaseView];
    
}

- (void)TestForEye{
//    for (int i = 0; i < 100; i++) {
//        @autoreleasepool {
//            
//        
//        UIImage *img = [[UIImage alloc] init];
//        BOOL isOK;
//        isOK = [_pupil passInUIImage:image andEyeImgPath:currentEyePath alpha:eyeAlpha andReceivedimg:&img andScale:eyeScale];
//        
//        NSLog(@"cout ---->%d",i);
//        }
//    }
//    
}

//创建列表的按钮
-(void)creatListButton{
    UIButton *listButton =[[UIButton alloc] initWithFrame:CGRectMake(WIDTH / 2 - album_camera_btn_width / 2+150, HEIGHT - eye_btn_width / 2 * 3 - album_camera_btn_width, album_camera_btn_width, album_camera_btn_width)];
    [listButton setTitle:@"列表" forState:UIControlStateNormal];
    listButton.backgroundColor = [UIColor blackColor];
    [listButton addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:listButton];
}
//进入列表的点击事件
-(void)btnPressed:(id)sender{
    UIStoryboard *main =[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ListViewController*listVC ;
    UIBarButtonItem *backItem=[[UIBarButtonItem alloc]init];
    listVC = (ListViewController *)[main instantiateViewControllerWithIdentifier:@"ListViewController"];
    backItem.title=@"美瞳列表";
    listVC.usingImage =image;
    listVC.pupil = _pupil;
    self.navigationItem.backBarButtonItem = backItem;
    [self.navigationController pushViewController:listVC animated:YES];
}

#pragma mark -- UI 相关 初始化加载
/**
 *@brief 初始化美瞳实例 创建显示scrollview 和 imageview 从UserDefaults读取大小颜色参数
 *
 *
 */
- (void)InitBaseView{
    
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
        [self savePupilDataForUserDefaults];
    }
    
    [self creatScrollViewAndImageView];
    
    [self creatAlbumButton];
    
    [self creatPupilList];
 


#ifdef Top
   // eyeScale = 1.0;
    if (!Alpha) {
        eyeAlpha = 0.5;
    }
    [self creatAlphaAndScale];
#else
    //[self creatAlphaAndScale];
#endif

}

/**
 * 创建 ScrollView 和 imageView
 */
- (void)creatScrollViewAndImageView{

    scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 20, Scroll_Width,Scroll_height)];
    
    scrollView.contentSize = CGSizeMake(Scroll_Width + 5, Scroll_height + 5);
    
    scrollView.showsHorizontalScrollIndicator = FALSE;
    
    scrollView.showsVerticalScrollIndicator = FALSE;
    
    scrollView.maximumZoomScale = 3;
    
    scrollView.minimumZoomScale = 1;
    
    scrollView.delegate = self;
    
    [self.view addSubview:scrollView];
    
    //image = [UIImage imageNamed:@"IMG_9269.JPG"];
    
    //image = [UIImage imageNamed:@"e50.jpg"];
    
    _showView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, ShowView_Height)];
    
    _showView.contentMode = UIViewContentModeScaleAspectFit;
    
    _showView.userInteractionEnabled = YES;
    
    _showView.image = image;
    
//    UIPinchGestureRecognizer *pin = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinchClick:)];
//    
//    [_showView addGestureRecognizer:pin];
    
    _currentScale = 1;
    
    [scrollView addSubview:_showView];
}

#pragma mark -- 滑动条

/**
 * 创建滑动条
 *
 */
- (void)creatAlphaAndScale{
    
    UILabel *scaleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, Scroll_height + 30, 50, 20)];
    
    scaleLabel.font = [UIFont systemFontOfSize:14];
    
    //scaleLabel.text = @"大小";
    
    scaleLabel.text = NSLocalizedString(@"大小",@"");
    
    [self.view addSubview:scaleLabel];
    
    UILabel *alphaLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, Scroll_height + 50, 50, 30)];
    
    alphaLabel.font = [UIFont systemFontOfSize:15];
    
    //alphaLabel.text = @"颜色";
    
    alphaLabel.text = NSLocalizedString(@"颜色",@"");
    
    [self.view addSubview:alphaLabel];
    
    
    aSlider = [[UISlider alloc]initWithFrame:CGRectMake(55, Scroll_height + 55, WIDTH / 3 * 2, 18)];
    
    [aSlider setThumbImage:[UIImage imageNamed:@"circle1.png"] forState:UIControlStateNormal];
    
    aSlider.maximumValue = 1.0;
    
    aSlider.minimumValue = 0;
    
    aSlider.value = eyeAlpha;
    
    
    aSlider.continuous = NO;
    
    [self.view addSubview:aSlider];
    
    [aSlider addTarget:self action:@selector(changeAlpha:) forControlEvents:UIControlEventValueChanged];
    
    ScaleSlider = [[UISlider alloc]initWithFrame:CGRectMake(55, Scroll_height + 30, WIDTH / 3 * 2, 18)];
    
    [ScaleSlider setThumbImage:[UIImage imageNamed:@"circle1.png"] forState:UIControlStateNormal];
    
    ScaleSlider.maximumValue = 1.0;
    
    ScaleSlider.minimumValue = 0.8;
    
    ScaleSlider.value = eyeScale;
    
    
    ScaleSlider.continuous = NO;
    
    [self.view addSubview:ScaleSlider];
    
    [ScaleSlider addTarget:self action:@selector(changeScale:) forControlEvents:UIControlEventValueChanged];
    
    
    //显示alpha值
    alphaLabel = [[UILabel alloc]initWithFrame:CGRectMake(55 + (WIDTH / 3 * 2), Scroll_height + 30, 80, 20)];
    
    [self.view addSubview:alphaLabel];
    
    
}

#pragma mark album and camera btn
- (void)creatAlbumButton{
    //   NSArray *btnNames = @[@"拍摄",@"相册"];
    for (int i = 0; i < 1; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[UIImage imageNamed:@"232.232拍照"] forState:UIControlStateNormal];
        btn.tag = 100 + i;
        //    [btn setTitle:btnNames[i + 1] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(selectImg:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        btn.titleLabel.adjustsFontSizeToFitWidth = YES;
        btn.frame = CGRectMake(WIDTH / 2 - album_camera_btn_width / 2, HEIGHT - eye_btn_width / 2 * 3 - album_camera_btn_width, album_camera_btn_width, album_camera_btn_width);
        [self.view addSubview:btn];
    }
    //眼镜按钮
//    _OpenGlassesButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    _OpenGlassesButton.frame = CGRectMake(WIDTH - (eye_btn_width), HEIGHT - eye_btn_width / 2 * 3, eye_btn_width , eye_btn_width / 2 * 3);
//    [_OpenGlassesButton setImage:[UIImage imageNamed:@"眼镜菜单"] forState:UIControlStateNormal];
//    [_OpenGlassesButton addTarget:self action:@selector(openGlass:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:_OpenGlassesButton];
}

#pragma mark 创建瞳片栏
/***/
- (void)creatPupilList{
    CGFloat intervalForBtn = WIDTH / 18;
    _boardViewForPupils = [[UIView alloc]initWithFrame:CGRectMake(WIDTH, HEIGHT - (eye_btn_width) / 2 * 3, WIDTH, eye_btn_width / 2 * 3)];
    _boardViewForPupils.backgroundColor = [UIColor whiteColor];
    
    NSLog(@"self.bpArray.count==%lu",(unsigned long)self.bpArray.count);
    
    UIScrollView *TscrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, HEIGHT - (eye_btn_width) / 2 * 3, WIDTH, eye_btn_width / 2 * 3)];
    
    TscrollView.contentSize = CGSizeMake(eye_btn_width * self.bpArray.count * 2, eye_btn_width / 2 * 3);
    
    
    for (int i = 0; i < self.bpArray.count ; i++) {
        NSString *icon_path = [_pupil GetRealPictureForPath:self.bpArray[i]];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = 300 + i;
        [btn setImage:[UIImage imageWithContentsOfFile:icon_path] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(eyeClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = CGRectMake(intervalForBtn + i * (eye_btn_width * 2)+4, intervalForBtn / 2, eye_btn_width, eye_btn_width);
        [TscrollView addSubview:btn];
    }
    [self.view addSubview:TscrollView];
    for (int i = 1; i < 54; i++) {
        UIView *blueView = [[UIView alloc]init];
        blueView.backgroundColor = [UIColor blackColor];
        blueView.frame = CGRectMake(i * (eye_btn_width * 2), intervalForBtn / 2, 1, eye_btn_width);
        [TscrollView addSubview:blueView];
    }
}

#pragma mark -- 视图响应

/**
 *  改变透明度
 */
- (void)changeAlpha:(UISlider *)sender{
    //显示alpha
    dispatch_async(dispatch_get_main_queue(), ^{
        _alphaLabel.text = [NSString stringWithFormat:@"%f",sender.value];
    });
    
    eyeAlpha = sender.value;
    if (haveBackImage) {
    if (currentEyePath) {
        
        [self savePupilDataForUserDefaults];
        UIImage *img = [[UIImage alloc] init];
        BOOL isOK;
        isOK = [_pupil passInUIImage:image andEyeImgPath:currentEyePath alpha:eyeAlpha andReceivedimg:&img andScale:eyeScale];
        if (!isOK) {
            [SVProgressHUD showErrorWithStatus:@"未检测到瞳孔，请选择正脸清晰的照片"];
        }
        _showView.image = img;
    }
        
    }
}

/**
 *  改变大小
 */
- (void)changeScale:(UISlider *)sender{
       eyeScale = sender.value;
    if (haveBackImage) {

    if (currentEyePath)
    {
        
        [self savePupilDataForUserDefaults];
        UIImage *img = [[UIImage alloc] init];
        BOOL isOK;
        isOK =  isOK = [_pupil passInUIImage:image andEyeImgPath:currentEyePath alpha:eyeAlpha andReceivedimg:&img andScale:eyeScale];
        if (!isOK) {
            [SVProgressHUD showErrorWithStatus:@"未检测到瞳孔，请选择正脸清晰的照片"];
        }
        _showView.image = img;
    }
        
    }
}


/**
 *  open pupils list
 */
- (void)openGlass:(UIButton *)sender{
    [UIView animateWithDuration:1 animations:^{
        CGRect rect = _boardViewForPupils.frame;
        rect.origin.x -= WIDTH;
        _boardViewForPupils.frame = rect;
        
        CGRect rect1 = _OpenGlassesButton.frame;
        rect1.origin.x -= WIDTH;
        _OpenGlassesButton.frame = rect1;
    }];
}

/**选中相册或手机*/
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
    
    if (!_pickerC) {
        _pickerC = [[UIImagePickerController alloc]init];
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
        
        _pickerC.sourceType = sourcheType;
        _pickerC.delegate = self;
    }
    //picker.allowsEditing = YES;
    [self presentViewController:_pickerC animated:NO completion:nil];
    
}

//美瞳点击
- (void)eyeClick:(UIButton *)sender{
    if (haveBackImage) {

    NSString *srcEye_Path = self.bpArray[sender.tag - 300];
    currentEyePath = srcEye_Path;
    UIImage *img = [[UIImage alloc] init];
    BOOL isOK;
    isOK = [_pupil passInUIImage:image andEyeImgPath:srcEye_Path alpha:eyeAlpha andReceivedimg:&img andScale:eyeScale];
    //UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil);
    //获取双眼的位置
    NSArray *arr = [_pupil GetPupilCenterLeftPoint];
    //NSLog(@"arr = %@，image.w=%f,image.h=%f",arr,img.size.width,img.size.height);
    
    if (isMove) {
       // [self MoveEyeToCenter:arr :img.size];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _showView.image = img;
        //_showView.contentMode = UIViewContentModeScaleAspectFit;
    });
    if (!isOK) {
        [SVProgressHUD showErrorWithStatus:@"未检测到瞳孔，请选择正脸清晰的照片"];
    }
    [self TestForEye];
        
    }
}

#pragma mark PickerController delegate
/**
 * 从相册选中图片
 */
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *tempImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
    NSLog(@"dic=%@",(NSDictionary *)[info objectForKey:UIImagePickerControllerMediaMetadata]);
    image = tempImage;
    _showView.image = image ;
    [_pupil changeImageIfNeed];
    [_pickerC.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
    NSString *Alpha = [U_De objectForKey:@"eyeAlpha"];
    
    NSString *Scale = [U_De objectForKey:@"eyeScale"];
    
    NSLog(@"alp=%@,sca=%@",Alpha,Scale);
    eyeAlpha = [Alpha floatValue];
    eyeScale = [Scale floatValue];
    aSlider.value = eyeAlpha;
    ScaleSlider.value = eyeScale;

    isMove = YES;
    haveBackImage = YES;
    _hintLabel.alpha = 0;
}

//告诉scrollview要缩放的是哪个子控件
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _showView;
}

#pragma mark --   私有函数 移动图片到屏幕中心
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
        _showView.transform = CGAffineTransformMakeScale(tranformScale, tranformScale);
        scrollView.contentSize = CGSizeMake(_showView.frame.size.width, _showView.frame.size.height);
        float width = _showView.frame.size.width;
        float height = _showView.frame.size.height;
        _showView.center = CGPointMake(width / 2, height / 2);
        scrollView.contentOffset = CGPointMake(Intervl_width + (tranformScale - 1) * imageViewSize.width / 2, Intervl_width + (tranformScale - 1) * imageViewSize.width / 2);
        //NSLog(@"图片中心坐标 x = %f y= % f\n,双眼中心坐标 x = %f y = %f\nscale = %f,tS=%f",imageCenter_x,imageCenter_y,eyeCenter_x,eyeCenter_y,tranformScale,imgeTempScale);
    }];
    
    isMove = NO;
}

#pragma mark -- 判断图片数据类型
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

#pragma mark -- 保存美瞳大小和颜色亮度
- (void)savePupilDataForUserDefaults{

    [U_De setObject:[NSString stringWithFormat:@"%f",eyeScale] forKey:@"eyeScale"];
    
    [U_De setObject:[NSString stringWithFormat:@"%f",eyeAlpha] forKey:@"eyeAlpha"];
    
    NSLog(@"保存美瞳数据");
}




@end
