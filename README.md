# iOSBeautyPupilSample使用说明

[官网](http://www.topplusvision.com)

## 开发环境说明 ##

### 开发环境说明###
Xcode7.0及以上版本


### 支持平台说明 ###
支持iOS7.0及以上版本

## 接入流程 ##
### 依赖库导入 ###

* [基础库](https://github.com/topplus/iOSBeautyPupilSample/tree/master/libs/opencv2.framework)，需添加到iOS项目中。
* [美瞳库](https://github.com/topplus/iOSBeautyPupilSample/blob/master/libs/beautifyPupil.h)，需添加到iOS项目中。
* [美瞳SDK](https://github.com/topplus/iOSBeautyPupilSample/blob/master/libs/libbeautifyPupil_SDK.a),需添加到iOS项目中。

### 授权认证 ###

调用beautifyPupil的setLicense：（NSString *）Client_id和Secret：（NSString *）Clicent_secret; 说明：申请 client_id 和 client_secret 后调用此函数获得授权。可通过商务合作邮箱sales@topplusvision.com获得client_id 和 client_secret


## 接口定义和使用说明 ##

[文档](https://github.com/topplus/iOSBeautyPupilSample/tree/master/Doc)

## 联系我们 ##

商务合作sales@topplusvision.com

媒体合作pr@topplusvision.com

技术支持support@topplusvision.com

