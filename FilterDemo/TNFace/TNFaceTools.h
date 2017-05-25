//
//  TNFaceTools.h
//  FilterDemo
//
//  Created by zhangheng on 2017/5/9.
//  Copyright © 2017年 zhangheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import "IFlyFaceImage.h"

@interface TNFaceTools : NSObject
+ (IFlyFaceImage *)faceImageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer cameraPosition:(AVCaptureDevicePosition)cameraPosition deviceOrientation:(UIDeviceOrientation)deviceOrientation;
@end
