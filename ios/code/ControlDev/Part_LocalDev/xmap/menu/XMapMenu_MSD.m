//
//  XMapMenu_MSD.m
//  code
//
//  Created by Be-Service on 2019/12/23.
//  Copyright © 2019 Han.zhihong. All rights reserved.
//

#import "XMapMenu_MSD.h"
#import <libxmap/libxmap.h>
#import "JSONKit.h"
#import "McuGlobalParameter.h"
#import "XMapWallElement.h"
#import "XMBaseStatus.h"
#import "Part_XMap_Cell_MSD.h"
extern McuGlobalParameter *mcuParameter;

@interface XMapMSDItem : NSObject

    @property (nonatomic,copy) NSString*  unique_id;
    @property (nonatomic,copy) NSString*  devname;
    @property (nonatomic,copy) NSString*  label;
    @property (nonatomic,copy) NSString*  desc;
    @property (nonatomic,copy) NSString*  descript;


@end
@implementation XMapMSDItem
@end

@interface CurMSDItem : NSObject

    @property (nonatomic,copy) NSDictionary*  dev_json;
    @property (nonatomic,copy) NSString*  dev_unique_id;
    @property (nonatomic,copy) NSString*  dev_devUUID;
    @property (nonatomic,copy) NSString*  dev_devflag;
    @property (nonatomic,copy) NSString*  dev_devname;
    @property (nonatomic,copy) NSString*  dev_label;
    @property (nonatomic,copy) NSString*  dev_descript;

@end
@implementation CurMSDItem
@end
@interface XMapMenu_MSD ()<XMapDTRSListener>
{
    XMapDTRS* xmap;
    NSMutableArray * projNodeData;
    NSMutableArray * online_dev;
    
}

@end

@implementation XMapMenu_MSD

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"MSD设备";
    
    xmap=(XMapDTRS*)[mcuParameter getParameter:@"+xmap"];
    [xmap.delegateList addObject:self];
    //
    projNodeData=[[NSMutableArray alloc] init];
    online_dev=[[NSMutableArray alloc] init];

    //返回键
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"back", nil) style:UIBarButtonItemStyleDone target:self action:@selector(onBackButtonClicked:)]];
    self.navigationItem.hidesBackButton = YES;
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    
    //获取工程信息
    [xmap sendPack:[XMapCommand getMSDDevice]];
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

    return projNodeData.count + online_dev.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Part_XMap_Cell_MSD *cell = [Part_XMap_Cell_MSD loadTableCell:tableView];
    if (online_dev.count > 0 && indexPath.row < online_dev.count){
        CurMSDItem * itm = [online_dev objectAtIndex:indexPath.row];
        cell.device_name.text = itm.dev_devname;
        cell.device_label.text = itm.dev_label;
        cell.device.text = itm.dev_descript;
        cell.image_selected.image = [UIImage imageNamed:@"devlst_cell_select0"];
    }else if (projNodeData.count > 0 && indexPath.row < projNodeData.count + online_dev.count){
        {
            XMapMSDItem* itm=[projNodeData objectAtIndex:indexPath.row - online_dev.count];
            cell.device_name.text = itm.devname;
            cell.device_label.text = itm.label;
            cell.device.text = itm.descript;
            cell.image_selected.image = [UIImage imageNamed:@"devlst_cell_select1"];
        }
    }
    
    return cell;
}

