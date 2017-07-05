//
//  ListViewCntroller.h
//  beautifyPupil
//
//  Created by wangyue on 16/9/26.
//  Copyright © 2016年 ningzoone. All rights reserved.
//


#import "ListViewController.h"
#import "ListViewControllerCell.h"
#import "beautifyPupil.h"
#import "ListCacheManager.h"


#import "ListTestViewController.h"
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
@interface ListViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>{
    
    dispatch_queue_t queue;
    CGRect rect;
    BOOL isScroll;
    
}

@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *floatLayput;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSMutableArray *bpArray;
@property (retain, nonatomic) NSMutableArray *allCells;

@property (strong, nonatomic) UIImage *cacheImage;

@property (assign, nonatomic) CGRect tmpFrame;
@property (assign, nonatomic) CGPoint tmpCenter;
@property (strong, nonatomic) UIImage *tmpImage;

@property (assign, nonatomic) CGFloat scale;
@end
static int ScrollCount = 0;
static BOOL isScrollEnd = NO;
@implementation ListViewController

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
    [self calculateCenter];
    
    self.navigationItem.title = @"美瞳";
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.floatLayput.itemSize = CGSizeMake(ScreenWidth, ScreenWidth);
    [self.collectionView registerClass:[ListViewControllerCell class] forCellWithReuseIdentifier:@"LensCell"];
    self.allCells = [NSMutableArray array];
    
    //cacheImage
    if (!self.cacheImage) {
        self.cacheImage =_usingImage;
    }
    
    queue = dispatch_queue_create("setLensModel", DISPATCH_QUEUE_SERIAL);
    
    [self collectionViewBatchUpdates];
}
-(BOOL) addCell:(ListViewControllerCell*) cell {
    if(cell == nil)
        return NO;
    for(id obj in self.allCells) {
        if(obj == cell)
            return NO;
    }
    [self.allCells addObject:cell];
    return YES;
}


#pragma mark - cell 刷新

- (void)collectionViewBatchUpdates{
    NSLog(@"总数");
    [self.collectionView performBatchUpdates:^{
        
    } completion:^(BOOL finished) {
        for (ListViewControllerCell *cell in self.allCells) {
            dispatch_async(queue, ^{
                NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];

                    [cell showWithLens:self.bpArray[indexPath.row] beautityPupil:_pupil];
        
            });
        }
    }];
}



#pragma mark ------  UITableViewDelegate | UITableViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.bpArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    ListViewControllerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LensCell" forIndexPath:indexPath];
    [self addCell:cell];
    cell.personImageView.frame = self.tmpFrame;
    //cell.personImageView.frame = CGRectMake(0, 80, ScreenWidth, 120);
    cell.personImageView.center = self.tmpCenter;
    cell.personImageView.contentMode = UIViewContentModeScaleAspectFill;

    cell.backgroundImage = self.usingImage;

    
    NSLog(@"tmpFrame----> %@",NSStringFromCGRect(self.tmpFrame));
    NSLog(@"tmpCenter----> %@",NSStringFromCGPoint(self.tmpCenter));
    
    //试戴美瞳名称
    NSString *lenPath = self.bpArray[indexPath.row];
    NSArray *arr = [lenPath componentsSeparatedByString:@"/"];
    for (NSString *name in arr) {
        if ([name containsString:@".bp"]) {
            cell.lensNameLabel.text = name;
        }
    }
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ListViewControllerCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ListTestViewController *testVC =[board instantiateViewControllerWithIdentifier:@"ListTestViewController"];
    testVC.originalImage = _usingImage;
    testVC.cachePupilImage =cell.returnImage;
    testVC.pupil = self.pupil;
    [self.navigationController pushViewController:testVC animated:YES];
    
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //isScroll = YES;
    ScrollCount++;
    NSLog(@"qqqq");
    isScrollEnd = YES;
    
}
//滑动结束后，加载美瞳
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

    //isScroll = NO;
    int temp = ScrollCount;
    float whenTime = 0.05;
    whenTime = whenTime + ( (_usingImage.size.width / 960.0) - 1) * 13 * whenTime;
    NSLog(@"间隔=%f",whenTime);
    dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(whenTime * NSEC_PER_SEC));
    dispatch_after(when, dispatch_get_main_queue(), ^{
        if (temp == ScrollCount && isScrollEnd) {
            [self collectionViewBatchUpdates];
            isScrollEnd = NO;
        }
    });
 
}
//拖动结束后，加载美瞳
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    //isScroll = NO;
    int temp = ScrollCount;
    float whenTime = 0.05;
        whenTime = whenTime + ( (_usingImage.size.width / 960.0) - 1) * 10 * whenTime;
    dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(whenTime * NSEC_PER_SEC));
    dispatch_after(when, dispatch_get_main_queue(), ^{
        if (temp == ScrollCount && isScrollEnd) {
            [self collectionViewBatchUpdates];
            isScrollEnd = NO;
        }
    });
}

//- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(8_0){

    
//}
- (void)calculateCenter
{
    NSString *lensPath = [NSString stringWithFormat:@"%@", self.bpArray[0]];
    CGSize originImageSize = _usingImage.size;
    
    UIImage *img = [[UIImage alloc] init];
   // [_pupil changeImageIfNeed];
    if (!self.cacheImage) {
        self.cacheImage = _usingImage;
    }
     NSLog(@"列表展示");
    BOOL ret = [_pupil passInUIImage:self.usingImage andEyeImgPath:lensPath alpha:0.5f andReceivedimg:&img andScale:1.0f];
    if (ret) {
        NSLog(@"列表展示处理成功----->");
        self.tmpImage = img;
        CGSize pupilImageSize = img.size;
        
       // NSLog(@"originImageSize:%@  pupilImageSize:%@",NSStringFromCGSize(originImageSize),NSStringFromCGSize(pupilImageSize));
        
        CGPoint personImageViewCenter = CGPointMake(ScreenWidth/2, ScreenWidth/2);
        
        
        NSArray *pupilPoint = [_pupil GetPupilCenterLeftPoint];
        CGFloat leftX = [pupilPoint[0] floatValue];
        CGFloat leftY = [pupilPoint[1] floatValue];
        CGFloat rightX = [pupilPoint[2] floatValue];
        CGFloat rightY = [pupilPoint[3] floatValue];
        
        CGFloat pupilLength = rightX - leftX;
        NSLog(@"pupilLength--------> %.f",pupilLength);
        //两眼间的间距设置为占屏幕宽度1/3
        float scale = (ScreenWidth/pupilLength)*0.3;
        NSLog(@"Scale=%f",scale);
        //如果按照两眼间的间距设置为屏幕的1/3 时宽度小于当前的屏幕宽度，则按屏幕充满宽度释放
        
        if (pupilImageSize.width * scale < ScreenWidth) {
            
            //scale = ScreenWidth / pupilImageSize.width;
        }
        
        //CGRect personImageViewFrame = CGRectMake(0, 0, originImageSize.width*scale, pupilImageSize.height*scale);
        CGRect personImageViewFrame = CGRectMake(0, 0, pupilImageSize.width*scale, pupilImageSize.height*scale);
        self.tmpFrame = personImageViewFrame;
        self.scale = scale;
        
        CGFloat centerX = (leftX + rightX)/2;
        CGFloat centerY = (leftY + rightY)/2;
        
        CGFloat tmpX = (centerX - pupilImageSize.width/2)*scale;
        CGFloat tmpY = (centerY - pupilImageSize.height/2)*scale;
        
        CGFloat lastX = personImageViewCenter.x - tmpX;
        CGFloat lastY = personImageViewCenter.y - tmpY;
        self.tmpCenter = CGPointMake(lastX, lastY);
        
        //NSLog(@"获取到的中心点-------------------------------> %@",NSStringFromCGPoint(self.tmpCenter));
    }
    else
    {
        //NSLog(@"列表展示处理失败---->");
    }
}


@end
