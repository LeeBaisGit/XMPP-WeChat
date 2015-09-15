//
//  MRChatViewController.m
//  WeChat
//
//  Created by 李白 on 15-7-11.
//  Copyright (c) 2015年 李白. All rights reserved.
//

#import "MRChatViewController.h"
#import "MRInputView.h"
#import "HttpTool.h"
#import "UIImageView+WebCache.h"

@interface MRChatViewController ()<UITextViewDelegate,UITableViewDataSource, UITableViewDelegate,NSFetchedResultsControllerDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    NSFetchedResultsController *_fetchResultsController;
}

@property(nonatomic,weak)NSLayoutConstraint *inputViewBottomCons;

@property(nonatomic,weak)NSLayoutConstraint *inputViewHeightCons;

@property(nonatomic,weak)UITableView *tableView;

@property(nonatomic,strong)HttpTool *httpTool;

@end

@implementation MRChatViewController

#pragma mark - 懒加载
- (HttpTool *)httpTool
{
    if (_httpTool == nil) {
        _httpTool = [[HttpTool alloc] init];
    }
    return _httpTool;
}


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
    [inputView.addBtn addTarget:self action:@selector(addBtnClick) forControlEvents:UIControlEventTouchUpInside];
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

#pragma mark inputView中“+”按钮的点击
- (void)addBtnClick
{
    // 判断相册是否可用
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        // 提示
        [MBProgressHUD showError:@"相册不可用" toView:self.view];
        return;
    }
    
    // 创建图片选择器
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    // 设置图片来源
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    // 设置代理
    imagePicker.delegate = self;
    
    // 显示图片选择器
    [self presentViewController:imagePicker animated:YES completion:nil];
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
        Mylog(@"%f", textView.contentSize.height);
        self.inputViewHeightCons.constant = textView.contentSize.height + 20;
    }
    
    // 聊天消息发送
    // textView中得文字编辑完成之后  换行就等于点击了send按钮
    if ([text rangeOfString:@"\n"].length != 0) {
        [self sendMessageWithText:text bodyType:@"text"];
        // 发送完成 清空数据
        textView.text = nil;
        // 修改约束为初始值
        self.inputViewHeightCons.constant = 50;
    }
    

}

#pragma mark 发送聊天数据
- (void)sendMessageWithText:(NSString *)text bodyType:(NSString *)bodyType
{
    // 创建聊天信息 设置聊天类型和聊天对象
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:self.friendJid];
    // 设置聊天内容
    [message addBody:text];
    
    [message addAttributeWithName:@"bodyType" stringValue:bodyType];
    
    // 发送聊天消息
    [[MRXMPPTool sharedMRXMPPTool].xmppStream sendElement:message];
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
    // 判断是纯文本还是图片
    NSString *bodyType = [message.message attributeStringValueForName:@"bodyType"];
    if ([bodyType isEqualToString:@"image"]) {
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:message.body] placeholderImage:[UIImage imageNamed:@"DefaultProfileHead_qq"]];
        cell.textLabel.text = nil;
    }else if ([bodyType isEqualToString:@"text"]){
        NSString *text = nil;
        if ([message.outgoing integerValue]) { // 发出
            text = [NSString stringWithFormat:@"我:%@", message.body];
        }else { // 接收
            text = [NSString stringWithFormat:@"好友:%@", message.body];
        }
        cell.textLabel.text = text;
        cell.imageView.image = nil;
    }
    
    
    // 滚动到最新的聊天信息
    [self scrollToBottom];
    
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
    // 滚动到最新的聊天信息
    [self scrollToBottom];
}

/**
 *  滚动到聊天数据的最新一条
 */
- (void)scrollToBottom
{
    if (_fetchResultsController.fetchedObjects.count) {
        // 获取索引
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_fetchResultsController.fetchedObjects.count - 1 inSection:0];
        // 滚动到最新的聊天数据
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
}

#pragma mark - UINavigationControllerDelegate, UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    Mylog(@"%@", info);
    // dimiss控制器
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // 获取图片
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    // 转换成二进制数据
    NSData *data = UIImageJPEGRepresentation(image, 1.0);

    // 拼接文件名 用户名 + 时间(201412111537)年月日时分秒
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *timeStr = [formatter stringFromDate:[NSDate date]];
    
    NSString *fileName = [[MRUserInfo sharedMRUserInfo].account stringByAppendingString:timeStr];
    
    NSString *uploadFileUrl = [@"http://localhost:8080/imfileserver/Upload/Image/" stringByAppendingString:fileName];
    
    // 使用HTTP put 上传
    [self.httpTool uploadData:data url:[NSURL URLWithString:uploadFileUrl] progressBlock:nil completion:^(NSError *error) {
        if (error) {
            Mylog(@"%@", error);
        }else {
            Mylog(@"上传成功");
            // 图片发送成功，把图片的URL传Openfire的服务
            [self sendMessageWithText:uploadFileUrl bodyType:@"image"];
        }
    }];
    
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    Mylog(@"---");
}

@end
