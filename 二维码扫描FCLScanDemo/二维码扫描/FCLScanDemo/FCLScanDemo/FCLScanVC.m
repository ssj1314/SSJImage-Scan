//
//  FCLScanVC.m
//  FCLScanDemo
//
//  Created by DragonStark on 16/3/11.
//  Copyright © 2016年 付程隆. All rights reserved.
//



/*
 
 
 博客地址：http://www.jianshu.com/users/4022d464ba9c/latest_articles
 
 
 */




#import "FCLScanVC.h"
#define Height [UIScreen mainScreen].bounds.size.height
#define Width [UIScreen mainScreen].bounds.size.width
#define XCenter self.view.center.x
#define YCenter self.view.center.y

#define SHeight 20

#define SWidth (XCenter+30)



@implementation FCLScanVC
{
//    UIImageView *_imageView;
    NSTimer *_timer;
    int num;
    BOOL upOrDown;
    //闪光灯开关
    BOOL _isLightOpenOrClose;
}

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
//input
- (AVCaptureDeviceInput *)input
{
    if (_input == nil) {
        _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    }
    return _input;
}
//output  --- output如果不打开就无法输出扫描得到的信息
// 设置输出对象解析数据时感兴趣的范围
// 默认值是 CGRect(x: 0, y: 0, width: 1, height: 1)
// 通过对这个值的观察, 我们发现传入的是比例
// 注意: 参照是以横屏的左上角作为, 而不是以竖屏
//        out.rectOfInterest = CGRect(x: 0, y: 0, width: 0.5, height: 0.5)
- (AVCaptureMetadataOutput *)output
{
    if (_output == nil) {
        _output = [[AVCaptureMetadataOutput alloc]init];
        [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        //限制扫描区域(上下左右)
        [_output setRectOfInterest:[self rectOfInterestByScanViewRect:_imageView.frame]];
    }
    return _output;
}
- (CGRect)rectOfInterestByScanViewRect:(CGRect)rect {
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGFloat height = CGRectGetHeight(self.view.frame);
    
    CGFloat x = (height - CGRectGetHeight(rect)) / 2 / height;
    CGFloat y = (width - CGRectGetWidth(rect)) / 2 / width;
    
    CGFloat w = CGRectGetHeight(rect) / height;
    CGFloat h = CGRectGetWidth(rect) / width;
    
    return CGRectMake(x, y, w, h);
}
         
//session
- (AVCaptureSession *)session
{
    if (_session == nil) {
        //session
        _session = [[AVCaptureSession alloc]init];
        [_session setSessionPreset:AVCaptureSessionPresetHigh];
        if ([_session canAddInput:self.input]) {
            [_session addInput:self.input];
        }
        if ([_session canAddOutput:self.output]) {
            [_session addOutput:self.output];
        }
    }
    return _session;
}
//preview
- (AVCaptureVideoPreviewLayer *)preview
{
    if (_preview == nil) {
        _preview = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    }
    return _preview;
}

#pragma mark ==========ViewDidLoad==========
- (void)viewDidLoad
{
    //1 判断是否存在相机
    if (self.device == nil) {
        [self showAlertViewWithMessage:@"未检测到相机"];
        
        return;
    }
    self.view.backgroundColor = [UIColor whiteColor];
    
    //打开定时器，开始扫描
    [self addTimer];
    
    //界面初始化
    [self interfaceSetup];

    //初始化扫描
    [self scanSetup];
    
}

#pragma mark ==========初始化工作在这里==========
- (void)viewDidDisappear:(BOOL)animated
{
    //视图退出，关闭扫描
    [self.session stopRunning];
    //关闭定时器
    [_timer setFireDate:[NSDate distantFuture]];
}
//界面初始化
- (void)interfaceSetup
{
    //1 添加扫描框
    [self addImageView];
    
    //添加模糊效果
    [self setOverView];
    
    //添加输入框
    [self addTextFieldInput];
    
    //添加确定按钮
    [self addMakeButton];
    
    //添加开始扫描按钮
    [self addStartButton];
    
    //添加保存二维码图片按钮
    [self addSaveImageButton];
    
    //添加选择照片二维码按钮
    [self addChooseImageButton];
    
    //添加闪光灯
    [self addLightButton];
}

//添加扫描框
- (void)addImageView
{
    _imageView = [[UIImageView alloc]initWithFrame:CGRectMake((Width-SWidth)/2, (Height-SWidth)/2, SWidth, SWidth)];
    //显示扫描框
    _imageView.image = [UIImage imageNamed:@"scanscanBg.png"];
    [self.view addSubview:_imageView];
    _line = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMinX(_imageView.frame)+5, CGRectGetMinY(_imageView.frame)+5, CGRectGetWidth(_imageView.frame), 3)];
    _line.image = [UIImage imageNamed:@"scanLine@2x.png"];
    [self.view addSubview:_line];
}

