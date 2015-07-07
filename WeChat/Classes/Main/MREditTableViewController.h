//
//  MREditTableViewController.h
//  WeChat
//
//  Created by 李白 on 15-7-8.
//  Copyright (c) 2015年 李白. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MREditTableViewController;
@protocol MREditTableViewControllerDelegate <NSObject>

@optional
- (void)editTableViewControllerDidFinshedEdit;


@end


@interface MREditTableViewController : UITableViewController

@property(nonatomic,strong)UITableViewCell *cell;

@property(nonatomic,weak)id<MREditTableViewControllerDelegate> delegate;

@end
