//
//  SSJKitImageManager.h
//  图片压缩
//
//  Created by ssj on 16/10/11.
//  Copyright © 2016年 jiteng. All rights reserved.
//

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


/**
 判断文件类型

 @param data 文件
 @return 文件后缀
 */
+(NSString *)contentTypeForImageData:(NSData *)data;
@end
