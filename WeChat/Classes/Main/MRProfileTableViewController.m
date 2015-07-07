//
//  MRProfileTableViewController.m
//  WeChat
//
//  Created by 李白 on 15-7-7.
//  Copyright (c) 2015年 李白. All rights reserved.
//

#import "MRProfileTableViewController.h"
#import "XMPPvCardTemp.h"
#import "MREditTableViewController.h"


@interface MRProfileTableViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate, MREditTableViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *nikNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *accountLabel;
@property (weak, nonatomic) IBOutlet UILabel *orgLabel;
@property (weak, nonatomic) IBOutlet UILabel *departLabel;
@property (weak, nonatomic) IBOutlet UILabel *positionLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;


@end

@implementation MRProfileTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // 取出当前用户的电子名片
    XMPPvCardTemp *myvCard = [MRXMPPTool sharedMRXMPPTool].vCard.myvCardTemp;
    if (myvCard.photo) {
        UIImage *icon = [UIImage imageWithData:myvCard.photo scale:1.0];
        self.iconView.image = icon;
    }
    self.nikNameLabel.text = myvCard.nickname;
    Mylog(@"%@", myvCard.nickname);
    self.accountLabel.text = [MRUserInfo sharedMRUserInfo].account;
    self.orgLabel.text = myvCard.orgName;
    if (myvCard.orgUnits.count > 0) {
        self.departLabel.text = [myvCard.orgUnits firstObject];
    }
    self.positionLabel.text = myvCard.title;
    // myVCard.telecomsAddresses 这个get方法，没有对电子名片的xml数据进行解析
    // 使用note字段充当电话
    self.phoneLabel.text = myvCard.note;
    //邮件
    // 用mailer充当邮件
    self.emailLabel.text = myvCard.mailer;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    Mylog(@"------");
}



#pragma mark - Table view data source  静态tableViewCell不需要数据源方法来设置cell

#pragma mark - UItableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 主动取消选中状态
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.accessoryType == UITableViewCellAccessoryDisclosureIndicator) {
        if (cell.editingAccessoryType == UITableViewCellAccessoryDisclosureIndicator) {
            Mylog(@"更换头像");
            // 弹出提示框 选择从相册还是从相机选择图片
            UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"选择照片" message:@"你可以从以下几种方式选中照片" preferredStyle:UIAlertControllerStyleActionSheet];
            /*
             *** Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'Text fields can only be added to an alert controller of style UIAlertControllerStyleAlert'
             */
//            [alertVc addTextFieldWithConfigurationHandler:^(UITextField *textField) {
//                Mylog(@"addtext");
//            }];
            
            UIAlertAction *cam = [UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                Mylog(@"相机");
                [self choseImageWithSourceType:UIImagePickerControllerSourceTypeCamera];
            }];
            [alertVc addAction:cam];
            
            UIAlertAction *abum = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                Mylog(@"相册");
                [self choseImageWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            }];
            [alertVc addAction:abum];
            
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                Mylog(@"取消");
            }];
            [alertVc addAction:cancel];
            
            [self presentViewController:alertVc animated:YES completion:nil];
        }else {
            Mylog(@"修改名称");
            
            // 手动执行segue的跳转
            [self performSegueWithIdentifier:@"profile2edit" sender:cell];
        }
    }
}

- (void)choseImageWithSourceType:(UIImagePickerControllerSourceType)sourceType
{
    // 判断设备是否可用
    if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        UIImagePickerController *imagePickerVc = [[UIImagePickerController alloc] init];
        // 设置图片来源
        imagePickerVc.sourceType = sourceType;
        // 设置代理
        imagePickerVc.delegate = self;
        // 设置是否允许编辑图片 此项可用调整选择图片的尺寸
        imagePickerVc.allowsEditing = YES;
        [self presentViewController:imagePickerVc animated:YES completion:nil];
    }
    
    
}



#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    MREditTableViewController *editVc = segue.destinationViewController;
    editVc.cell = sender;
    // 设置当前控制器为编辑控制器的代理
    editVc.delegate = self;
}


#pragma mark - UIImagePickerControllerDelegate
/**
 *  选择完成图片后调用
 *
 *  @param picker
 *  @param info
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
//    Mylog(@"%@", info);
    // 获取编辑后的图片
    UIImage *image = info[UIImagePickerControllerEditedImage];
    
    // 设置头像图片
    self.iconView.image = image;
    
    // dismiss图片选择器窗口
    [picker dismissViewControllerAnimated:YES completion:nil];

    // 更新头像到服务器
    [self editTableViewControllerDidFinshedEdit];
}

#pragma mark - MREditTableViewControllerDelegate
- (void)editTableViewControllerDidFinshedEdit
{
    // 取出当前用户的电子名片
    XMPPvCardTemp *myvCard = [MRXMPPTool sharedMRXMPPTool].vCard.myvCardTemp;
    
    myvCard.photo = UIImagePNGRepresentation(self.iconView.image);
    
    myvCard.nickname = self.nikNameLabel.text;
    
    myvCard.orgName = self.orgLabel.text;
    
    if (self.departLabel.text.length > 0) {
        myvCard.orgUnits = @[self.departLabel.text];
    }
    
    myvCard.title = self.positionLabel.text;
    
    myvCard.note = self.phoneLabel.text;
    
    myvCard.mailer = self.emailLabel.text;
    
    // 更新电子名片 这个方法内部会实现数据上传到服务，无需程序自己操作
    [[MRXMPPTool sharedMRXMPPTool].vCard updateMyvCardTemp:myvCard];
    
}


@end
