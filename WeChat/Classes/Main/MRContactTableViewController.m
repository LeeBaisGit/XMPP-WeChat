//
//  MRContactTableViewController.m
//  WeChat
//
//  Created by 李白 on 15-7-8.
//  Copyright (c) 2015年 李白. All rights reserved.
//

#import "MRContactTableViewController.h"
#import <CoreData/CoreData.h>

@interface MRContactTableViewController ()<NSFetchedResultsControllerDelegate>
{
    NSFetchedResultsController *_resultController;
}

@property(nonatomic,strong)NSArray *friends;

@end

@implementation MRContactTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 加载好友数据
    [self loadFriends2];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 初始化方法
- (void)loadFriends
{
    // 使用CoreData获取数据
    // 1.获取上下文
    NSManagedObjectContext *context = [MRXMPPTool sharedMRXMPPTool].rosterStorage.mainThreadManagedObjectContext;
    
    // 2.创建抓取数据的请求 FetchRequest (查询哪张表)
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
    
    // 设置过滤和排序
    // 过滤当前登录用户的好友
    NSString *jid = [MRUserInfo sharedMRUserInfo].jid;
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@", jid];
    request.predicate = pre;
    
    // 排序
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    request.sortDescriptors = @[sort];
    
    // 4.执行抓取数据请求 获取数据
    NSError *error = nil;
    self.friends = [context executeFetchRequest:request error:&error];
    Mylog(@"%@", self.friends);
    if (error) {
        Mylog(@"%@", error);
    }
}

- (void)loadFriends2
{
    // 使用CoreData获取数据
    // 1.获取上下文
    NSManagedObjectContext *context = [MRXMPPTool sharedMRXMPPTool].rosterStorage.mainThreadManagedObjectContext;
    
    // 2.创建抓取数据的请求 FetchRequest (查询哪张表)
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
    
    // 设置过滤和排序
    // 过滤当前登录用户的好友
    NSString *jid = [MRUserInfo sharedMRUserInfo].jid;
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@", jid];
    request.predicate = pre;
    
    // 排序
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    request.sortDescriptors = @[sort];
    
    // 4.执行抓取数据请求 获取数据
//    NSError *error = nil;
//    self.friends = [context executeFetchRequest:request error:&error];
//    Mylog(@"%@", self.friends);
//    if (error) {
//        Mylog(@"%@", error);
//    }
    
    _resultController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    
    _resultController.delegate = self;
    
    NSError *error = nil;
    if (![_resultController performFetch:&error]) {
        Mylog(@"%@", error);
    }
    
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
//    return self.friends.count;
    return _resultController.fetchedObjects.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *identifier = @"contact";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    // 获取对用的好友数据
//    XMPPUserCoreDataStorageObject *storageObject = self.friends[indexPath.row];
    
    XMPPUserCoreDataStorageObject *storageObject = _resultController.fetchedObjects[indexPath.row];
    
    Mylog(@"%@", _resultController.fetchedObjects);
    
    cell.textLabel.text = storageObject.jidStr;
    //    sectionNum
    //    “0”- 在线
    //    “1”- 离开
    //    “2”- 离线
    NSString *detail = nil;
    switch ([storageObject.sectionNum intValue]) {
        case 0:
            detail = @"在线";
            break;
        case 1:
            detail = @"离开";
            break;
        case 2:
            detail = @"离线";
            break;
        default:
            break;
    }
    cell.detailTextLabel.text = detail;
    
    return cell;
}

// 实现这个方法，cell往左滑就会出现delete选项
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Mylog(@"删除好友");
        XMPPUserCoreDataStorageObject *friend = _resultController.fetchedObjects[indexPath.row];
        
        XMPPJID *friendJid = friend.jid;
        
        // 调用花名册的removeUser：方法 XMPP框架内部会根据JID删除好友 并告诉XMPP
        // XMPP会向服务器发送修改后的数据且自动删除sqlite数据库里的数据
        [[MRXMPPTool sharedMRXMPPTool].roster removeUser:friendJid];
    }
    
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - NSFetchedResultsControllerDelegate
/**
 *  sqlite里存储的花名册数据发生改变时调用
 *
 *  @param controller
 */
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    Mylog(@"数据发生改变");
    // 刷新表格
    [self.tableView reloadData];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    Mylog(@"-----");
}

@end
