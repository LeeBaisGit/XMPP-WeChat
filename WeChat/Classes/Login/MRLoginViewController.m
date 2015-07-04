//
//  MRLoginViewController.m
//  WeChat
//
//  Created by 李白 on 15-7-4.
//  Copyright (c) 2015年 李白. All rights reserved.
//

#import "MRLoginViewController.h"

@interface MRLoginViewController ()

/**
 *  账号
 */
@property (weak, nonatomic) IBOutlet UILabel *accountLabel;

/**
 *  密码
 */
@property (weak, nonatomic) IBOutlet UITextField *pwdField;

@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

/**
 *  登录按钮点击
 */
- (IBAction)loginBtnClick:(id)sender;
@end

@implementation MRLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.accountLabel.text = [MRUserInfo sharedMRUserInfo].account;
    
    // 设置文本输入框的背景
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

- (IBAction)loginBtnClick:(id)sender {
    
    
}

- (void)dealloc
{
    Mylog(@"----");
}

@end
