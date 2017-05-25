//
//  ViewController.m
//  FilterDemo
//
//  Created by zhangheng on 2017/5/25.
//  Copyright © 2017年 zhangheng. All rights reserved.
//

#import "ViewController.h"
#import "FilterPhotoController.h"
#import <TZImagePickerController.h>

@interface ViewController ()

@end

@implementation ViewController

- (IBAction)showPhoto:(id)sender {
    TZImagePickerController *controller = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:nil];
    controller.allowPickingVideo = NO;
    controller.allowPickingGif = NO;
    __weak typeof(&*self)weakSelf = self;
    [controller setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos,NSArray *assets,BOOL isSelectOriginalPhoto){
        FilterPhotoController *controller = [FilterPhotoController new];
        controller.photo = photos.firstObject;
        [weakSelf.navigationController pushViewController:controller animated:YES];
    }];
    [self.navigationController presentViewController:controller animated:YES completion:nil];
}


@end
