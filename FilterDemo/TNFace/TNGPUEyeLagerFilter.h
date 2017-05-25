//
//  TNGPUEyeLagerFilter.h
//  FilterDemo
//
//  Created by zhangheng on 2017/5/16.
//  Copyright © 2017年 zhangheng. All rights reserved.
//

#import <GPUImage/GPUImage.h>

@interface TNGPUEyeLagerFilter : GPUImageFilter {
    GLint leftEyeUniform, rightEyeUniform, aspectRatioUniform, scaleUniform, radiusUniform;
}

@property (nonatomic, readwrite) CGPoint leftEyePoint;
@property (nonatomic, readwrite) CGPoint rightEyePoint;
@property (nonatomic, readwrite) CGFloat scale;
@property (nonatomic, readwrite) CGFloat radius;

@end
