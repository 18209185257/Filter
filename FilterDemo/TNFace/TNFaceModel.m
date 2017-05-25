//
//  TNFaceModel.m
//  FilterDemo
//
//  Created by zhangheng on 2017/5/10.
//  Copyright © 2017年 zhangheng. All rights reserved.
//

#import "TNFaceModel.h"

@implementation TNFaceModel

+ (instancetype)instanceWithInfo:(NSDictionary *)info {
    TNFaceModel *faceModel = [[TNFaceModel alloc] init];
    NSDictionary *keyPoint = [info valueForKey:@"landmark"];
    faceModel.left_eye_left_corner = [self pointWithName:@"left_eye_left_corner" keyPoint:keyPoint];
    faceModel.left_eye_right_corner = [self pointWithName:@"left_eye_right_corner" keyPoint:keyPoint];
    faceModel.left_eye_center = [self pointWithName:@"left_eye_center" keyPoint:keyPoint];

    faceModel.right_eye_center = [self pointWithName:@"right_eye_center" keyPoint:keyPoint];
    faceModel.right_eye_left_corner = [self pointWithName:@"right_eye_left_corner" keyPoint:keyPoint];
    faceModel.right_eye_right_corner = [self pointWithName:@"right_eye_right_corner" keyPoint:keyPoint];
    
    return faceModel;
}

+ (CGPoint)pointWithName:(NSString *)name keyPoint:(NSDictionary *)keyPoint {
    return CGPointMake([[[keyPoint valueForKey:name] valueForKey:@"x"] floatValue], [[[keyPoint valueForKey:name] valueForKey:@"y"] floatValue]);
}

@end
