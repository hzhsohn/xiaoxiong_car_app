//
//  WebSetConfig.m
//  home
//
//  Created by Han.zh on 2017/1/11.
//  Copyright © 2017年 Han.zhihong. All rights reserved.
//

#import "WebSetConfig.h"
#import "Reachability.h"

@interface WebSetConfig ()
{
    Reachability* rbty;
}

@property (strong, nonatomic) IBOutlet UIButton *startBtn;

- (IBAction)btnGo_click:(id)sender;

@end

@implementation WebSetConfig

-(void) dealloc
{
    rbty=nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //设置圆角
    _startBtn.layer.masksToBounds = true;
    _startBtn.layer.cornerRadius = 5;

    //netStatus值,启用蜂窝网络时值为2,启用WIFI为1,什么网络都没有为0
    rbty = [Reachability reachabilityForInternetConnection];
    [rbty startNotifier];
    [self networkConfigure:rbty :1];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChanged:) name: kReachabilityChangedNotification object: nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnGo_click:(id)sender {
    NSString* url = [NSString stringWithFormat:@"http://192.168.1.10"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    /*
    UIStoryboard *frm=NULL;
    frm = [UIStoryboard storyboardWithName:@"APConfig" bundle:nil];
    UIViewController*tt=(UIViewController*)[frm instantiateViewControllerWithIdentifier:@"APConfig_CheckDev"];
    [self.navigationController pushViewController:tt animated:YES];*/
}

//当前网络状态改变后
//Called by Reachability whenever status changes.
- (void) reachabilityChanged: (NSNotification* )note
{
    Reachability* curReach = [note object];
    [self networkConfigure:curReach :2];
}


- (void) networkConfigure :(Reachability*) curReach :(int)income
{
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    BOOL connectionRequired= [curReach connectionRequired];
    //NSLog(@"curReach=%p netStatus=%d income=%d",curReach,netStatus,income);
    
    switch (netStatus)
    {
        case NotReachable:
        {
            //网络不可用
            connectionRequired= NO;
            NSLog(@"网络不可用");
            break;
        }
        case ReachableViaWiFi:
        {
            //WIFI网络
            NSLog(@"使用WIFI网络");
            break;
        }
        case ReachableViaWWAN:
        {
            //Reachable WWAN蜂窝网络
            NSLog(@"WWAN蜂窝网络");
            break;
        }
    }
}


@end
