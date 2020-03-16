//
//  SignUpDone_iPhone.m
//  smart
//
//  Created by Han.zh on 14-8-21.
//  Copyright (c) 2014年 Han.zhihong. All rights reserved.
//

#import "SignUpDone_iPhone.h"
#import "JSONKit.h"
#import "WebProc.h"
#import "GlobalParameter.h"

@interface SignUpDone_iPhone ()

- (IBAction)btnBack_click:(id)sender;

@end

@implementation SignUpDone_iPhone

-(void)awakeFromNib
{
    [super awakeFromNib];
}

-(void)dealloc
{
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationItem setHidesBackButton:YES];
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

- (IBAction)btnBack_click:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}


@end