//初始化扫描配置
- (void)scanSetup
{
    //2 添加预览图层
    self.preview.frame = self.view.bounds;
    self.preview.videoGravity = AVLayerVideoGravityResize;
    [self.view.layer insertSublayer:self.preview atIndex:0];
    
    //3 设置输出能够解析的数据类型
    //注意:设置数据类型一定要在输出对象添加到回话之后才能设置
    [self.output setMetadataObjectTypes:@[AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeQRCode]];
    
    //高质量采集率
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    
    //4 开始扫描
    [self.session startRunning];
    
}
//提示框alert
- (void)showAlertViewWithMessage:(NSString *)message
{
    //弹出提示框后，关闭扫描
    [self.session stopRunning];
    //弹出alert，关闭定时器
    [_timer setFireDate:[NSDate distantFuture]];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"image" message:[NSString stringWithFormat:@"扫描结果：%@",message] preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"tishi" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        //点击alert，开始扫描
        [self.session startRunning];
        //开启定时器
        [_timer setFireDate:[NSDate distantPast]];
    }]];
    [self presentViewController:alert animated:true completion:^{
        
    }];
    
}
//添加文本框
- (void)addTextFieldInput
{
    _textField = [[UITextField alloc]init];
    _textField.frame = CGRectMake(20, 80, 280, 40);
    [_textField resignFirstResponder];
    _textField.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_textField];
    
}

#pragma mark ==========制作二维码并保存==========
//添加制作按钮
- (void)addMakeButton
{
    UIButton *makeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    makeButton.frame = CGRectMake(60, 130, 80, 40);
    makeButton.backgroundColor = [UIColor orangeColor];
    [makeButton addTarget:self action:@selector(makeButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [makeButton setTitle:@"制作" forState:UIControlStateNormal];
    [self.view addSubview:makeButton];
}
- (void)makeButtonClick
{
    //关闭扫描
    [self stopScan];
    //键盘下落
    [self.view endEditing:YES];
    
    //1 实例化二维码滤镜
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    //2 回复滤镜的默认属性(因为滤镜有可能保存上一次的属性)
    [filter setDefaults];
    //3 经字符串转化为NSData
    NSData *data = [self.textField.text dataUsingEncoding:NSUTF8StringEncoding];
    //4 通过KVC设置滤镜，传入data,将来滤镜就知道要通过传入的数据生成二维码
    [filter setValue:data forKey:@"inputMessage"];
    //5 生成二维码
    CIImage *image = [filter outputImage];
    //CIImage是CoreImage框架中最基本代表图像的对象，他不仅包含原图像数据，还包含作用在原图像上的滤镜链
//    UIImage *image1 = [UIImage imageWithCIImage:image];
    //<这样讲CIImage直接转换成UIImage生成的二维码比较模糊，有点事比较简单>
    
    //6 设置生成好的二维码到ImageView上
//    self.imageView.image = image1;
    self.imageView.image= [self createNonInterpolatedUIImageFormCIImage:image withSize:100.0];
}
//将得到的文本数据转化为高清图片
//由于生成的二维码是CIImage类型，如果直接转换成UIImage，大小不好控制，图片模糊
//高清方法：CIImage->CGImageRef->UIImage
- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {
    CGRect extent = CGRectIntegral(image.extent);
    //设置比例
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // 创建bitmap（位图）;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // 保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

//添加保存二维码图片的按钮
- (void)addSaveImageButton
{
    UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    saveButton.frame = CGRectMake(180, 130, 80, 40);
    saveButton.backgroundColor = [UIColor orangeColor];
    [saveButton setTitle:@"保存" forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(saveImageToPhotoLib) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveButton];
}
//将二维码图片保存到相册
- (void)saveImageToPhotoLib
{
    UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, @selector(saveImage:didFinishSavingWithError:contextInfo:), nil);
}
- (void)saveImage:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error == nil) {
        [self showAlertViewWithTitle:@"保存图片" withMessage:@"成功"];
    }
    else
    {
        [self showAlertViewWithTitle:@"保存图片" withMessage:@"失败"];
    }
}

