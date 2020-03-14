//
//  AboutTable.m
//  code
//
//  Created by Be-Service on 2018/8/1.
//  Copyright © 2018年 Han.zhihong. All rights reserved.
//

#import "AboutTable.h"
#import "WebBrower.h"
#import "JSONKit.h"
#import "MBProgressHUD.h"
#import "HelpHeader.h"
@interface AboutTable ()<UITableViewDelegate,UITableViewDataSource>
{
    WebProc* _web;
}
@end

@implementation AboutTable
{
    
    __weak IBOutlet UITableView *tbView;
    UIView * headerView;
    UIImageView * headerImg;
    UILabel * headerLabel;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    _web=[[WebProc alloc] init];
    _web.delegate=self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"about", nil);
    [self configHeaderView];
    
    tbView.backgroundColor = [UIColor clearColor];
    tbView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    tbView.tableHeaderView = headerView;
}

- (void)configHeaderView
{
    headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 200)];
    headerView.backgroundColor = [UIColor colorWithRed:88/255.0 green:188/255.0 blue:247/255.0 alpha:1];
    headerImg = [[UIImageView alloc]initWithFrame:CGRectMake((CGRectGetWidth(headerView.frame)-80)/2, (CGRectGetHeight(headerView.frame)-80)/2, 80, 80)];
    headerImg.layer.masksToBounds = true;
    headerImg.layer.cornerRadius = 40;
    headerImg.image = [UIImage imageNamed:@"AppIcon"];
    headerLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(headerView.frame)-40, CGRectGetWidth(self.view.frame), 20)];
    headerLabel.font = [UIFont boldSystemFontOfSize:16];
    headerLabel.textAlignment = 1;
    headerLabel.textColor = [UIColor whiteColor];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    CFShow((__bridge CFTypeRef)(infoDictionary));
    headerLabel.text = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"version",nil),[infoDictionary objectForKey:@"CFBundleShortVersionString"]];
    
//    [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    [headerView addSubview:headerImg];
    [headerView addSubview:headerLabel];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString *cellidentifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellidentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellidentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (indexPath.section == 0){
        cell.textLabel.text = NSLocalizedString(@"Function is introduced", nil);
    }else{
        cell.textLabel.text = NSLocalizedString(@"Detect new version", nil);
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}

//设行高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            NSString* tmpstr=@"http://home.hx-kong.com/about_software";
            
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MyProfile" bundle:nil];
            WebBrower *frm=(WebBrower *)[sb instantiateViewControllerWithIdentifier:@"HTML5"];
            frm.main_url=tmpstr;
            [self.navigationController pushViewController:frm animated:YES];
            
        }
            break;
        case 1:
        {
            [self newVersion];
        }
            break;
    }
}

-(void)newVersion{
    [_web sendData:@"http://home.hx-kong.com/ios_iphone_ver.txt" parameter:nil];
}

//////////////////////////////////
//网络回调
-(void) WebProcCallBackBegin:(NSURL*)url
{
//    [ind setAlpha:1];
//    [ind setHidden:NO];
//    [ind startAnimating];
}
-(void) WebProcCallBackCookies:(NSURL*)url :(NSString*)cookie
{
    
}
-(void) WebProcCallBackData:(NSURL*)url :(NSData*)data
{
    [MBProgressHUD showHUDAddedTo:self.view animated:true];
    
    NSLog(@"url=%@",[url relativeString]);
    NSString *page=[url lastPathComponent];
    NSLog(@"page=%@",page);
    
    NSData *safeJsonData = [_web getSafeJsonData:data];
    
    if (0==[safeJsonData length]) {
        [MBProgressHUD hideHUDForView:self.view animated:true];
        return;
    }
    
    if([page isEqualToString:@"ios_iphone_ver.txt"])
    {
        //解释data
        NSDictionary *result = [safeJsonData objectFromJSONData];
        if(nil!=result)
        {
            [MBProgressHUD hideHUDForView:self.view animated:true];
            if ([headerLabel.text containsString:result[@"ver"]]){
                alert_err(NSLocalizedString(@"alert",nil), NSLocalizedString(@"New",nil));
            }else{
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:result[@"url"]]];
            }
        }
    }
}
-(void) WebProcCallBackFail:(NSURL*)url
{
   
}

@end
