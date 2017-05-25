//
//  FilterCameraController.m
//  FilterDemo
//
//  Created by zhangheng on 2017/5/9.
//  Copyright © 2017年 zhangheng. All rights reserved.
//

#import "FilterCameraController.h"
#import <Masonry/Masonry.h>
#import <GPUImage.h>
#import <iflyMSC/IFlyFaceSDK.h>
#import "TNFaceTools.h"
#import "TNFaceEyeView.h"
#import "TNFaceModel.h"
#import <CoreMotion/CoreMotion.h>

#define RADIAN_TO_DEGREE(__ANGLE__) ((__ANGLE__) * 180/M_PI)
#define DEGREE_TO_RADIAN(__ANGLE__) ((__ANGLE__) * M_PI/180.0)

@interface FilterCameraController ()<GPUImageVideoCameraDelegate>

@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic, strong) GPUImageView *videoView;;
@property (nonatomic, strong) GPUImageBrightnessFilter *brightness; // 亮度
@property (nonatomic, retain) IFlyFaceDetector *faceDetector;
@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, strong) UIImageView *testImageView;
@property (nonatomic, assign) UIDeviceOrientation deviceOrientation;

//@property (nonatomic, strong) TNFaceEyeView *eyeView;

@property (nonatomic, strong) UIView *left_eye_KeyPoint;
@property (nonatomic, strong) UIView *right_eye_KeyPoint;

@end

@implementation FilterCameraController {
//    GPUImageBulgeDistortionFilter *leftEyeBulge; // 凸起失帧
    GPUImageBulgeDistortionFilter *rightEyeBulge; // 凸起失帧
    GPUImageFilterPipeline *pipeline; // 组合滤镜
}

- (void)dealloc {
    [[GPUImageContext sharedImageProcessingContext].framebufferCache purgeAllUnassignedFramebuffers];
    [self.motionManager stopAccelerometerUpdates];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.videoCamera.horizontallyMirrorRearFacingCamera = NO;
    self.videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    self.videoCamera.delegate = self;
    [self.videoCamera addAudioInputsAndOutputs];
    
    self.videoView.fillMode = kGPUImageFillModePreserveAspectRatio;
//    [self.videoCamera addTarget:self.videoView];
    
//    leftEyeBulge = [[GPUImageBulgeDistortionFilter alloc] init];
//    leftEyeBulge.scale = 0.0;
    
    rightEyeBulge = [[GPUImageBulgeDistortionFilter alloc] init];
    rightEyeBulge.scale = 0.3;
    rightEyeBulge.center = CGPointMake(1.0, 1.333);
    pipeline = [[GPUImageFilterPipeline alloc] initWithOrderedFilters:@[rightEyeBulge] input:self.videoCamera output:self.videoView];
    
    [self.videoCamera startCameraCapture];
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"切换" style:UIBarButtonItemStylePlain target:self action:@selector(exchangeCamera:)];
    
    self.faceDetector = [IFlyFaceDetector sharedInstance];
    if(self.faceDetector){
        [self.faceDetector setParameter:@"1" forKey:@"detect"];
        [self.faceDetector setParameter:@"1" forKey:@"align"];
    }
    
    // 这里使用CoreMotion来获取设备方向以兼容iOS7.0设备
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.accelerometerUpdateInterval = .2;
    self.motionManager.gyroUpdateInterval = .2;
    __weak typeof(&*self)weakSelf = self;
    [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
        if (error == nil) {
            if (accelerometerData.acceleration.x >= 0.75) {
                weakSelf.deviceOrientation = UIDeviceOrientationLandscapeLeft;
            } else if (accelerometerData.acceleration.x <= -0.75) {
                weakSelf.deviceOrientation = UIDeviceOrientationLandscapeRight;
            } else if (accelerometerData.acceleration.y <= -0.75) {
                weakSelf.deviceOrientation = UIDeviceOrientationPortrait;
            } else if (accelerometerData.acceleration.y >= 0.75) {
                weakSelf.deviceOrientation = UIDeviceOrientationPortraitUpsideDown;
            } else {
                return;
            }
        }
    }];
}


