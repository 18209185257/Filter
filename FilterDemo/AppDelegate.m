//
//  AppDelegate.m
//  FilterDemo
//
//  Created by zhangheng on 2017/4/24.
//  Copyright © 2017年 zhangheng. All rights reserved.
//

#import "AppDelegate.h"
#import <iflyMSC/IFlyFaceSDK.h>

#define USER_APPID           @"5907f8c4"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [IFlySetting showLogcat:NO];
    
    //创建语音配置,appid必须要传入，仅执行一次则可
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@,",USER_APPID];
    //    所有服务启动前，需要确保执行createUtility
    [IFlySpeechUtility createUtility:initString];
    return YES;
}

@end
