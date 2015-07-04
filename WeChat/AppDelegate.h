//
//  AppDelegate.h
//  WeChat
//
//  Created by 李白 on 15-7-3.
//  Copyright (c) 2015年 李白. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    XMPPResultTypeSuccess, // 登录成功
    XMPPResultTypeFailure,  // 登录失败
    XMPPResultTypeNetError
}XMPPResultType;

typedef void (^XMPPResultBlock)(XMPPResultType type); // XMPP请求结果的block


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

/**
 *  登录
 */
- (void)xmppUserLogin:(XMPPResultBlock)resultBlock;

/**
 *  退出登录
 */
- (void)xmppUserLogout;

@end

