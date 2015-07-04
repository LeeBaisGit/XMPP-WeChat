//
//  MROtherLoginViewController.m
//  WeChat
//
//  Created by 李白 on 15-7-4.
//  Copyright (c) 2015年 李白. All rights reserved.
//

#import "MROtherLoginViewController.h"
#import "AppDelegate.h"
#import "MBProgressHUD+HM.h"


@interface MROtherLoginViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightConstraint;
@property (weak, nonatomic) IBOutlet UITextField *accountField;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

- (IBAction)loginBtnClick:(id)sender;

- (IBAction)cancelBtnClick:(id)sender;


@end

@implementation MROtherLoginViewController


#pragma mark - 系统方法

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 判断是ipad还是iPhone 改变左右两边约束
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        self.leftConstraint.constant = 10;
        self.rightConstraint.constant = 10;
    }
    
    // 设置文本输入框的背景
    self.accountField.background = [UIImage stretchedImageWithName:@"operationbox_text"];
    self.pwdField.background = [UIImage stretchedImageWithName:@"operationbox_text"];
    
    [self.loginBtn setResizeN_BG:@"fts_green_btn" H_BG:@"fts_green_btn_HL"];
    
    
    
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

- (void)dealloc
{
    Mylog(@"-----");
}

#pragma mark - 控制器器内部方法
- (IBAction)loginBtnClick:(id)sender {
    // 获取账户名 和 密码
    NSString *account = self.accountField.text;
    NSString *pwd = self.pwdField.text;
    if (account != nil  && account.length > 0 && pwd != nil && pwd.length > 0) {
        // 保存 账户名和密码到沙盒
       NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        [defaults setValue:account forKey:@"account"];
        [defaults setValue:pwd forKey:@"pwd"];
        [defaults synchronize];
        
        [self.view endEditing:YES];
        
        // 添加提示遮盖
        [MBProgressHUD showMessage:@"正在登录中..." toView:self.view];
        
        // 登录
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        __weak typeof(self) selfVc = self; // block中使用 先转为weak 防止循环引用
        [appDelegate xmppUserLogin:^(XMPPResultType type) {
            [selfVc handleResultType:type];
        }];
    }
}

- (IBAction)cancelBtnClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - 其他方法
- (void)handleResultType:(XMPPResultType)type
{
    // 回到主线程刷新UI    所有的UI刷新都应该在UI中操作
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // 隐藏提示遮盖
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        switch (type) {
            case XMPPResultTypeSuccess:
                Mylog(@"登录成功");
                [self enterMainPage];
                break;
    
            case XMPPResultTypeFailure:
                Mylog(@"登录失败");
                [MBProgressHUD showError:@"用户名或密码错误" toView:self.view];
                break;
            case XMPPResultTypeNetError:
                [MBProgressHUD showError:@"网络不给力" toView:self.view];
            default:
                break;
        }
    });
}



/**
 *  进入主页面
 */
- (void)enterMainPage
{
    Mylog(@"------");
    // dismiss当前控制器
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // 加载main.storyboard
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    // 设为窗口的根控制器
    [UIApplication sharedApplication].keyWindow.rootViewController = storyBoard.instantiateInitialViewController;
    
}


@end
