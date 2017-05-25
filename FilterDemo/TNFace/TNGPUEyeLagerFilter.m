//
//  TNGPUEyeLagerFilter.m
//  FilterDemo
//
//  Created by zhangheng on 2017/5/16.
//  Copyright © 2017年 zhangheng. All rights reserved.
//

#import "TNGPUEyeLagerFilter.h"

NSString *const TNGPUEyeLagerFilterFragmentShaderString = SHADER_STRING
(
 precision highp float;
 
 varying highp vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 
 uniform highp float scaleRatio;// 缩放系数，0无缩放，大于0则放大
 uniform highp float radius;// 缩放算法的作用域半径
 uniform highp vec2 leftEyeCenterPosition; // 左眼控制点，越远变形越小
 uniform highp vec2 rightEyeCenterPosition; // 右眼控制点
 uniform float aspectRatio; // 所处理图像的宽高比
 
 highp vec2 warpPositionToUse(vec2 centerPostion, vec2 currentPosition, float radius, float scaleRatio, float aspectRatio)
 {
     vec2 positionToUse = currentPosition;
     
     vec2 currentPositionToUse = vec2(currentPosition.x, currentPosition.y * aspectRatio + 0.5 - 0.5 * aspectRatio);
     vec2 centerPostionToUse = vec2(centerPostion.x, centerPostion.y * aspectRatio + 0.5 - 0.5 * aspectRatio);
     
     float r = distance(currentPositionToUse, centerPostionToUse);
     
     if(r < radius)
     {
         float alpha = 1.0 - scaleRatio * pow(r / radius - 1.0, 2.0);
         positionToUse = centerPostion + alpha * (currentPosition - centerPostion);
     }
     
     return positionToUse;
 }
 
 void main()
 {
     vec2 positionToUse = warpPositionToUse(leftEyeCenterPosition, textureCoordinate, radius, scaleRatio, aspectRatio);
     
     positionToUse = warpPositionToUse(rightEyeCenterPosition, positionToUse, radius, scaleRatio, aspectRatio);
     
     gl_FragColor = texture2D(inputImageTexture, positionToUse);
 }
);


@interface TNGPUEyeLagerFilter ()
- (void)adjustAspectRatio;
@property (readwrite, nonatomic) CGFloat aspectRatio;
@end

@implementation TNGPUEyeLagerFilter

- (instancetype)init {
    if (!(self = [super initWithFragmentShaderFromString:TNGPUEyeLagerFilterFragmentShaderString])) {
        return nil;
    }
    
    rightEyeUniform = [filterProgram uniformIndex:@"rightEyeCenterPosition"];
    leftEyeUniform = [filterProgram uniformIndex:@"leftEyeCenterPosition"];
    aspectRatioUniform = [filterProgram uniformIndex:@"aspectRatio"];
    scaleUniform = [filterProgram uniformIndex:@"scaleRatio"];
    radiusUniform = [filterProgram uniformIndex:@"radius"];
    
    self.leftEyePoint = CGPointMake(0.5, 0.5);
    self.rightEyePoint = CGPointMake(0.5, 0.5);
    self.scale = 0.5;
    self.radius = 0.25;
    
    return self;
}

- (void)adjustAspectRatio;
{
    if (GPUImageRotationSwapsWidthAndHeight(inputRotation))
    {
        [self setAspectRatio:(inputTextureSize.width / inputTextureSize.height)];
    }
    else
    {
        [self setAspectRatio:(inputTextureSize.height / inputTextureSize.width)];
    }
}

- (void)forceProcessingAtSize:(CGSize)frameSize;
{
    [super forceProcessingAtSize:frameSize];
    [self adjustAspectRatio];
}

- (void)setInputSize:(CGSize)newSize atIndex:(NSInteger)textureIndex;
{
    CGSize oldInputSize = inputTextureSize;
    [super setInputSize:newSize atIndex:textureIndex];
    
    if ( (!CGSizeEqualToSize(oldInputSize, inputTextureSize)) && (!CGSizeEqualToSize(newSize, CGSizeZero)) )
    {
        [self adjustAspectRatio];
    }
}

- (void)setAspectRatio:(CGFloat)newValue;
{
    _aspectRatio = newValue;
    
    [self setFloat:_aspectRatio forUniform:aspectRatioUniform program:filterProgram];
}

- (void)setInputRotation:(GPUImageRotationMode)newInputRotation atIndex:(NSInteger)textureIndex;
{
    [super setInputRotation:newInputRotation atIndex:textureIndex];
    [self adjustAspectRatio];
}


- (void)setLeftEyePoint:(CGPoint)leftEyePoint {
    _leftEyePoint = leftEyePoint;
    [self setPoint:_leftEyePoint forUniform:leftEyeUniform program:filterProgram];
}

- (void)setRightEyePoint:(CGPoint)rightEyePoint {
    _rightEyePoint = rightEyePoint;
    [self setPoint:_rightEyePoint forUniform:rightEyeUniform program:filterProgram];
}

- (void)setScale:(CGFloat)scale {
    _scale = scale;
    [self setFloat:_scale forUniform:scaleUniform program:filterProgram];
}

- (void)setRadius:(CGFloat)radius {
    _radius = radius;
    [self setFloat:_radius forUniform:radiusUniform program:filterProgram];
}

@end
