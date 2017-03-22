//
//  ViewController.m
//  原生二维码测试
//
//  Created by ssj on 16/9/29.
//  Copyright © 2016年 jiteng. All rights reserved.
//

#import "ViewController.h"
#import "CreateBarcodeAndQrcode.h"
#import <AVFoundation/AVFoundation.h>
@interface ViewController ()<AVCaptureMetadataOutputObjectsDelegate>
@property (strong, nonatomic) IBOutlet UIView *videoPreviewLayer;
@property (strong, nonatomic) UIView *boxView;
@property (nonatomic) BOOL isReading;
@property (strong, nonatomic) CALayer *scanLayer;
@property (nonatomic, weak) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureSession *captureSession;//捕捉会话
@property (strong, nonatomic) IBOutlet UIImageView *erWEima;
@property (strong, nonatomic) IBOutlet UIImageView *Image222;
@property (strong, nonatomic) IBOutlet UITextField *INput;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.btn_2d_n
    
    
}

- (IBAction)CreatImage:(UIButton *)sender {
    _Image222.image = [CreateBarcodeAndQrcode generateQRCode:self.INput.text size:_Image222.frame.size color:[UIColor whiteColor] backGroundColor:[UIColor blackColor]];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