-(CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
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
               
               if([jcmd isEqualToString:@"dev_label_rb"])
               {
                   NSDictionary* its = [result objectForKey:@"its"];
                   int count = [[its objectForKey:@"cnt"] intValue];
                   if(count>0)
                   {
                       [xmap sendPack:[XMapCommand getMSDDeviceCxt :0]];
                   }
                   
//                   [projNodeData removeAllObjects];
                   NSLog(@"元素数量: %d", count);
               }
               else if([jcmd isEqualToString:@"dev_label_c_rb"])
               {
                   NSDictionary* its = [result objectForKey:@"its"];
                   XMapMSDItem* msd = [[XMapMSDItem alloc] init];
                   int index = [[its objectForKey:@"index"] intValue];
                   if(-1==index)
                   {
                       [self.tableView reloadData];
                   }
                   else {
                       msd.unique_id =[its objectForKey:@"unique_id"];
                       msd.label =[its objectForKey:@"label"];
                       msd.devname =[its objectForKey:@"devname"];
                       msd.desc =[its objectForKey:@"desc"];
                       
                       
                       [projNodeData addObject:msd];
                       [self.tableView reloadData];
                       //继续获取数据
                       [xmap sendPack:[XMapCommand getUserListCxt :index+1]];
                       
                   }
               }else if ([jcmd isEqualToString:@"dev_label_del_rb"]){
                   NSDictionary* its = [result objectForKey:@"its"];
                   if ([its[@"ret"] boolValue]){
                       NSString *unique_id = its[@"unique_id"];
                        
                       for (XMapMSDItem* msd in projNodeData) {
                           if (![msd.unique_id isEqual: [NSNull null]] && [msd.unique_id isEqual:unique_id]){
                               [projNodeData removeObject:msd];
                           }
                       }
                        [self.tableView reloadData];
                       
                   }
               }else if([jcmd isEqualToString:@"dev_label_modify_rb"]){
                   NSDictionary* its = [result objectForKey:@"its"];
                   if ([its[@"ret"] boolValue]){
                       NSString *unique_id = its[@"unique_id"];
                       NSString *devname = its[@"devname"];
                       NSString *label = its[@"label"];
                       NSString *desc = its[@"desc"];
                       for (XMapMSDItem* msd in projNodeData) {
                           if (![msd.unique_id isEqual: [NSNull null]] && [msd.unique_id isEqual:unique_id]){
                               msd.devname = devname;
                               msd.label = label;
                               msd.desc = desc;
                           }
                       }
                        [self.tableView reloadData];
                       
                   }
               }else if ([jcmd isEqualToString:@"online_msd_rb"]){
                   
//                   NSDictionary* its = [result objectForKey:@"its"];
//                   int count = [[its objectForKey:@"cnt"] intValue];
                   [projNodeData removeAllObjects];
               }else if([jcmd isEqualToString:@"online_msd_c_rb"]){
                   NSDictionary* its = [result objectForKey:@"its"];
                   CurMSDItem * pn = [[CurMSDItem alloc]init];
                   int index = [[its objectForKey:@"index"] intValue];
                   if(-1==index)
                   {
                       [self.tableView reloadData];
                   }
                   else {
                       pn.dev_devUUID = its[@"uuid"];
                       pn.dev_json = its[@"info"];
                       if (![pn.dev_devUUID isEqual:@""]){
                           NSDictionary * newIts = pn.dev_json;
                           pn.dev_devflag = newIts[@"f"];
                           pn.dev_devname = newIts[@"n"];
                           pn.dev_descript = newIts[@"d"];
                           pn.dev_label = newIts[@"l"];
                           [online_dev addObject:pn];
                           [self.tableView reloadData];
                       }
                   }
               }else if([jcmd isEqualToString:@"online_msd_income_rb"]){
                   NSDictionary* its = [result objectForKey:@"its"];
                   CurMSDItem * pn = [[CurMSDItem alloc]init];
                   pn.dev_devUUID = its[@"uuid"];
                   pn.dev_json = its[@"info"];
                   if (![pn.dev_devUUID isEqual:@""] ){
                       NSDictionary * newIts = pn.dev_json;
                       pn.dev_devflag = newIts[@"f"];
                       pn.dev_devname = newIts[@"n"];
                       pn.dev_descript = newIts[@"d"];
                       pn.dev_label = newIts[@"l"];
                       BOOL b = false;
                       BOOL b2 = false;
                       for (CurMSDItem * ppp in online_dev) {
                           if ([ppp.dev_devname isEqual:pn.dev_devname]){
                               b = true;
                               break;
                           }
                       }
                       if(false == b){
                           [online_dev addObject:pn];
                       }
                       for (XMapMSDItem * ppp in projNodeData) {
                           if ([ppp.devname isEqual:pn.dev_devname]){
                               b2 = true;
                               break;
                           }
                       }
                       if (false == b2){
                           XMapMSDItem * msd = [[XMapMSDItem alloc]init];
                           msd.devname = pn.dev_devname;
                           msd.label = pn.dev_label;
                           msd.descript = pn.dev_descript;
                           [projNodeData addObject:msd];
                       }
                   }
                   [self.tableView reloadData];
                   
               }else if([jcmd isEqualToString:@"online_msd_leave_rb"]){
                    NSDictionary* its = [result objectForKey:@"its"];
                   NSString * dev_devUUID = its[@"uuid"];
                   for (CurMSDItem* pn in projNodeData) {
                       if (![pn.dev_devUUID isEqual: [NSNull null]] && [pn.dev_devUUID isEqual:dev_devUUID]){
                           [projNodeData removeObject:pn];
                       }
                   }
                    [self.tableView reloadData];
                   
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


- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}
@end