- (GPUImageView *)videoView {
    if (_videoView == nil) {
        _videoView = [[GPUImageView alloc] init];
        [self.view addSubview:_videoView];
        [_videoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_top);
            make.left.equalTo(self.view.mas_left);
            make.width.equalTo(self.view.mas_width).multipliedBy(1.0);
            make.height.equalTo(self.view.mas_height).multipliedBy(1.0);
        }];
    }
    return _videoView;
}


- (UIImageView *)testImageView {
    if (_testImageView == nil) {
        _testImageView = [[UIImageView alloc] init];
        _testImageView.contentMode = UIViewContentModeScaleAspectFit;
        _testImageView.backgroundColor = [UIColor redColor];
        _testImageView.layer.masksToBounds = YES;
        [self.view addSubview:_testImageView];
        [_testImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_top);
            make.left.equalTo(self.view.mas_left);
            make.width.equalTo(self.view.mas_width).multipliedBy(0.2);
            make.height.equalTo(self.view.mas_height).multipliedBy(0.2);
        }];
    }
    return _testImageView;
}

//- (TNFaceEyeView *)eyeView {
//    if (_eyeView == nil) {
//        _eyeView = [TNFaceEyeView instanceWithIndex:0];
//        [self.videoView addSubview:_eyeView];
//    }
//    return _eyeView;
//}

- (UIView *)right_eye_KeyPoint {
    if (_right_eye_KeyPoint == nil) {
        _right_eye_KeyPoint = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 5)];
        _right_eye_KeyPoint.layer.cornerRadius = 2.5;
        _right_eye_KeyPoint.layer.masksToBounds = YES;
        _right_eye_KeyPoint.backgroundColor = [UIColor redColor];
        [self.view addSubview:_right_eye_KeyPoint];
    }
    return _right_eye_KeyPoint;
}

- (UIView *)left_eye_KeyPoint {
    if (_left_eye_KeyPoint == nil) {
        _left_eye_KeyPoint = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 5)];
        _left_eye_KeyPoint.layer.cornerRadius = 2.5;
        _left_eye_KeyPoint.layer.masksToBounds = YES;
        _left_eye_KeyPoint.backgroundColor = [UIColor greenColor];
        [self.view addSubview:_left_eye_KeyPoint];
    }
    return _left_eye_KeyPoint;
}


- (void)exchangeCamera:(id)sender {
    [self.videoCamera rotateCamera];
    NSError *err;
    [self.videoCamera.inputCamera lockForConfiguration:&err];
    if ([self.videoCamera.inputCamera isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        [self.videoCamera.inputCamera setFocusMode:AVCaptureFocusModeAutoFocus];
    }
    if ([self.videoCamera.inputCamera isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
        [self.videoCamera.inputCamera setExposureMode:AVCaptureExposureModeAutoExpose];
    }
    [self.videoCamera.inputCamera unlockForConfiguration];
}

#pragma mark 摄像头回调
- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    IFlyFaceImage *faceImage = [TNFaceTools faceImageFromSampleBuffer:sampleBuffer cameraPosition:[self.videoCamera cameraPosition] deviceOrientation:self.deviceOrientation];
    NSString *result = [self.faceDetector trackFrame:faceImage.data withWidth:faceImage.width height:faceImage.height direction:(int)faceImage.direction];
    NSDictionary *json = [result objectFromJSONString];
    NSMutableArray<TNFaceModel *> *faceModels = [NSMutableArray array];
    for (NSDictionary *faceInfo in [json valueForKey:@"face"]) {
        [faceModels addObject:[TNFaceModel instanceWithInfo:faceInfo]];
    }
    [self drawPointWithFaces:faceModels faceImage:faceImage sampleBuffer:sampleBuffer];
    UIImage *iamge = [faceImage.image copy];
    __weak typeof(&*self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.testImageView.image = iamge;
    });
    faceImage.data = nil;
    faceImage.image = nil;
    faceImage = nil;
}

