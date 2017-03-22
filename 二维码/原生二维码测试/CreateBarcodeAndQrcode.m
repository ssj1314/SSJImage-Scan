//
//  CreateBarcodeAndQrcode.m
//  SQJR
//
//  Created by jiuyv on 16/8/30.
//  Copyright © 2016年 Julija. All rights reserved.
//

#import "CreateBarcodeAndQrcode.h"

@implementation CreateBarcodeAndQrcode

+ (UIImage *)resizeImageWithoutInterpolation:(UIImage *)sourceImage size:(CGSize )size{
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextSetInterpolationQuality(UIGraphicsGetCurrentContext(), kCGInterpolationNone);
    [sourceImage drawInRect:(CGRect){.size = size}];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
    
}

+ (UIImage *)imageWithCIImage:(CIImage *)aCIImage orientation:(UIImageOrientation)anOrientation{
    if (!aCIImage) return nil;
    
    CGImageRef imageRef = [[CIContext contextWithOptions:nil] createCGImage:aCIImage fromRect:aCIImage.extent];
    UIImage *image = [UIImage imageWithCGImage:imageRef scale:1.0 orientation:anOrientation];
    CFRelease(imageRef);
    
    return image;
}


+ (UIImage *)generateQRCode:(NSString *)code size:(CGSize )size color:(UIColor *)color backGroundColor:(UIColor *)bgcolor{
    //生成滤镜
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 2.恢复默认
    [qrFilter setDefaults];
    if (!qrFilter) {
        NSLog(@"error:Could nor load filter");
        return nil;
    }
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    //3.滤镜的内容
    NSData *singleData = [code dataUsingEncoding:NSUTF8StringEncoding];
    [qrFilter setValue:singleData forKey:@"inputMessage"];
    //4.滤镜的颜色
    CIFilter *colorQrFilter = [CIFilter filterWithName:@"CIFalseColor"];
    [colorQrFilter setValue:qrFilter.outputImage forKey:@"inputImage"];
    
    //5.二维码颜色
    if (color == nil) {
        color = [UIColor blackColor];
    }
    [colorQrFilter setValue:[CIColor colorWithCGColor:color.CGColor] forKey:@"inputColor0"];
    //6.背景颜色
    if (bgcolor == nil) {
        bgcolor = [UIColor whiteColor];
    }
    [colorQrFilter setValue:[CIColor colorWithCGColor:bgcolor.CGColor] forKey:@"inputColor1"];
    //7.获得滤镜输出的图像
    CIImage *outputImage = [colorQrFilter valueForKey:@"outputImage"];
    
    UIImage *smallImage = [self imageWithCIImage:outputImage orientation:UIImageOrientationUp];
    //8.将CIImage转换成UIImage，并放大显示
    return [self resizeImageWithoutInterpolation:smallImage size:size];
}

+ (UIImage *)generateBarCode:(NSString *)code size:(CGSize)size color:(UIColor *)color backGroundColor:(UIColor *)bgcolor{
    
    //生成条形码图片
    CIImage *barcodeImage;
    NSData *barData = [code dataUsingEncoding:NSISOLatin1StringEncoding allowLossyConversion:false];
    //生成滤镜
    CIFilter *filter = [CIFilter filterWithName:@"CICode128BarcodeGenerator"];
    [filter setValue:barData forKey:@"inputMessage"];
    //设置条形码颜色和背景颜色
    CIFilter *colorFilter = [CIFilter filterWithName:@"CIFalseColor"];
    [colorFilter setValue:filter.outputImage forKey:@"inputImage"];
    //条形码颜色
    if (color == nil) {
        color = [UIColor blackColor];
    }
    [colorFilter setValue:[CIColor colorWithCGColor:color.CGColor] forKey:@"inputColor0"];
    
    //背景颜色
    if (bgcolor == nil) {
        bgcolor = [UIColor whiteColor];
    }
    [colorFilter setValue:[CIColor colorWithCGColor:bgcolor.CGColor] forKey:@"inputColor1"];
    barcodeImage = [colorFilter outputImage];
    
    // 消除模糊
    CGFloat scaleX = size.width / barcodeImage.extent.size.width;
    CGFloat scaleY = size.height / barcodeImage.extent.size.height;
    CIImage *transformedImage = [barcodeImage imageByApplyingTransform:CGAffineTransformScale(CGAffineTransformIdentity, scaleX, scaleY)];
    
    return [UIImage imageWithCIImage:transformedImage];
}

@end



