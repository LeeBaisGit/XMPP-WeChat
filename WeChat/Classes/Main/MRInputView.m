//
//  MRInputView.m
//  WeChat
//
//  Created by 李白 on 15-7-11.
//  Copyright (c) 2015年 李白. All rights reserved.
//

#import "MRInputView.h"

@implementation MRInputView

+ (instancetype)inputView
{
    return [[[NSBundle mainBundle] loadNibNamed:@"MRInputView" owner:nil options:nil] lastObject];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
