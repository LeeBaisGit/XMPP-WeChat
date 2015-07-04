//
//  MRNavgationViewController.m
//  WeChat
//
//  Created by 李白 on 15-7-4.
//  Copyright (c) 2015年 李白. All rights reserved.
//

#import "MRNavgationViewController.h"

@interface MRNavgationViewController ()

@end

@implementation MRNavgationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - 公有方法
+ (void)setupNavTheme
{
    UINavigationBar *navBar = [UINavigationBar appearance];
//    navBar.backIndicatorImage = [UIImage imageNamed:@"topbarbg_ios7"];
    // 设置导航栏背景
    // 高度不会拉伸，宽度会自动拉伸
    [navBar setBackgroundImage:[UIImage imageNamed:@"topbarbg_ios7"] forBarMetrics:UIBarMetricsDefault];
    
    // 设置导航栏字体
    NSMutableDictionary *attr = [NSMutableDictionary dictionary];
    attr[NSForegroundColorAttributeName] = [UIColor whiteColor];
    attr[NSFontAttributeName] = [UIFont systemFontOfSize:20];
    [navBar setTitleTextAttributes:attr];
    
    // 设置状态栏样式
    // Xcode5以上，创建的项目，默认的话，这个状态栏的样式由控制器决定 可以一个控制器对应一个样式
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;


}

// 结论：如果控制器是由导航控制器管理，设置状态栏的样式要再导航控制器里设置
//- (UIStatusBarStyle)preferredStatusBarStyle
//{
//    return UIStatusBarStyleLightContent;
//}

@end
