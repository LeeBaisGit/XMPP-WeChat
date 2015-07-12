//
//  MRInputView.h
//  WeChat
//
//  Created by 李白 on 15-7-11.
//  Copyright (c) 2015年 李白. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MRInputView : UIView

/**
 *  通过nib创建inputView
 *
 *  @return
 */
+ (instancetype)inputView;

/**
 *  inputView中得textView
 */
@property (weak, nonatomic) IBOutlet UITextView *textView;


@end
