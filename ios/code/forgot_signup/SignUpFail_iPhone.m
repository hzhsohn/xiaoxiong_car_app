//
//  SignUpFail_iPhone.m
//  smart
//
//  Created by Han.zh on 14-8-21.
//  Copyright (c) 2014年 Han.zhihong. All rights reserved.
//

#import "SignUpFail_iPhone.h"

@interface SignUpFail_iPhone ()

@end

@implementation SignUpFail_iPhone

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    _lbReason=nil;
    //[_lbReason release];
    //[super dealloc];
}


-(void) setReason:(NSString*)str
{
    [_lbReason setText:str];
}

@end