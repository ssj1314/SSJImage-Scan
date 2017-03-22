//
//  SSJKitImageManager.m
//  图片压缩
//
//  Created by ssj on 16/10/11.
//  Copyright © 2016年 jiteng. All rights reserved.
//

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
// 判断文件类型
+(NSString *)contentTypeForImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
        case 0x4D:
            return @"image/tiff";
        case 0x52:
            // R as RIFF for WEBP
            if ([data length] < 12) {
                return nil;
            }
            
            NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
            if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) {
                return @"image/webp";
            }
            
            return nil;
    }
    return nil;
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


@end
