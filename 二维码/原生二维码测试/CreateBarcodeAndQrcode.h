//
//  CreateBarcodeAndQrcode.h
//  SQJR
//
//  Created by jiuyv on 16/8/30.
//  Copyright © 2016年 Julija. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CreateBarcodeAndQrcode : NSObject
/**
 * 二维码生成
 * @param code 内容字符串
 * @param size 二维码大小
 * @param color 二维码颜色
 * @param bgcolor 背景颜色
 *
 * return 返回一张图片
 */
+ (UIImage *)generateQRCode:(NSString *)code size:(CGSize)size color:(UIColor *)color backGroundColor:(UIColor *)bgcolor;


/**
 * 条形码生成
 * @param code 内容字符串
 * @param size 条形码大小
 * @param color 条形码颜色
 * @param bgcolor 背景颜色
 *
 * return 返回一张图片
 */
+ (UIImage *)generateBarCode:(NSString *)code size:(CGSize)size color:(UIColor *)color backGroundColor:(UIColor *)bgcolor;


@end
