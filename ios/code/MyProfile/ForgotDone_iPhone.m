//
//  ForgotDone_iPhone.m
//  smart
//
//  Created by Han.zh on 14-8-21.
//  Copyright (c) 2014年 Han.zhihong. All rights reserved.
//

#import "ForgotDone_iPhone.h"

@interface ForgotDone_iPhone ()

- (IBAction)btnDone_click:(id)sender;

@end

@implementation ForgotDone_iPhone

- (void)awakeFromNib{
    [super awakeFromNib];
}

- (void)dealloc {
    //[super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationItem setHidesBackButton:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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

- (IBAction)btnDone_click:(id)sender
{
    UIViewController*frm=[self.navigationController.viewControllers objectAtIndex:1] ;
    [self.navigationController popToViewController:frm animated:YES];
}
@end
