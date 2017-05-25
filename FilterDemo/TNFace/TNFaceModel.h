//
//  TNFaceModel.h
//  FilterDemo
//
//  Created by zhangheng on 2017/5/10.
//  Copyright © 2017年 zhangheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TNFaceModel : NSObject

@property (nonatomic, assign) CGPoint left_eye_center; // 左眼中心
@property (nonatomic, assign) CGPoint left_eye_left_corner; // 左眼左边
@property (nonatomic, assign) CGPoint left_eye_right_corner; // 左眼右边

@property (nonatomic, assign) CGPoint right_eye_center; // 右眼中心
@property (nonatomic, assign) CGPoint right_eye_left_corner; // 右眼左边
@property (nonatomic, assign) CGPoint right_eye_right_corner; // 右眼右边

+ (instancetype)instanceWithInfo:(NSDictionary *)info;

@end
