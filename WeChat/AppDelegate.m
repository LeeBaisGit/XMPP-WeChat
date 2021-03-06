//
//  AppDelegate.m
//  WeChat
//
//  Created by 李白 on 15-7-3.
//  Copyright (c) 2015年 李白. All rights reserved.
//

#import "AppDelegate.h"
#import "XMPPFramework.h"
#import "MRNavgationViewController.h"

/*
 * 在AppDelegate实现登录
 
 1. 初始化XMPPStream
 2. 连接到服务器[传一个JID]
 3. 连接到服务成功后，再发送密码授权
 4. 授权成功后，发送"在线" 消息
 */
@interface AppDelegate ()<XMPPStreamDelegate>
//{
//    XMPPStream *_xmppStream;
//    XMPPResultBlock _resultBlock;
//}
//
//- (void)setupXMPPStream;
//
//- (void)connectToHost;
//
//- (void)authenticateWithPassword;
//
//- (void)sendOnlineToHost;

@end


@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // 设置导航栏主题
    [MRNavgationViewController setupNavTheme];
    
    // 从沙盒中获取用户信息
    [[MRUserInfo sharedMRUserInfo] loadFromSanbox];
    
    // 判断用户登录状态 如果登录过没有注销 直接进入主页面
    BOOL loginStatus = [MRUserInfo sharedMRUserInfo].loginStatus;
    if (loginStatus) { // 登录过未注销
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.window.rootViewController = storyboard.instantiateInitialViewController;
        // 自动连接服务器
        [[MRXMPPTool sharedMRXMPPTool] xmppUserLogin:nil];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//#pragma mark - 私有方法
//- (void)setupXMPPStream
//{
//    // 创建XMMP流
//    _xmppStream = [[XMPPStream alloc] init];
//    
//    // 设置代理
//    [_xmppStream addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
//    
//}
//- (void)connectToHost
//{
//    Mylog(@"开始连接到主机");
//    // 判断是否存在XMPP流
//    if (_xmppStream == nil) {
//        [self setupXMPPStream];
//    }
//    
//    MRUserInfo *userInfo = [MRUserInfo sharedMRUserInfo];
//    
//    NSString *account = nil;
//    if (self.isRegisterUser) {
//        account = userInfo.registerAccount;
//    }else {
//        account = userInfo.account;
//    }
//    
//    // 设置JID
//    XMPPJID *myJID = [XMPPJID jidWithUser:account domain:@"libai.local" resource:@"iphone"];
//    _xmppStream.myJID = myJID;
//    
//    // 设置服务器域名 也可以是IP
//    _xmppStream.hostName = @"libai.local";
//    // 设置主机端口
//    _xmppStream.hostPort = 5222;
//    
//    // 连接主机
//    NSError *error = nil;
//    if (![_xmppStream connectWithTimeout:-1 error:&error]) {
//        Mylog(@"%@", error);
//    }
//}
//- (void)authenticateWithPassword
//{
//    Mylog(@"发送密码进行授权");
//    
//    // 从沙盒中获取密码
//    NSString *pwd = [MRUserInfo sharedMRUserInfo].pwd;
//    NSError *error = nil;
//   
//    
//        if (![_xmppStream authenticateWithPassword:pwd error:&error]) {
//            Mylog(@"%@", error);
//        }
//}
//
//
//- (void)sendOnlineToHost
//{
//    Mylog(@"发送'在线'消息");
//    XMPPPresence *presence = [XMPPPresence presence];
//    
//    [_xmppStream sendElement:presence];
//    
//}
//
//- (void)registerWithPassword
//{
//    Mylog(@"发送密码进行注册");
//    // 从单例中获取注册密码
//    NSString *pwd = [MRUserInfo sharedMRUserInfo].registerPwd;
//    NSError *error = nil;
//    if (![_xmppStream registerWithPassword:pwd error:&error]) {
//        Mylog(@"%@", error);
//    }
//
//}
//
//#pragma mark - 代理方法 XMPPStreamDelegate
///**
// *  连接到主机时调用
// *
// *  @param sender
// */
//- (void)xmppStreamDidConnect:(XMPPStream *)sender
//{
//    // 连接成功时发送密码进行登录或注册
//    // 判读是注册还是登录
//    if([self isRegisterUser]){  // 注册
//        [self registerWithPassword];
//    }else { // 登录
//        [self authenticateWithPassword];
//    }
//    
//    
//}
///**
// *  与主机断开连接时调用
// *
// *  @param sender
// *  @param error
// */
//- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
//{
//    Mylog(@"%@", error);
//    
//    if (error && _resultBlock) {
//        _resultBlock(XMPPResultTypeNetError);
//    }
//}
///**
// *  获取授权时调用
// *
// *  @param sender
// */
//- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
//{
//    Mylog(@"授权成功");
//    // 发送在线消息
//    [self sendOnlineToHost];
//    
//    // 回调控制器登录成功
//    if (_resultBlock) {
//        _resultBlock(XMPPResultTypeSuccess);
//    }
//}
///**
// *  获取授权失败时调用
// *
// *  @param sender
// *  @param error
// */
//- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error
//{
//    Mylog(@"%@", error);
//    if (_resultBlock) {
//        _resultBlock(XMPPResultTypeFailure);
//    }
//}
///**
// *  注册成功时调用
// *
// *  @param sender
// */
//- (void)xmppStreamDidRegister:(XMPPStream *)sender
//{
//    Mylog(@"注册成功");
//    if (_resultBlock) {
//        _resultBlock(XMPPResultTypeRegisterSuccess);
//    }
//}
//
//- (void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error
//{
//    NSLog(@"注册失败%@", error);
//    if (error && _resultBlock) {
//        _resultBlock(XMPPResultTypeRegisterFailure);
//    }
//    
//}
//
//
//#pragma mark - 公有方法 提供给外界访问
///**
// *  登录
// */
//- (void)xmppUserLogin:(XMPPResultBlock)resultBlock
//{
//    // 先把block保存起来 以便其他地方拿到
//    _resultBlock = resultBlock;
//    
//    // 判断是否有连接存在 如果有则断开
////    if (_xmppStream.isConnected) {
////        [_xmppStream disconnect];
////    }
//    // 或者 不管有没有都断开上一次的连接
//    [_xmppStream disconnect];
//    
//    
//    // 连接主机 成功后 发送密码授权
//    [self connectToHost];
//}
//
///**
// *  退出登录
// */
//- (void)xmppUserLogout;
//{
//    Mylog(@"发送离线消息");
//    // 发送离线消息
//    XMPPPresence *offline = [XMPPPresence presenceWithType:@"unavailable"];
//    [_xmppStream sendElement:offline];
//    
//    // 与服务器断开连接
//    [_xmppStream disconnect];
//    
//    // 跳转到登陆的storyboard
//    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
//    
//    self.window.rootViewController = storyBoard.instantiateInitialViewController;
//    
//    // 注销时设置登录状态为NO
//    [MRUserInfo sharedMRUserInfo].loginStatus = NO;
//    
//}
//
//- (void)xmppUserRegister:(XMPPResultBlock)resultBlock
//{
//    // 保存block
//    _resultBlock = resultBlock;
//    
//    // 不管有没有都断开上一次的连接
//    [_xmppStream disconnect];
//    
//    [self connectToHost];
//
//}


@end
