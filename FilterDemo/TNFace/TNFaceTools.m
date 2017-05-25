//
//  TNFaceTools.m
//  FilterDemo
//
//  Created by zhangheng on 2017/5/9.
//  Copyright © 2017年 zhangheng. All rights reserved.
//

#import "TNFaceTools.h"
#import <CoreMotion/CoreMotion.h>

@implementation TNFaceTools
+ (IFlyFaceImage *)faceImageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer cameraPosition:(AVCaptureDevicePosition)cameraPosition deviceOrientation:(UIDeviceOrientation)deviceOrientation {
    //获取灰度图像数据
    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    uint8_t *lumaBuffer = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    
    size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer,0);
    size_t width  = CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);
    
    CGColorSpaceRef grayColorSpace = CGColorSpaceCreateDeviceGray();
    
    CGContextRef context=CGBitmapContextCreate(lumaBuffer, width, height, 8, bytesPerRow, grayColorSpace,0);
    CGImageRef cgImage = CGBitmapContextCreateImage(context);

    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);

    
    IFlyFaceImage* faceImage= [[IFlyFaceImage alloc] init];
    if(!faceImage){
        return nil;
    }
    
    CGDataProviderRef provider = CGImageGetDataProvider(cgImage);
    
    faceImage.image = [UIImage imageWithCGImage:cgImage];
    faceImage.data = (__bridge_transfer NSData*)CGDataProviderCopyData(provider);
    faceImage.width = width;
    faceImage.height = height;
    faceImage.direction = [self faceImageOrientationWithCameraPosition:cameraPosition deviceOrientation:deviceOrientation];
    
    CGImageRelease(cgImage);
    CGContextRelease(context);
    CGColorSpaceRelease(grayColorSpace);
    
    return faceImage;
}


+ (IFlyFaceDirectionType)faceImageOrientationWithCameraPosition:(AVCaptureDevicePosition)cameraPosition deviceOrientation:(UIDeviceOrientation)deviceOrientation {
    IFlyFaceDirectionType faceOrientation = IFlyFaceDirectionTypeLeft;
    BOOL isFrontCamera = cameraPosition == AVCaptureDevicePositionFront;
    switch (deviceOrientation) {
        case UIDeviceOrientationPortrait: {
            // 正常 脸型逆时针90度
            faceOrientation = IFlyFaceDirectionTypeLeft;
        }
            break;
        case UIDeviceOrientationPortraitUpsideDown: {
            // 倒立 脸型顺时针90度
            faceOrientation = IFlyFaceDirectionTypeRight;
        }
            break;
        case UIDeviceOrientationLandscapeRight: {
            // 右侧
            faceOrientation = isFrontCamera ? IFlyFaceDirectionTypeUp : IFlyFaceDirectionTypeDown;
        }
            break;
        default: {
            // 左侧
            faceOrientation= isFrontCamera ? IFlyFaceDirectionTypeDown : IFlyFaceDirectionTypeUp;
        }
            break;
    }
    return faceOrientation;
}


@end
