//
//  TestTabController.m
//  hx-home
//
//  Created by Han.zh on 16/4/6.
//  Copyright © 2016年 Han.zhihong. All rights reserved.
//

#import "TestTabController.h"
#import "UDPTest.h"
#import "TCPTest.h"
#import  <libHxkNet/McuNet.h>

extern MSDSearchDev *msdSearchDev;

@interface TestTabController ()
{
    UDPTest* frm0;
    TCPTest* frm1;
}
- (IBAction)btnBack_click:(id)sender;
@end

@implementation TestTabController

-(void)dealloc
{
    NSLog(@"TestTabController dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [(UITabBarItem *)[self.tabBar.items objectAtIndex:0] setTitle:NSLocalizedString(@"UDP Test", nil)];
    [(UITabBarItem *)[self.tabBar.items objectAtIndex:0] setImage:[UIImage imageNamed:@"testview_icon0"]];
    [(UITabBarItem *)[self.tabBar.items objectAtIndex:0] setTag:0];
    [(UITabBarItem *)[self.tabBar.items objectAtIndex:1] setTitle:NSLocalizedString(@"TCP Test", nil)];
    [(UITabBarItem *)[self.tabBar.items objectAtIndex:1] setImage:[UIImage imageNamed:@"testview_icon1"]];
    [(UITabBarItem *)[self.tabBar.items objectAtIndex:1] setTag:1];
    
    //
    frm0=[self.childViewControllers objectAtIndex:0];
    frm0.def_ip=self.host;
    frm0.def_port=self.port;
    
    frm1=[self.childViewControllers objectAtIndex:1];
    frm1.def_ip=self.host;
    frm1.def_port=1234; //TCP默认连接端口是1234
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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.title=self.devName;
    [msdSearchDev stopService];
    //
    self.title=NSLocalizedString(@"UDP Test", nil);
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [msdSearchDev startService];
}

- (IBAction)btnClearMsg:(id)sender
{
    switch (self.selectedIndex)
    {
        case 0:
        {
            UDPTest*frm=self.selectedViewController;
            [frm clearMessage];
        }
            break;
            
        case 1:
        {
            TCPTest*frm=self.selectedViewController;
            [frm clearMessage];
        }
            break;
    }
}

- (IBAction)btnBack_click:(id)sender
{
    [frm0 closeService];
    [frm1 closeService];
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    switch (item.tag)
    {
        case 0:
            self.title=NSLocalizedString(@"UDP Test", nil);
            break;
        case 1:
            self.title=NSLocalizedString(@"TCP Test", nil);
            break;
    }
}

@end
