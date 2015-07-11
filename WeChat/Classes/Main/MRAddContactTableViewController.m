//
//  MRAddContactTableViewController.m
//  WeChat
//
//  Created by 李白 on 15-7-11.
//  Copyright (c) 2015年 李白. All rights reserved.
//

#import "MRAddContactTableViewController.h"

@interface MRAddContactTableViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *addContactField;

@end

@implementation MRAddContactTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"添加联系人";
    
    [self.addContactField addLeftViewWithImage:@"add_friend_searchicon"];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 弹出键盘
    [self.addContactField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // 关闭键盘
    [self.view endEditing:YES];
    Mylog(@"%@", textField.text);

    // 判断这个跟账号是否为手机号码
    if (![textField isTelphoneNum]) {
        // 提示
        [self showAlert:@"请输入正确的手机号码"];
        return YES;
    }
    
    // 获取好友账号
    NSString *account = textField.text;
    
    // 判断是否添加自己
    if ([account isEqualToString:[MRUserInfo sharedMRUserInfo].account]) {
        // 提示 不能添加自己为好友
        [self showAlert:@"不能添加自己为好友"];
        return YES;
    }
    
    XMPPJID *otherJid = [XMPPJID jidWithUser:textField.text domain:@"libai.local" resource:nil];
    
    // 判断好友是否已经存在
    if ([[MRXMPPTool sharedMRXMPPTool].rosterStorage userExistsWithJID:otherJid xmppStream:[MRXMPPTool sharedMRXMPPTool].xmppStream]) {
        // 提示
        [self showAlert:@"当前好友已在联系人列表中"];
        return YES;
    }
    
    // 发送添加发送好友的请求
    // 添加好友 ，xmpp里叫做 订阅
    [[MRXMPPTool sharedMRXMPPTool].roster subscribePresenceToUser:otherJid];
    
//    [[MRXMPPTool sharedMRXMPPTool].roster addUser:otherJid withNickname:nil];
    
    // 清空文本框
    textField.text = nil;
    
    // 返回上一级控制器
    [self.navigationController popViewControllerAnimated:YES];
    
    return YES;
}

- (void)showAlert:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}



@end
