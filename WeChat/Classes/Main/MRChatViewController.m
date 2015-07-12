//
//  MRChatViewController.m
//  WeChat
//
//  Created by 李白 on 15-7-11.
//  Copyright (c) 2015年 李白. All rights reserved.
//

#import "MRChatViewController.h"
#import "MRInputView.h"


@interface MRChatViewController ()<UITextViewDelegate,UITableViewDataSource, UITableViewDelegate,NSFetchedResultsControllerDelegate>
{
    NSFetchedResultsController *_fetchResultsController;
}

@property(nonatomic,weak)NSLayoutConstraint *inputViewBottomCons;

@property(nonatomic,weak)NSLayoutConstraint *inputViewHeightCons;

@property(nonatomic,weak)UITableView *tableView;

@end

@implementation MRChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSLog(@"%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]);
    
    
    // 初始化子控件
    [self setupSubviews];
    
    // 监听键盘通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];

    
    // 加载聊天数据
    [self loadMessage];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    Mylog(@"----");
}


#pragma mark - 其他方法
- (void)setupSubviews
{
    // 添加subviews
    // 添加tableView
    UITableView *tableView = [[UITableView alloc] init];
//    tableView.backgroundColor = [UIColor redColor];
#warning 代码实现自动布局，要设置下面的属性为NO
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    // 添加inputView
    MRInputView *inputView = [MRInputView inputView];
    inputView.translatesAutoresizingMaskIntoConstraints = NO;
    inputView.textView.delegate = self;
    [self.view addSubview:inputView];
    

    // 自动布局 添加subviews的约束
    // 添加水平方向约束
    NSDictionary *views = @{@"tableView" : tableView,
                            @"inputView" : inputView
                            };
    // 1.tableView
    NSArray *tableViewCons = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[tableView]-0-|" options:0 metrics:nil views:views];
    [self.view addConstraints:tableViewCons];
    
    // 2.inputView
    NSArray *inputViewCons = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[inputView]-0-|" options:0 metrics:nil views:views];
    [self.view addConstraints:inputViewCons];
    
    // 添加垂直方向的约束
    // tableView
    NSArray *vCons = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[tableView]-0-[inputView(50)]-0-|" options:0 metrics:nil views:views];
    [self.view addConstraints:vCons];
    Mylog(@"%@", vCons);
    // 获取inputView底部的约束
    self.inputViewBottomCons = [vCons lastObject];
    // 获取inputView高度的约束
    self.inputViewHeightCons = vCons[2];
}

/**
 *   加载聊天数据
 */
- (void)loadMessage
{
    // 上下文
    NSManagedObjectContext *context = [MRXMPPTool sharedMRXMPPTool].messageStorage.mainThreadManagedObjectContext;
    
    // 抓取请求
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
    
    // 过滤
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@ AND bareJidStr = %@",[MRUserInfo sharedMRUserInfo].jid, self.friendJid.bare];
    
    request.predicate = pre;
    // 排序
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    request.sortDescriptors = @[sort];
    
    // 创建抓取结果控制器
    _fetchResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    // 设置代理
    _fetchResultsController.delegate = self;
    // 开始抓取结果
    NSError *error = nil;
    [_fetchResultsController performFetch:&error];
    if (error) {
        Mylog(@"%@", error);
    }
    
    
}


#pragma mark - 键盘通知的监听
- (void)keyboardDidShow:(NSNotification *)notification
{
    Mylog(@"%@", notification.userInfo);
    
    NSTimeInterval interval = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    __block CGFloat keyboardHeight = keyboardRect.size.height;
    [UIView animateWithDuration:interval animations:^{
        // IOS8之前ipad的横竖屏
        //竖屏{{0, 0}, {768, 264}
        //横屏{{0, 0}, {352, 1024}}
        // 如果是ios7以下的，当屏幕是横屏键盘的高底是size.with
        if ([[UIDevice currentDevice].systemVersion doubleValue] < 8.0 && UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            keyboardHeight = keyboardRect.size.width;
        }

        self.inputViewBottomCons.constant = keyboardHeight;
    }];

}

- (void)keyboardDidHide:(NSNotification *)notification
{
//    Mylog(@"%@", notification.userInfo);
    NSTimeInterval interval = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
//    CGRect keyRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [UIView animateWithDuration:interval animations:^{
//        self.inputViewBottomCons.constant = keyRect.size.height;
       
        // 隐藏键盘 键盘距离底部的约束永远为0
        self.inputViewBottomCons.constant = 0;
    }];
    
}



#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView
{
    NSString *text = textView.text;
    Mylog(@"%@", text);
    
    Mylog(@"%@", NSStringFromCGSize(textView.contentSize));
    
    // 文本输入框输入的内容 大于1行 且小于3行的情况下 设置inputView的高度随着行数增加增加
    if (textView.contentSize.height > 33 && textView.contentSize.height < 68) {
        self.inputViewHeightCons.constant = textView.contentSize.height + 20;
    }

}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    Mylog(@"%lu", (unsigned long)_fetchResultsController.fetchedObjects.count);
    return _fetchResultsController.fetchedObjects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"chat";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    // 获取聊天消息对象
    XMPPMessageArchiving_Message_CoreDataObject *message =  _fetchResultsController.fetchedObjects[indexPath.row];
    
    Mylog(@"%@", _fetchResultsController.fetchedObjects);
    NSString *text = nil;
    if ([message.outgoing integerValue]) { // 发出
        text = [NSString stringWithFormat:@"我:%@", message.body];
    }else { // 接收
        text = [NSString stringWithFormat:@"好友:%@", message.body];
    }
    
    cell.textLabel.text = text;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    // 关闭键盘
    [self.view endEditing:YES];
}

#pragma mark - NSFetchedResultsControllerDelegate
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // 刷新表格
    [self.tableView reloadData];
}

@end