#pragma mark ===========从相册读取二维码并扫描===========
//添加选项按钮
- (void)addChooseImageButton
{
    UIButton *chooseButton = [UIButton buttonWithType:UIButtonTypeSystem];
    chooseButton.frame = CGRectMake(0, 0, 60, 44);
    [chooseButton setTitle:@"相册" forState:UIControlStateNormal];
    [chooseButton addTarget:self action:@selector(chooseButtonClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:chooseButton];
    //解决自定义leftBarbuttonItem左滑返回手势失效的问题
//    self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
}
//打开系统相册
- (void)chooseButtonClick
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        //关闭扫描
        [self stopScan];
        
        //1 弹出系统相册
        UIImagePickerController *pickVC = [[UIImagePickerController alloc]init];
        //2 设置照片来源
        /**
         UIImagePickerControllerSourceTypePhotoLibrary,相册
         UIImagePickerControllerSourceTypeCamera,相机
         UIImagePickerControllerSourceTypeSavedPhotosAlbum,照片库
         */

        pickVC.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        //3 设置代理
        pickVC.delegate = self;
        //4.随便给他一个转场动画
        self.modalTransitionStyle=UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:pickVC animated:YES completion:nil];
    }
    else
    {
        [self showAlertViewWithTitle:@"打开失败" withMessage:@"相册打开失败。设备不支持访问相册，请在设置->隐私->照片中进行设置！"];
        
    }
    
}
//从相册中选取照片&读取相册二维码信息
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    //1 获取选择的图片
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    //初始化一个监听器
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy : CIDetectorAccuracyHigh}];
    [picker dismissViewControllerAnimated:YES completion:^{
        //监测到的结果数组
        NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
        if (features.count >= 1) {
            //结果对象
            CIQRCodeFeature *feature = [features objectAtIndex:0];
            NSString *scannedResult = feature.messageString;
            [self showAlertViewWithTitle:@"读取相册二维码" withMessage:scannedResult];
        }
        else
        {
            [self showAlertViewWithTitle:@"读取相册二维码" withMessage:@"读取失败"];
        }
    }];
    
}

#pragma mark ===========重启扫描&闪光灯===========
//添加开始扫描按钮
- (void)addStartButton
{
    UIButton *startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    startButton.frame = CGRectMake(60, 420, 80, 40);
    startButton.backgroundColor = [UIColor orangeColor];
    [startButton addTarget:self action:@selector(startButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [startButton setTitle:@"扫描" forState:UIControlStateNormal];
    [self.view addSubview:startButton];
}
- (void)startButtonClick
{
    //清除imageView上的图片
    self.imageView.image = [UIImage imageNamed:@""];
    //开始扫描
    [self starScan];
    
}
//添加闪光灯控制开关
- (void)addLightButton
{
    UIButton *startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    startButton.frame = CGRectMake(180, 420, 80, 40);
    startButton.backgroundColor = [UIColor orangeColor];
    [startButton addTarget:self action:@selector(lightButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [startButton setTitle:@"灯光" forState:UIControlStateNormal];
    [self.view addSubview:startButton];
}
- (void)lightButtonClick
{
    _isLightOpenOrClose = !_isLightOpenOrClose;
    //开启闪光灯
    [self systemLightSwitch:_isLightOpenOrClose];
}

- (void)systemLightSwitch:(BOOL)open
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch]) {
        [device lockForConfiguration:nil];
        if (open) {
            [device setTorchMode:AVCaptureTorchModeOn];
        } else {
            [device setTorchMode:AVCaptureTorchModeOff];
        }
        [device unlockForConfiguration];
    }
}

#pragma mark ===========添加提示框===========
//提示框alert
- (void)showAlertViewWithTitle:(NSString *)aTitle withMessage:(NSString *)aMessage
{
    
    //弹出提示框后，关闭扫描
    [self.session stopRunning];
    //弹出alert，关闭定时器
    [_timer setFireDate:[NSDate distantFuture]];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:aTitle message:[NSString stringWithFormat:@"%@",aMessage] preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"tishi" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        //点击alert，开始扫描
        [self.session startRunning];
        //开启定时器
        [_timer setFireDate:[NSDate distantPast]];
    }]];
    [self presentViewController:alert animated:true completion:^{
        
    }];
    
}


