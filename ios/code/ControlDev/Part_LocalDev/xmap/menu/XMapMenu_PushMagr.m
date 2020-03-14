//
//  XMapMenu_PushMagr.m
//  code
//
//  Created by Be-Service on 2019/12/24.
//  Copyright © 2019 Han.zhihong. All rights reserved.
//

#import "XMapMenu_PushMagr.h"
#import <libxmap/libxmap.h>
#import "JSONKit.h"
#import "McuGlobalParameter.h"
#import "XMapWallElement.h"
#import "XMBaseStatus.h"
#import "Part_XMap_Cell_UserList.h"
extern McuGlobalParameter *mcuParameter;

@interface XTSYSPushGroupItem : NSObject

    @property (nonatomic,copy) NSString*  pushType;
    @property (nonatomic,copy) NSString*  aliasName;


@end
@implementation XTSYSPushGroupItem
@end

@interface XMapMenu_PushMagr ()<XMapDTRSListener>
{
    XMapDTRS* xmap;
    NSMutableArray * projNodeData;
}

@end

@implementation XMapMenu_PushMagr

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"MSD设备";
    
    xmap=(XMapDTRS*)[mcuParameter getParameter:@"+xmap"];
    [xmap.delegateList addObject:self];
    //
    projNodeData=[[NSMutableArray alloc] init];

    //返回键
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"back", nil) style:UIBarButtonItemStyleDone target:self action:@selector(onBackButtonClicked:)]];
    self.navigationItem.hidesBackButton = YES;
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    
    //获取工程信息
    [xmap sendPack:[XMapCommand getPushGroup]];
    
}

- (void)onBackButtonClicked:(id)sender{
    //返回主界面
       [self.navigationController popViewControllerAnimated:true];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return projNodeData.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Part_XMap_Cell_UserList *cell = [Part_XMap_Cell_UserList loadTableCell:tableView];
    XTSYSPushGroupItem* itm=[projNodeData objectAtIndex:indexPath.row];
    
    cell.name.text = itm.aliasName;
    cell.desc.text = itm.pushType;
    
    return cell;
}



//检测是否返回
- (void)didMoveToParentViewController:(UIViewController*)parent{
    [super didMoveToParentViewController:parent];
    if(!parent){
        NSLog(@"XMapWallList 页面pop成功了");
        [xmap.delegateList removeObject:self];
        [projNodeData removeAllObjects];
    }
}

// XMapDTRS 的回调
//
-(void) XMapDTRS_devuuid_subscr_success
{
    
}
-(void) XMapDTRS_sign_success
{
    
}

-(void) XMapDTRS_new_data:(char*) data :(int)len
{
    short cmd=0;
    memcpy(&cmd,data,2);
    NSLog(@"XMapWallList new_data len=%d , cmd=%d",len,cmd);
    
    switch (cmd) {
           case ecpuSToCJsonCommand:
           {
               NSString* pjsonData=[NSString stringWithUTF8String:&data[2]];

               NSData*jsonData=[NSData dataWithData:[pjsonData dataUsingEncoding: NSUTF8StringEncoding]];
               NSDictionary *result = [jsonData objectFromJSONData];
               NSString*jcmd=[result objectForKey:@"cmd"];
               
               if([jcmd isEqualToString:@"push_group_rb"])
               {
                   NSDictionary* its = [result objectForKey:@"its"];
                   int count = [[its objectForKey:@"cnt"] intValue];
                   if(count>0)
                   {
                       [xmap sendPack:[XMapCommand getPushGroupCxt :0]];
                   }
                   
//                   [projNodeData removeAllObjects];
                   NSLog(@"元素数量: %d", count);
               }
               else if([jcmd isEqualToString:@"push_group_c_rb"])
               {
                   NSDictionary* its = [result objectForKey:@"its"];
                   XTSYSPushGroupItem* pn = [[XTSYSPushGroupItem alloc] init];
                   int index = [[its objectForKey:@"index"] intValue];
                   if(-1==index)
                   {
                       [self.tableView reloadData];
                   }
                   else {
                       pn.pushType =[its objectForKey:@"type"];
                       pn.aliasName =[its objectForKey:@"aname"];
                       [projNodeData addObject:pn];
                       [self.tableView reloadData];
                       //继续获取数据
                       [xmap sendPack:[XMapCommand getUserListCxt :index+1]];
                       
                   }
               }else if ([jcmd isEqualToString:@"push_group_add_rb"]){
                       
                   
               }else if([jcmd isEqualToString:@"push_group_del_rb"]){
                   NSDictionary* its = [result objectForKey:@"its"];
                   BOOL ret = its[@"ret"];
                   NSString * pushType = its[@"type"];
                   if (ret){
                       for (XTSYSPushGroupItem * pn in projNodeData) {
                           if (![pn.pushType isEqual: [NSNull null]] && [pn.pushType isEqual:pushType]){
                               [projNodeData removeObject:pn];
                           }
                       }
                        [self.tableView reloadData];
                   }
                }
           }
           break;
       }
}

//通讯异常
-(void) XMapDTRS_abnormal_communication:(int)errid :(NSString*) msg
{
}
-(void) XMapDTRS_disconnect
{
}



@end
