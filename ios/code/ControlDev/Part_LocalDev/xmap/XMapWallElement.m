//
//  XMapWallListTableViewController.m
//  code
//
//  Created by Han.zh on 2019/12/15.
//  Copyright © 2019 Han.zhihong. All rights reserved.
//

#import "XMapWallElement.h"
#import <libxmap/libxmap.h>
#import "JSONKit.h"
#import "McuGlobalParameter.h"
#import "Part_XMap_Cell_WallEle.h"
#import "XMBaseStatus.h"

//网络控制
extern McuGlobalParameter *mcuParameter;


@interface XMapWallElementItem : NSObject

    @property (nonatomic,copy) NSString*  nodeType;
    @property (nonatomic,copy) NSString*  name;
    @property (nonatomic,copy) NSString*  txt;
    @property (nonatomic,copy) NSString*  title;

@end
@implementation XMapWallElementItem
@end


@interface XMapWallElement ()<XMapDTRSListener>
{
    XMapDTRS* xmap;
    NSMutableArray* eleNodeData;
}

@end

@implementation XMapWallElement

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    //
    xmap=(XMapDTRS*)[mcuParameter getParameter:@"+xmap"];
    [xmap.delegateList addObject:self];
    //
    eleNodeData=[[NSMutableArray alloc] init];
    //
    //获取WALL元素
    [xmap sendPack:[XMapCommand getWallElement :self.wall_filename]];
}

//--------------------------------------------------------
//检测是否返回
- (void)didMoveToParentViewController:(UIViewController*)parent{
    [super didMoveToParentViewController:parent];
    if(!parent){
        NSLog(@"XMapWallElement 页面pop成功了");
        [xmap.delegateList removeObject:self];
        [eleNodeData removeAllObjects];
    }
}

-(void)dealloc
{
    NSLog(@"XMapWallElement dealloc");
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [eleNodeData count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Part_XMap_Cell_WallEle *cell = [Part_XMap_Cell_WallEle loadTableCell:tableView];
    XMapWallElementItem* itm=[eleNodeData objectAtIndex:indexPath.row];
    
    cell.txt1.text=itm.title;
    cell.txt2.text=itm.txt;
    if([itm.nodeType isEqualToString:@"box"])
    {
        cell.img1.image=[UIImage imageNamed:@"xtsys_box"];
    }
    else if([itm.nodeType isEqualToString:@"lbus"])
    {
        cell.img1.image=[UIImage imageNamed:@"xtsys_lbus"];
    }
    else if([itm.nodeType isEqualToString:@"msd_if"])
    {
        cell.img1.image=[UIImage imageNamed:@"xtsys_msd_if"];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XMapWallElementItem* itm=[eleNodeData objectAtIndex:indexPath.row];
    
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

//-------------------------------------------------
//
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
            
            if([jcmd isEqualToString:@"wall_element_rb"])
            {
                NSDictionary* its = [result objectForKey:@"its"];
                int count = [[its objectForKey:@"cnt"] intValue];
                if(count>0)
                {
                    [xmap sendPack:[XMapCommand getWallElementCxt :self.wall_filename :0]];
                }
                
                [eleNodeData removeAllObjects];
                NSLog(@"元素数量: %d", count);
            }
            else if([jcmd isEqualToString:@"wall_element_c_rb"])
            {
                NSDictionary* its = [result objectForKey:@"its"];
                XMapWallElementItem* pn = [[XMapWallElementItem alloc] init];
                int index = [[its objectForKey:@"index"] intValue];
                if(-1==index)
                {
                    [self.tableView reloadData];
                }
                else {
                    pn.nodeType =[its objectForKey:@"type"];
                    pn.name =[its objectForKey:@"name"];
                    pn.title = [its objectForKey:@"title"];
                    pn.txt = [its objectForKey:@"txt"];
                    [eleNodeData addObject:pn];
                    [self.tableView reloadData];
                    //继续获取数据
                    [xmap sendPack:[XMapCommand getWallElementCxt :self.wall_filename :index+1]];
                }

            }
            else if([jcmd isEqualToString:@"box_rb"])
            {
                
                NSDictionary* its = [result objectForKey:@"its"];
                NSString* wf=[its objectForKey:@"file"];
                NSString* na = [its objectForKey:@"name"];
                BOOL ret = [[its objectForKey:@"name"] boolValue];
                if([wf isEqualToString:self.wall_filename]) {
                    for(XMapWallElementItem* st in eleNodeData)
                    {
                        if ([st.name isEqualToString:na] && [st.nodeType isEqualToString:@"box"]) {
                            if(ret) {
                                xmapShowAlert(self, [NSString stringWithFormat:@"%@ 控制成功",st.title]);
                            }
                            else
                            {
                                xmapShowAlert(self, [NSString stringWithFormat:@"%@ 控制失败",st.title]);
                            }
                        }
                    }
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
