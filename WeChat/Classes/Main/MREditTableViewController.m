//
//  MREditTableViewController.m
//  WeChat
//
//  Created by 李白 on 15-7-8.
//  Copyright (c) 2015年 李白. All rights reserved.
//

#import "MREditTableViewController.h"

@interface MREditTableViewController ()
@property (weak, nonatomic) IBOutlet UITextField *editTextField;

@end

@implementation MREditTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // 设置标题为要修改的属性
    self.title = self.cell.textLabel.text;
    // 设置文本框内文字为要修改的属性的值
    self.editTextField.text = self.cell.detailTextLabel.text;
    
    // 添加导航栏上右边 保存按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(saveBtnClick)];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  保存按钮的点击
 */
- (void)saveBtnClick
{
    // 更改cell的detailTextLabel的文字
    self.cell.detailTextLabel.text = self.editTextField.text;
    
    [self.cell layoutSubviews];
    
    // 出栈当前控制器 返回上一个控制器
    [self.navigationController popViewControllerAnimated:YES];
    
    if ([self.delegate respondsToSelector:@selector(editTableViewControllerDidFinshedEdit)]) {
        [self.delegate editTableViewControllerDidFinshedEdit];
    }
    
}

@end
