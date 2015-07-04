//
//  MRUserInfo.m
//  WeChat
//
//  Created by 李白 on 15-7-5.
//  Copyright (c) 2015年 李白. All rights reserved.
//

#import "MRUserInfo.h"

#define ACCOUNTKEY @"account"
#define PWDKEY @"pwd"
#define LOGINSTATUSKEY @"loginStatus"

@implementation MRUserInfo

singleton_implementation(MRUserInfo)

- (void)saveToSanbox
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.account forKey:ACCOUNTKEY];
    [defaults setObject:self.pwd forKey:PWDKEY];
    [defaults setBool:self.loginStatus forKey:LOGINSTATUSKEY];
}

- (void)loadFromSanbox
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.account = [defaults objectForKey:ACCOUNTKEY];
    self.pwd = [defaults objectForKey:PWDKEY];
    self.loginStatus = [defaults boolForKey:LOGINSTATUSKEY];
}

@end
