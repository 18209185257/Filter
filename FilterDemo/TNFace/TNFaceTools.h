//
//  TNFaceTools.h
//  FilterDemo
//
//  Created by zhangheng on 2017/5/9.
//  Copyright © 2017年 zhangheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IFlyFaceImage.h"
#import <GPUImage.h>

@interface TNFaceTools : NSObject
+ (IFlyFaceImage *) faceImageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer camera:(GPUImageVideoCamera *)camera;
@end
