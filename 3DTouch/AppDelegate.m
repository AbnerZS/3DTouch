//
//  AppDelegate.m
//  3DTouch
//
//  Created by abnerzhang on 2016/12/12.
//  Copyright © 2016年 abnerzhang. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self configShortCutItems];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    RootViewController *rootVC = [[RootViewController alloc] init];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:rootVC];
    self.window.rootViewController = navi;
    [self.window makeKeyAndVisible];
    
    if (launchOptions[@"UIApplicationLaunchOptionsShortcutItemKey"] == nil) {
        return YES;
    } else {
        return NO;
    }
}

/*
 * 长按应用图标, 触发3dtouch
 * 创建shortcutItems
 */
- (void)configShortCutItems {
    NSMutableArray *shortcutItems = [NSMutableArray array];
    
    
    // 系统默认的图标,一个小黑点
    UIApplicationShortcutItem *item1 = [[UIApplicationShortcutItem alloc] initWithType:@"1" localizedTitle:@"测试1"];
    
    // 系统的播放图标, 其他图标参考UIApplicationShortcutIconTypePlay枚举
    UIApplicationShortcutIcon *icon2 = [UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypePlay];
    UIApplicationShortcutItem *item2 = [[UIApplicationShortcutItem alloc] initWithType:@"2" localizedTitle:@"测试2" localizedSubtitle:@"测试2" icon:icon2 userInfo:nil];
    
    // 添加一张图片, 设置为3dtouch显示的图标
    UIApplicationShortcutIcon *shortcutIcon = [UIApplicationShortcutIcon iconWithTemplateImageName:@"icon_1"];
    UIApplicationShortcutItem *item3 = [[UIApplicationShortcutItem alloc] initWithType:@"3" localizedTitle:@"测试3" localizedSubtitle:@"测试3" icon:shortcutIcon userInfo:nil];
    
    [shortcutItems addObject:item1];
    [shortcutItems addObject:item2];
    [shortcutItems addObject:item3];
    [[UIApplication sharedApplication] setShortcutItems:shortcutItems];
}

/** 处理shortcutItem */
- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    switch (shortcutItem.type.integerValue) {
        case 1: { // 测试1
            [[NSNotificationCenter defaultCenter] postNotificationName:@"gotoVC" object:self userInfo:@{@"type":@"1"}];
        }   break;
        case 2: { // 测试2
            [[NSNotificationCenter defaultCenter] postNotificationName:@"gotoVC" object:self userInfo:@{@"type":@"2"}];
        }   break;
        case 3: { // 测试3
            [[NSNotificationCenter defaultCenter] postNotificationName:@"gotoVC" object:self userInfo:@{@"type":@"3"}];
        }   break;
        default:
            break;
    }
}

/*
 * 另一种设置方式
 <key>UIApplicationShortcutItems</key>
 <array>
 <dict>
 <key>UIApplicationShortcutItemType</key>
 <string>test1</string>
 <key>UIApplicationShortcutItemTitle</key>
 <string>标题</string>
 <key>UIApplicationShortcutItemSubtitle</key>
 <string>副标题</string>
 <key>UIApplicationShortcutItemIconFile</key>
 <string>icon</string>
 </dict>
 </array>
 */
@end
