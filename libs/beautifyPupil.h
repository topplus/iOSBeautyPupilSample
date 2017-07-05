//
//  beautifyPupil.h
//  beautifyPupil
//
//  Created by ningzoone on 15/12/8.
//  Copyright © 2015年 ningzoone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface beautifyPupil : NSObject

/**初始化*/
- (BOOL)SDKInit;

/**
 *@brief 加载美瞳瞳片
 *
 *@param eyeImgPath 美瞳文件路径
 *
 *@param Receivedimg:返回图片
 *
 *@param alpha:颜色调节
 *
 *@param scale:大小调节
 *
 */
- (bool) passInUIImage:(UIImage *)image andEyeImgPath:(NSString *)eyeImgPath alpha:(float)alpha andReceivedimg:(UIImage **)receivedImg andScale:(float)scale;


/**
 *@brief 获取眼部中心坐标
 *
 *return arr[0]:左眼中心的x轴坐标，arr[1]:左眼中心的y轴坐标
 *
 *       arr[2]:右眼中心的x轴坐标，arr[3]右眼中心的y轴坐标
 */
- (NSArray *)GetPupilCenterLeftPoint;


/**切换人脸图片时调用*/
- (void)changeImageIfNeed;

/**
 *@brief 用户认证
 *
 *@param Client_id :client_id
 *
 *@param Client_secret :client_secret
 */
- (void)setLicense:(NSString *)Client_id andSecret:(NSString *)Clicent_secret;

/**
 *@brief 获取美瞳实物图片
 *
 *@param path 美瞳文件的路径
 *
 */
- (NSString *)GetRealPictureForPath:(NSString *)path;

/**
 *@brief 获取美瞳资源信息
 *
 *@param path 美瞳文件的路径
 *
 */
- (NSDictionary *)GetInfo:(NSString *)path;

/**设置高光*/
- (void)setHighLight:(bool)Hight;

/**
 * @brief 保存日志
 *
 *
 */
- (void)saveLogToFile:(NSString *)filePath;

/**设置高清图片，YES为开启，默认为NO*/
- (void)enableHD:(BOOL)isHD;
@end
