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

@interface FilterCameraController ()<GPUImageVideoCameraDelegate>

@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic, strong) GPUImageView *videoView;;
@property (nonatomic, strong) GPUImageBrightnessFilter *brightness; // 亮度
@property (nonatomic, retain) IFlyFaceDetector *faceDetector;
@property (nonatomic, strong) UIImageView *testImageView;

@end

@implementation FilterCameraController

- (void)dealloc {
    [[GPUImageContext sharedImageProcessingContext].framebufferCache purgeAllUnassignedFramebuffers];
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
    
    self.videoView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    [self.videoCamera addTarget:self.videoView];
    [self.videoCamera startCameraCapture];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"切换" style:UIBarButtonItemStylePlain target:self action:@selector(exchangeCamera:)];
    
    self.faceDetector = [IFlyFaceDetector sharedInstance];
    if(self.faceDetector){
        [self.faceDetector setParameter:@"1" forKey:@"detect"];
        [self.faceDetector setParameter:@"1" forKey:@"align"];
    }
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
            make.width.equalTo(self.view.mas_width).multipliedBy(0.3);
            make.height.equalTo(self.view.mas_height).multipliedBy(0.3);
        }];
    }
    return _testImageView;
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
    IFlyFaceImage *faceImage = [TNFaceTools faceImageFromSampleBuffer:sampleBuffer camera:self.videoCamera];
    NSString* strResult = [self.faceDetector trackFrame:faceImage.data withWidth:faceImage.width height:faceImage.height direction:(int)faceImage.direction];
    NSLog(@"MonkeyHengLog: description === %@", strResult);
    
    UIImage *iamge = [faceImage.image copy];
    __weak typeof(&*self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.testImageView.image = iamge;
    });
    faceImage.data = nil;
    faceImage.image = nil;
    faceImage = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
