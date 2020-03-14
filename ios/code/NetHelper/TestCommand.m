//
//  TestCommand.m
//  hx-home
//
//  Created by Han.zh on 16/4/6.
//  Copyright © 2016年 Han.zhihong. All rights reserved.
//

#import "TestCommand.h"

@interface TestCommand ()
{
    __weak IBOutlet UITextView *txtCommandGen;
}
- (IBAction)btnSave:(id)sender;

@end

@implementation TestCommand

-(void)dealloc
{
    self.delegate=nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    txtCommandGen.text=self.sOldCommand;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnSave:(id)sender
{
    [self.delegate TestCommandCallBack:txtCommandGen.text];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
