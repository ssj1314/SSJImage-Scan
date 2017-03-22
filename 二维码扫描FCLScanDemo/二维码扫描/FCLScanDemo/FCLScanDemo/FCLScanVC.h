//
//  FCLScanVC.h
//  FCLScanDemo
//
//  Created by DragonStark on 16/3/11.
//  Copyright © 2016年 付程隆. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@interface FCLScanVC : UIViewController<AVCaptureMetadataOutputObjectsDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

//输入输出的中间桥梁
@property (nonatomic,strong)AVCaptureSession *session;
//
@property (nonatomic,strong)AVCaptureDevice *device;
//
@property (nonatomic,strong)AVCaptureDeviceInput *input;
//
@property (nonatomic,strong)AVCaptureMetadataOutput *output;
//
@property (nonatomic,strong)AVCaptureVideoPreviewLayer *preview;

//扫描结果
@property (nonatomic,strong)NSString *scannedResult;

//扫描框
@property (nonatomic,strong)UIImageView *imageView;

//扫描线
@property (nonatomic,retain)UIImageView *line;

//添加输入文本框
@property (nonatomic,strong)UITextField *textField;

@end
