//
//  FoundTableController.m
//  home
//
//  Created by Han.zh on 2017/3/1.
//  Copyright © 2017年 Han.zhihong. All rights reserved.
//

#import "FoundTableController.h"
#import "TestTabController.h"

@interface FoundTableController ()

@end

@implementation FoundTableController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    //设置标题
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [UIColor whiteColor],NSForegroundColorAttributeName,
                          [UIFont systemFontOfSize:17],NSFontAttributeName,
                          nil];
    self.navigationController.navigationBar.titleTextAttributes=dict;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(0==indexPath.section)
    {
        switch (indexPath.row) {
            case 0:
            {
                //扫一扫
                UIStoryboard *frm=NULL;
                frm = [UIStoryboard storyboardWithName:@"QRCode" bundle:nil];
                [self.navigationController pushViewController:frm.instantiateInitialViewController animated:YES];
            }
                break;
            case 1:
            {
                //网络助手
                UIStoryboard *frm=NULL;
                frm = [UIStoryboard storyboardWithName:@"NetHelper" bundle:nil];
                TestTabController*tt=(TestTabController*)[frm instantiateViewControllerWithIdentifier:@"TestTabController"];
                [self.navigationController pushViewController:tt animated:YES];
            }
                break;
            case 2:
            {
                //samrtconfig一键配置
                UIStoryboard *frm=NULL;
                frm = [UIStoryboard storyboardWithName:@"EspTouch" bundle:nil];
                UIViewController*tt=(UIViewController*)frm.instantiateInitialViewController;
                [self.navigationController pushViewController:tt animated:YES];
            }
        }
    }
    else if(1==indexPath.section)
    {
        switch (indexPath.row) {
            case 0:
            {
                //商店
                UIStoryboard *frm=NULL;
                frm = [UIStoryboard storyboardWithName:@"Store" bundle:nil];
                [self.navigationController pushViewController:[frm instantiateViewControllerWithIdentifier:@"Store"] animated:YES];
            }
                break;
        }
    }
}

@end
