
###首先，我们必须明确图片的压缩其实是两个概念：

>1.“压” 是指文件体积变小，但是像素数不变，长宽尺寸不变，那么质量可能下降。
>2.“缩” 是指文件的尺寸变小，也就是像素数减少，而长宽尺寸变小，文件体积同样会减小。
#####对这个不明白的可以先看看标哥的文章。http://www.jianshu.com/p/f014d0dfeac3
###写了个小demo 这是简单的功能界面

![IMG_0097.PNG](http://upload-images.jianshu.io/upload_images/1761100-19b5f3edca5a0fa2.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
#1. 先介绍一下怎么用 -------开始
1.点击选择图片进入相册，选择图片。（iOS10以后记得添加key，不然会挂的）
![05177241-A9DA-46CA-9FFE-17FD7EC3F0EE.png](http://upload-images.jianshu.io/upload_images/1761100-8332e4f43bda81bb.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
2.点击压缩图片，图片压缩。有没有效果呢？废话
![ 2017-02-13 下午2.51.05.png](http://upload-images.jianshu.io/upload_images/1761100-a91701552255ff9f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
####压缩前2M  ----- 压缩后1M
3.可以保存到相册。
###什么时候用到压缩图片呢？
1.向服务器上传图片，如果太大，速度会很慢。
2.等等等等，其他情况。。。
###回到上文的图片的 "压" 和 "缩"  以下参考简书文章 --- iOS 图片压缩逻辑
http://www.jianshu.com/p/7533ed993130
>图片压缩的逻辑: 首先进行图片的尺寸压缩 再进行图片的质量压缩
#####一 :  图片尺寸压缩 主要分为以下几种情况 一般参照像素为 1280
a. 图片宽高均≤1280px 时，图片尺寸保持不变;
b. 宽或高均＞1280px 时 ——图片宽高比≤2，则将图片宽或者高取大的等比压缩至 1280px; ——但是图片宽高比＞2 时，则宽或者高取小的等比压缩至 1280px;
c. 宽高一个＞1280px，另一个＜1280px，-- 图片宽高比＞2 时，则宽高尺寸不变;-- 但是图片宽高比≤2 时, 则将图片宽或者高取大的等比压缩至 1280px.
#####二 :  图片质量压缩
一般图片质量都压缩在 90% 就可以了

测试结果:有时候原图片太大，有时压缩需要重复几次， 一般压缩出来的 data 再 150 - 300kb 之间 这个结果相对于大多数的 APP 已经够了。

##代码和图
```
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface SSJKitImageManager : NSObject
// 我们项目中的图片压缩参照为1280px
#define KitTargetPx 1280

/**
 *  图片压缩的逻辑类
 */


/**
 *  图片压缩的单例实现方法
 *
 *  @return 返回一个图片压缩的类
 */
+ (instancetype)shareManager;

/**
 *  将图片压缩的data返回
 *
 *  @param sourceImage 传进来要压缩的照片
 *  @param targetPx    压缩图片时参照的像素px
 *
 *  @return 返回图片压缩后的data
 */
- (NSData *)imageCompressForSize:(UIImage *)sourceImage targetPx:(NSInteger)targetPx;
@end

```
###.m文件
```

#import "SSJKitImageManager.h"

@implementation SSJKitImageManager
#pragma mark -- 返回图片压缩类的单例
+ (instancetype)shareManager
{
    static SSJKitImageManager *manager = nil;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        manager = [[SSJKitImageManager alloc] init];
    });
    return manager;
}

/**
 图片压缩的逻辑:
 一:图片尺寸压缩 主要分为以下几种情况 一般参照像素为1280
 a.图片宽高均≤1280px时，图片尺寸保持不变;
 b.宽或高均＞1280px时 ——图片宽高比≤2，则将图片宽或者高取大的等比压缩至1280px; ——但是图片宽高比＞2时，则宽或者高取小的等比压缩至1280px;
 c.宽高一个＞1280px，另一个＜1280px，--图片宽高比＞2时，则宽高尺寸不变;--但是图片宽高比≤2时,则将图片宽或者高取大的等比压缩至1280px.
 
 二:图片质量压缩
 一般图片质量都压缩在90%就可以了
 */

#pragma mark -- 图片压缩方法
- (NSData *)imageCompressForSize:(UIImage *)sourceImage targetPx:(NSInteger)targetPx
{
    UIImage *newImage = nil;  // 尺寸压缩后的新图片
    CGSize imageSize = sourceImage.size; // 源图片的size
    CGFloat width = imageSize.width; // 源图片的宽
    CGFloat height = imageSize.height; // 原图片的高
    BOOL drawImge = NO;   // 是否需要重绘图片 默认是NO
    CGFloat scaleFactor = 0.0;  // 压缩比例
    CGFloat scaledWidth = targetPx;  // 压缩时的宽度 默认是参照像素
    CGFloat scaledHeight = targetPx; // 压缩是的高度 默认是参照像素
    
    // 先进行图片的尺寸的判断
    
    // a.图片宽高均≤参照像素时，图片尺寸保持不变
    if (width < targetPx && height < targetPx) {
        newImage = sourceImage;
    }
    // b.宽或高均＞1280px时
    else if (width > targetPx && height > targetPx) {
        drawImge = YES;
        CGFloat factor = width / height;
        if (factor <= 2) {
            // b.1图片宽高比≤2，则将图片宽或者高取大的等比压缩至1280px
            if (width > height) {
                scaleFactor  = targetPx / width;
            } else {
                scaleFactor = targetPx / height;
            }
        } else {
            // b.2图片宽高比＞2时，则宽或者高取小的等比压缩至1280px
            if (width > height) {
                scaleFactor  = targetPx / height;
            } else {
                scaleFactor = targetPx / width;
            }
        }
    }
    // c.宽高一个＞1280px，另一个＜1280px 宽大于1280
    else if (width > targetPx &&  height < targetPx ) {
        if (width / height > 2) {
            newImage = sourceImage;
        } else {
            drawImge = YES;
            scaleFactor = targetPx / width;
        }
    }
    // c.宽高一个＞1280px，另一个＜1280px 高大于1280
    else if (width < targetPx &&  height > targetPx) {
        if (height / width > 2) {
            newImage = sourceImage;
        } else {
            drawImge = YES;
            scaleFactor = targetPx / height;
        }
    }
    
    // 如果图片需要重绘 就按照新的宽高压缩重绘图片
    if (drawImge == YES) {
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        UIGraphicsBeginImageContext(CGSizeMake(scaledWidth, scaledHeight));
        // 绘制改变大小的图片
        [sourceImage drawInRect:CGRectMake(0, 0, scaledWidth,scaledHeight)];
        // 从当前context中创建一个改变大小后的图片
        newImage =UIGraphicsGetImageFromCurrentImageContext();
        // 使当前的context出堆栈
        UIGraphicsEndImageContext();
    }
    // 防止出错  可以删掉的
    if (newImage == nil) {
        newImage = sourceImage;
    }
    
    // 如果图片大小大于200kb 在进行质量上压缩
    NSData * scaledImageData = nil;
    if (UIImageJPEGRepresentation(newImage, 1) == nil) {
        scaledImageData = UIImagePNGRepresentation(newImage);
    }else{
        scaledImageData = UIImageJPEGRepresentation(newImage, 1);
        if (scaledImageData.length >= 1024 * 200) {
            scaledImageData = UIImageJPEGRepresentation(newImage, 0.9);
        }
    }
    
    return scaledImageData;
    
}

```
###压缩图片按钮执行方法
![4040BAAC-8FFA-4650-9FCA-40CDE1B87197.png](http://upload-images.jianshu.io/upload_images/1761100-a164b57b496a737a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
图有时候会挂还是上代码吧-----
```
#//压缩图片
- (void)ssjKitImage{
    NSData * imageData = UIImageJPEGRepresentation(self.SelImage.image,1);

    NSUInteger length = [imageData length]/1000;
     NSLog(@"self.SelImage.imageOriginal = %ld", length);
    SSJKitImageManager * SSJKit = [SSJKitImageManager shareManager];
//压缩图片调用
  NSData * imageDatas = [SSJKit imageCompressForSize:self.SelImage.image targetPx:1000];
//    NSData * imageDatas = UIImageJPEGRepresentation(self.SelImage.image,1);
    
    NSUInteger lengths = [imageDatas length]/1000;
    NSLog(@"self.SelImage.imageKit = %ld", lengths);

}
#// 打开相册
- (IBAction)SelectImage:(UIButton *)sender {
    //调用系统相册的类
    UIImagePickerController * pickController = [[UIImagePickerController alloc] init];
    //设置是否选取的照片可编辑
    pickController.allowsEditing = YES;
    //设置相册的呈现样式
    pickController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;//图片分组列表样式
    //照片的选取样式还有以下两种
    //UIImagePickerControllerSourceTypePhotoLibrary,直接全部呈现系统相册
    //UIImagePickerControllerSourceTypeCamera//调取摄像头
    //选择完成图片或者点击取消按钮都是通过代理来操作我们所需要的逻辑过程
    pickController.delegate = self;
    //使用模态呈现相册
     self.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
    [self.navigationController presentViewController:pickController animated:YES completion:^{
        
    }];
//    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
//        NSLog(@"相机类型可用YES");
//        
//    }else{
//        NSLog(@"相机类型不可用NO");
//    }
    
}
#//保存压缩过的图片  这是最简单的保存 勿喷0.0
- (IBAction)SaveImage:(UIButton *)sender {
    
    UIImageWriteToSavedPhotosAlbum(self.SelImage.image, self, nil, nil);
}

```
###可以去github上给兄弟点个赞，https://github.com/ssj1314/SSJSave-and-CompactImage
####不然的话，哈哈哈


![LOD~F~BXHDKYR@9PRZFESAN.jpg](http://upload-images.jianshu.io/upload_images/1761100-b80342a0325d609e.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
