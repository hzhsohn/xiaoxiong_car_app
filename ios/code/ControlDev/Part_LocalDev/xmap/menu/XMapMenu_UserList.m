//
//  XMapMenu_UserList.m
//  code
//
//  Created by Be-Service on 2019/12/20.
//  Copyright © 2019 Han.zhihong. All rights reserved.
//

#import "XMapMenu_UserList.h"
#import <libxmap/libxmap.h>
#import "JSONKit.h"
#import "McuGlobalParameter.h"
#import "XMapWallElement.h"
#import "XMBaseStatus.h"
#import "Part_XMap_Cell_UserList.h"
extern McuGlobalParameter *mcuParameter;

@interface XMapUserListItem : NSObject

    @property (nonatomic,copy) NSString*  desc;
    @property (nonatomic,copy) NSString*  name;

@end
@implementation XMapUserListItem
@end

@interface XMapMenu_UserList ()<XMapDTRSListener>
{
    XMapDTRS* xmap;
    NSMutableArray* projNodeData;
}
@end

@implementation XMapMenu_UserList

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"用户列表";
    
    xmap=(XMapDTRS*)[mcuParameter getParameter:@"+xmap"];
    [xmap.delegateList addObject:self];
    //
    projNodeData=[[NSMutableArray alloc] init];
    //
    //返回键
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"back", nil) style:UIBarButtonItemStyleDone target:self action:@selector(onBackButtonClicked:)]];
    self.navigationItem.hidesBackButton = YES;
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    
    //获取工程信息
    [xmap sendPack:[XMapCommand getUserList]];
    
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
    return [projNodeData count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Part_XMap_Cell_UserList *cell = [Part_XMap_Cell_UserList loadTableCell:tableView];
    XMapUserListItem* itm=[projNodeData objectAtIndex:indexPath.row];
    
    cell.name.text = [NSString stringWithFormat:@"用户名：%@",itm.name];
    cell.desc.text = itm.desc;
     
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


//--------------------------------------------------------
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
               
               if([jcmd isEqualToString:@"user_list_rb"])
               {
                   NSDictionary* its = [result objectForKey:@"its"];
                   int count = [[its objectForKey:@"cnt"] intValue];
                   if(count>0)
                   {
                       [xmap sendPack:[XMapCommand getUserListCxt :0]];
                   }
                   
//                   [projNodeData removeAllObjects];
                   NSLog(@"元素数量: %d", count);
               }
               else if([jcmd isEqualToString:@"user_list_c_rb"])
               {
                   NSDictionary* its = [result objectForKey:@"its"];
                   XMapUserListItem* user = [[XMapUserListItem alloc] init];
                   int index = [[its objectForKey:@"index"] intValue];
                   if(-1==index)
                   {
                       [self.tableView reloadData];
                   }
                   else {
                       user.desc =[its objectForKey:@"desc"];
                       user.name =[its objectForKey:@"user"];
                       [projNodeData addObject:user];
                       [self.tableView reloadData];
                       //继续获取数据
                       [xmap sendPack:[XMapCommand getUserListCxt :index+1]];
                       
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
