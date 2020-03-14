//
//  MySettingTable.m
//  home
//
//  Created by Han.zh on 2017/7/15.
//  Copyright © 2017年 Han.zhihong. All rights reserved.
//

#import "MySettingTable.h"
#import "WebBrower.h"
#import "DefineHeader.h"
#import "LoginInfo.h"
#import "GlobalParameter.h"

@interface MySettingTable ()
@end

@implementation MySettingTable

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0://///////////////////////////////////////////
        {
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"AccountSafe" bundle:nil];
            UIViewController *frm=[sb instantiateViewControllerWithIdentifier:@"AccountSafe"];
            [self.navigationController pushViewController:frm animated:YES];
            
        }
            break;
        case 1://///////////////////////////////////////////
        {
//            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MyProfile" bundle:nil];
//            UIViewController *frm=[sb instantiateViewControllerWithIdentifier:@"AboutTable"];
//            [self.navigationController pushViewController:frm animated:YES];
            
        }
            break;
        case 2://///////////////////////////////////////////
        {
            NSString* tmpstr=[NSString stringWithFormat:FEEDBACK_URL@"?platefrom=ios-app&nickname=%@&userid=%@",
                              [[LoginInfo get:@"nickname"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                              [[LoginInfo get:@"userid"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MyProfile" bundle:nil];
            WebBrower *frm=(WebBrower *)[sb instantiateViewControllerWithIdentifier:@"HTML5"];
            frm.main_url=tmpstr;
            [self.navigationController pushViewController:frm animated:YES];

        }
            break;
        case 3:// 退出
        {
            //退出登录
            [GlobalParameter clearLoginCfg];
            [LoginInfo clear];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
            break;
    }
}


@end