#pragma mark ===========扫描的代理方法===========
//得到扫描结果
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if ([metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects objectAtIndex:0];
        if ([metadataObject isKindOfClass:[AVMetadataMachineReadableCodeObject class]]) {
            NSString *stringValue = [metadataObject stringValue];
            if (stringValue != nil) {
                [self.session stopRunning];
                //扫描结果
                self.scannedResult = stringValue;
                NSLog(@"%@",stringValue);
                [self showAlertViewWithMessage:stringValue];
                
            }
        }
        
    }
}


#pragma mark ============添加模糊效果============
- (void)setOverView {
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGFloat height = CGRectGetHeight(self.view.frame);
    
    CGFloat x = CGRectGetMinX(_imageView.frame);
    CGFloat y = CGRectGetMinY(_imageView.frame);
    CGFloat w = CGRectGetWidth(_imageView.frame);
    CGFloat h = CGRectGetHeight(_imageView.frame);
    
    [self creatView:CGRectMake(0, 0, width, y)];
    [self creatView:CGRectMake(0, y, x, h)];
    [self creatView:CGRectMake(0, y + h, width, height - y - h)];
    [self creatView:CGRectMake(x + w, y, width - x - w, h)];
}

- (void)creatView:(CGRect)rect {
    CGFloat alpha = 0.5;
    UIColor *backColor = [UIColor blueColor];
    UIView *view = [[UIView alloc] initWithFrame:rect];
    view.backgroundColor = backColor;
    view.alpha = alpha;
    [self.view addSubview:view];
}

#pragma mark ============添加扫描效果============

- (void)addTimer
{
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.008 target:self selector:@selector(timerMethod) userInfo:nil repeats:YES];
}
//控制扫描线上下滚动
- (void)timerMethod
{
    if (upOrDown == NO) {
        num ++;
        _line.frame = CGRectMake(CGRectGetMinX(_imageView.frame)+5, CGRectGetMinY(_imageView.frame)+5+num, CGRectGetWidth(_imageView.frame)-10, 3);
        if (num == (int)(CGRectGetHeight(_imageView.frame)-10)) {
            upOrDown = YES;
        }
    }
    else
    {
        num --;
        _line.frame = CGRectMake(CGRectGetMinX(_imageView.frame)+5, CGRectGetMinY(_imageView.frame)+5+num, CGRectGetWidth(_imageView.frame)-10, 3);
        if (num == 0) {
            upOrDown = NO;
        }
    }
}
//暂定扫描
- (void)stopScan
{
    //弹出提示框后，关闭扫描
    [self.session stopRunning];
    //弹出alert，关闭定时器
    [_timer setFireDate:[NSDate distantFuture]];
    //隐藏扫描线
    _line.hidden = YES;
}
- (void)starScan
{
    //开始扫描
    [self.session startRunning];
    //打开定时器
    [_timer setFireDate:[NSDate distantPast]];
    //显示扫描线
    _line.hidden = NO;
}
#pragma mark ============从相册读取二维码============














@end
