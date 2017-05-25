//
//  TNFaceEyeView.m
//  FilterDemo
//
//  Created by zhangheng on 2017/5/10.
//  Copyright © 2017年 zhangheng. All rights reserved.
//

#import "TNFaceEyeView.h"

@implementation TNFaceEyeView

+ (instancetype)instanceWithIndex:(NSInteger)index {
    TNFaceEyeView *eyeView = [[TNFaceEyeView alloc] init];
    NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TNFaceInfo" ofType:@"plist"]];
    NSDictionary *eyeInfo = [[plist valueForKey:@"Eye"] objectAtIndex:index];
    eyeView.image = [UIImage imageNamed:[eyeInfo valueForKey:@"name"]];
    eyeView.left_eye = [[eyeInfo valueForKey:@"left_eye"] floatValue];
    eyeView.right_eye = [[eyeInfo valueForKey:@"right_eye"] floatValue];
    eyeView.width = [[eyeInfo valueForKey:@"width"] floatValue];
    eyeView.height = [[eyeInfo valueForKey:@"height"] floatValue];
    eyeView.frame = CGRectMake(0, 0, eyeView.width, eyeView.height);
    eyeView.contentMode = UIViewContentModeScaleAspectFit;
    return eyeView;
}

@end
