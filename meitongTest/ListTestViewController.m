//
//  ListTestViewController.m
//  beautifyPupil
//
//  Created by wangyue on 16/9/27.
//  Copyright © 2016年 ningzoone. All rights reserved.
//

#import "ListTestViewController.h"
#import "beautifyPupil.h"
#import "SVProgressHUD.h"
#define WIDTH           [UIScreen mainScreen].bounds.size.width
#define HEIGHT          [UIScreen mainScreen].bounds.size.height
#define Scroll_Width    WIDTH
#define Scroll_height   HEIGHT / 3 * 2
#define ShowView_Height     (WIDTH / 3) * 4

#define eye_btn_width WIDTH / 8
#define album_camera_btn_width WIDTH / 6
@interface ListTestViewController ()<UIScrollViewDelegate>{
    float eyeAlpha;
    float eyeScale;
    UIImage *image;
    
    UIScrollView *scrollView;
    
    NSString *currentEyePath;
    
    CGPoint lastPointOffset;
}
@property (nonatomic, strong)UIImageView *showView;//显示视图

@property(nonatomic, assign)CGFloat currentScale;

@property (nonatomic, strong)UIView *boardViewForPupils;

@property (nonatomic, strong)NSMutableArray *bpArray;

@property (weak, nonatomic) IBOutlet UIImageView *testImage;

@end
static BOOL isMove = YES;
@implementation ListTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   // pupil = [[beautifyPupil alloc]init];
    [self creatDetailPupilList];
    [self creatScrollViewAndImageView];
  //  [pupil SDKInit];
    //[pupil changeImageIfNeed];
    //self.testImage.image =_cachePupilImage;
    //self.testImage.contentMode =UIViewContentModeScaleAspectFill;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark 创建瞳片栏
/***/
- (void)creatDetailPupilList{
    CGFloat intervalForBtn = WIDTH / 18;
    _boardViewForPupils = [[UIView alloc]initWithFrame:CGRectMake(0, HEIGHT - (eye_btn_width) / 2 * 3, WIDTH, eye_btn_width / 2 * 3)];
    _boardViewForPupils.backgroundColor = [UIColor whiteColor];
    for (int i = 0; i < 4 ; i++) {
        NSString *icon_path = [_pupil GetRealPictureForPath:self.bpArray[i]];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = 300 + i;
        [btn setImage:[UIImage imageWithContentsOfFile:icon_path] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(eyeClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = CGRectMake(intervalForBtn + i * (eye_btn_width * 2), intervalForBtn / 2, eye_btn_width, eye_btn_width);
        [_boardViewForPupils addSubview:btn];
    }
    for (int i = 1; i < 4; i++) {
        UIView *blueView = [[UIView alloc]init];
        blueView.backgroundColor = [UIColor blackColor];
        blueView.frame = CGRectMake(i * (eye_btn_width * 2), intervalForBtn / 2, 1, eye_btn_width);
        [_boardViewForPupils addSubview:blueView];
    }
    [self.view addSubview:_boardViewForPupils];
}
//加载美瞳数据
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
    }
    return _bpArray;
}
//美瞳点击
- (void)eyeClick:(UIButton *)sender{
    NSString *srcEye_Path = self.bpArray[sender.tag - 300];
    currentEyePath = srcEye_Path;
    UIImage *img = [[UIImage alloc] init];
    BOOL isOK;
    eyeAlpha=0.5;
    eyeScale =1.0;
    isOK = [_pupil passInUIImage:_originalImage andEyeImgPath:srcEye_Path alpha:eyeAlpha andReceivedimg:&img andScale:eyeScale];
    //获取双眼的位置
    NSArray *arr = [_pupil GetPupilCenterLeftPoint];
    //NSLog(@"arr = %@，image.w=%f,image.h=%f",arr,img.size.width,img.size.height);
    if (isMove) {
        // [self MoveEyeToCenter:arr :img.size];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        _showView.image = img;
        NSLog(@"imge=%@",img);
    });
    if (!isOK) {
        [SVProgressHUD showErrorWithStatus:@"未检测到瞳孔，请选择正脸清晰的照片"];
    }
    
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
    
    image = _cachePupilImage;
    
    //image = [UIImage imageNamed:@"e50.jpg"];
    
    _showView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, ShowView_Height)];
    
    _showView.contentMode = UIViewContentModeScaleAspectFit;
    
    _showView.userInteractionEnabled = YES;
    
    _showView.image = image;
//    
//    UIPinchGestureRecognizer *pin = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinchClick:)];
//    
//    [_showView addGestureRecognizer:pin];
    
    _currentScale = 1;
    
    [scrollView addSubview:_showView];
}

//告诉scrollview要缩放的是哪个子控件
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _showView;
}
@end