- (void)drawPointWithFaces:(NSArray<TNFaceModel *> *)faces faceImage:(IFlyFaceImage *)faceImage sampleBuffer:(CMSampleBufferRef)sampleBuffer {
    __weak typeof(&*self)weakSelf = self;

    if (CGRectGetWidth(self.videoView.frame) == 0 || CGRectGetHeight(self.videoView.frame) == 0 || faces.count != 1) {
        dispatch_async(dispatch_get_main_queue(), ^{
//            weakSelf.eyeView.hidden = YES;
            weakSelf.left_eye_KeyPoint.hidden = YES;
            weakSelf.right_eye_KeyPoint.hidden = YES;
        });
        return;
    }
    
    CGRect contentRect;
    // 计算宽高比
    if (faceImage.height / faceImage.width > CGRectGetWidth(self.videoView.frame) / CGRectGetHeight(self.videoView.frame)) {
        // 原图比view宽
        contentRect = CGRectMake(0, 0, (CGRectGetWidth(self.videoView.frame) / CGRectGetHeight(self.videoView.frame)) * faceImage.width, faceImage.width);
        contentRect.origin.x = (faceImage.height - CGRectGetWidth(contentRect)) / 2.0;
    } else {
        // 原图比view窄
        contentRect = CGRectMake(0, 0, faceImage.height, (CGRectGetHeight(self.videoView.frame) / CGRectGetWidth(self.videoView.frame)) * faceImage.height);
        contentRect.origin.y = (faceImage.width - CGRectGetHeight(contentRect)) / 2.0;
    }
    
    TNFaceModel *faceModel = faces.firstObject;
    
    CGPoint left_eye_superPoint = CGPointMake(faceModel.left_eye_center.y - CGRectGetMinX(contentRect), faceModel.left_eye_center.x - CGRectGetMinY(contentRect));
    CGPoint left_eye_realPoint = CGPointMake((CGRectGetWidth(self.videoView.frame) / CGRectGetWidth(contentRect)) * left_eye_superPoint.x, (CGRectGetHeight(self.videoView.frame) / CGRectGetHeight(contentRect)) * left_eye_superPoint.y);
    
//    CGPoint right_eye_superPoint = CGPointMake(faceModel.right_eye_center.y - CGRectGetMinX(contentRect), faceModel.right_eye_center.x - CGRectGetMinY(contentRect));
//    CGPoint right_eye_realPoint = CGPointMake((CGRectGetWidth(self.videoView.frame) / CGRectGetWidth(contentRect)) * right_eye_superPoint.x, (CGRectGetHeight(self.videoView.frame) / CGRectGetHeight(contentRect)) * right_eye_superPoint.y);
    
//     右眼半径
    CGFloat rightEyeWidth = sqrtf(pow(faceModel.left_eye_right_corner.x - faceModel.left_eye_left_corner.x, 2.0) + pow(faceModel.left_eye_right_corner.y - faceModel.left_eye_left_corner.y, 2.0));
    CGFloat rightEyeRadius = (rightEyeWidth / 2) / faceImage.width;
    CGPoint rightEyeCenter = CGPointMake(faceModel.left_eye_center.y / faceImage.height, faceModel.left_eye_center.x / faceImage.width);
    
//    CGFloat eyes_imageDistance = weakSelf.eyeView.right_eye - weakSelf.eyeView.left_eye;
//    CGFloat eyes_realDistance = sqrt(pow((left_eye_realPoint.x - right_eye_realPoint.x), 2) + pow((left_eye_realPoint.y - right_eye_realPoint.y), 2));
//    
//    // eyeView的中心
//    CGPoint eye_realCenter = CGPointMake((left_eye_realPoint.x + right_eye_realPoint.x) / 2, (left_eye_realPoint.y + right_eye_realPoint.y) / 2);
//    // eyeView的尺寸
//    CGRect eye_realBounds = CGRectMake(0, 0, (eyes_realDistance / eyes_imageDistance) * weakSelf.eyeView.width, (eyes_realDistance / eyes_imageDistance) * weakSelf.eyeView.height);
//    // eyeView的角度
//    CGFloat tanValue = (left_eye_realPoint.y - right_eye_realPoint.y) / (left_eye_realPoint.x - right_eye_realPoint.x);
//    CGFloat radian = atanf(tanValue); // 返回弧度
//    CGAffineTransform transform = CGAffineTransformMakeRotation(radian);
    
    dispatch_async(dispatch_get_main_queue(), ^{
//        rightEyeBulge.center = CGPointMake(rightEyeCenter.x, rightEyeCenter.y - 0.01);
//        rightEyeBulge.radius = rightEyeRadius;
        
        weakSelf.right_eye_KeyPoint.hidden = NO;
        weakSelf.right_eye_KeyPoint.center = left_eye_realPoint;
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
