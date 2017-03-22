//
//  ViewController.m
//  图片压缩
//
//  Created by ssj on 16/10/11.
//  Copyright © 2016年 jiteng. All rights reserved.
//

#import "ViewController.h"
#import "SSJKitImageManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <Photos/Photos.h>

#import "NSData+ImageContentType.h"

#define Screen_W [UIScreen mainScreen].bounds.size.width
#define screen_H [UIScreen mainScreen].bounds.size.height
@interface ViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    UIImagePickerController *_imagePickerController;

}
//
@property (nonatomic,strong)AVCaptureDevice *device;
@property (strong, nonatomic) IBOutlet UIImageView *SelImage;

@end

@implementation ViewController
#pragma mark ===========懒加载===========
//device
- (AVCaptureDevice *)device
{
    if (_device == nil) {
        //AVMediaTypeVideo是打开相机
        //AVMediaTypeAudio是打开麦克风
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    return _device;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //1 判断是否存在相机
    if (self.device == nil) {
     
        
        return;
    }
    self.view.backgroundColor = [UIColor whiteColor];
    // "检查用户对视频媒体类型的授权状态"
    // 返回用户对视频媒体类型的授权状态
    /*
     用户对相机的授权状态是一个枚举,拥有如下四种类型
     AVAuthorizationStatusNotDetermined // 用户没有选择是否授权使用
     AVAuthorizationStatusRestricted // 用户禁止使用,且授权状态不可修改,可能由于家长控制功能
     AVAuthorizationStatusDenied // 用户已经禁止使用
     AVAuthorizationStatusAuthorized // 用户已经授权使用
     */
//    AVAuthorizationStatus authorizationStastus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
//    //用户没有选择是否授权使用
//    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
//        if (granted) {
//            //用户授权使用
//        }else{
//            //用户禁止使用
//        }
//    }];
//
//    //处理不同的授权流程
//    switch (authorizationStastus) {
//        case AVAuthorizationStatusNotDetermined:
//        {
//            
//        }
//            break;
//        case AVAuthorizationStatusRestricted:
//        {
//            
//        }
//            break;
//        case AVAuthorizationStatusDenied:
//        {
//            
//        }
//            break;
//        case AVAuthorizationStatusAuthorized:
//        {
//        }
//            break;
//        default:
//            break;
//    }

    // Do any additional setup after loading the view, typically from a nib.
    UIButton * button = [[UIButton alloc] init];
//    typeof(self)__weak weakSelf = self;
//    __strong typeof(self) strongSelf = self;
    button.frame = CGRectMake(20, screen_H/3, Screen_W/2, 50);
    button.center = self.view.center;
    CGRect rect = button.frame;
    rect.origin.y -= 100;
    button.frame = rect;
    button.backgroundColor = [UIColor redColor];
    [button setTitle:@"压缩图片" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(ssjKitImage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}
//压缩图片
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
// 打开相册
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
//保存压缩过的图片  这是最简单的保存 勿喷0.0
- (IBAction)SaveImage:(UIButton *)sender {

    //gif 图片
    NSData *imageData = UIImagePNGRepresentation(self.SelImage.image);
  NSString * filename =  [SSJKitImageManager contentTypeForImageData:imageData];
    
    if ([filename isEqualToString:@"image/gif"]) {
        NSLog(@"Gif图片");
    }else{
    
        NSLog(@"普通图片");
    }
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
    
    
    #else
    
    
    #endif
    
//    UIImageWriteToSavedPhotosAlbum(self.SelImage.image, self, nil, nil);
}

    //xuaz选择照片完成之后的代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
//UIImagePickerControllerEditedImage 编辑过的图片
//    UIImagePickerControllerOriginalImage 原图
    /*
     UIButton *button = (UIButton *)[self.view viewWithTag:1004];
     
     UIImage *resultImage = [info objectForKey:@"UIImagePickerControllerEditedImage"];
     [button setImage:[resultImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]forState:UIControlStateNormal];//如果按钮创建时用的是系统风格UIButtonTypeSystem，需要在设置图片一栏设置渲染模式为"使用原图"
     */
    //info 是选择照片的信息
    NSLog(@"info = %@",info);
    NSURL *imageAssetUrl = [info objectForKey:UIImagePickerControllerReferenceURL];
    
    PHFetchResult*result = [PHAsset fetchAssetsWithALAssetURLs:@[imageAssetUrl] options:nil];
    
    PHAsset *asset = [result firstObject];
    
    PHImageRequestOptions *phImageRequestOptions = [[PHImageRequestOptions alloc] init];
    
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:phImageRequestOptions resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        
        NSData *imageDatas = imageData;
        if ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f) {
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init];
                [[PHAssetCreationRequest creationRequestForAsset] addResourceWithType:PHAssetResourceTypePhoto data:imageDatas options:options];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                NSLog(@"是否保存成功：%d",success);
            }];
        }
        
    }];
    
//    NSString * filename =  [SSJKitImageManager contentTypeForImageData:imageData];
//    
//    if ([filename isEqualToString:@"image/gif"]) {
//        NSLog(@"Gif图片");
//    }else{
//        
//        NSLog(@"普通图片");
//    }
    UIImage * resultImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    self.SelImage.image  = [resultImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//返回
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{

//这是捕获点击右上角cancel按钮所触发的事件，如果我们需要在点击cancel按钮的时候做一些其他的逻辑操作，如果不做按钮任何操作，可以不实现。
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}






- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
