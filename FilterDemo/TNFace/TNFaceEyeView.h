//
//  TNFaceEyeView.h
//  FilterDemo
//
//  Created by zhangheng on 2017/5/10.
//  Copyright © 2017年 zhangheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TNFaceEyeView : UIImageView

@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat right_eye;
@property (nonatomic, assign) CGFloat left_eye;
+ (instancetype)instanceWithIndex:(NSInteger)index;

@end
