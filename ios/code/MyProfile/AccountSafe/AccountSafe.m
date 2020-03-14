//
//  AccountSafe.m
//  home
//
//  Created by Han.zh on 2017/7/15.
//  Copyright © 2017年 Han.zhihong. All rights reserved.
//

#import "AccountSafe.h"
#import "LoginInfo.h"

@interface AccountSafe ()
{
    __weak IBOutlet UILabel *txtUserid;
    __weak IBOutlet UILabel *txtCreatetime;
    __weak IBOutlet UILabel *txtEmail;
    __weak IBOutlet UILabel *txtPhone;
}

-(void)setInfo;

@end

@implementation AccountSafe

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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setInfo];
}

-(void)setInfo
{
    NSString* userid;
    NSString* createtime;
    NSString* nickname;
    NSString* email;
    NSString* phone;
    NSString* szUserid;
    
    userid=[LoginInfo get:@"userid"];
    szUserid=[LoginInfo get:@"szUserid"];
    createtime=[LoginInfo get:@"createtime"];
    nickname=[LoginInfo get:@"nickname"];
    email=[LoginInfo get:@"email"];
    phone=[LoginInfo get:@"phone"];
    
    [txtUserid setText:userid];
    [txtCreatetime setText:createtime];
    [txtEmail setText:email];
    [txtPhone setText:phone];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0://///////////////////////////////////////////
        {
            switch (indexPath.row) {
                case 2://#########
                {
                        [self performSegueWithIdentifier:@"segModifyPhone" sender:nil];
                }
                    break;
            }
        }
            break;
        case 1://///////////////////////////////////////////
        {
            [self performSegueWithIdentifier:@"segModifyPasswd" sender:nil];            
        }
            break;
    }
}


@end
