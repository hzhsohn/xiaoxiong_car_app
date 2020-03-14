//
//  XMapWallListTableViewController.m
//  code
//
//  Created by Han.zh on 2019/12/15.
//  Copyright © 2019 Han.zhihong. All rights reserved.
//

#import "XMapWallList.h"
#import "XMapMenu_UserList.h"
#import "XMapMenu_PushMagr.h"
#import "XMapMenu_Password.h"
#import "XMapMenu_MSD.h"
#import <libxmap/libxmap.h>
#import "JSONKit.h"
#import "McuGlobalParameter.h"
#import "Part_XMap_Cell_WallList.h"
#import "XMapWallElement.h"
#import "XWSLeftView.h"
#import "XMBaseStatus.h"
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
//网络控制
extern McuGlobalParameter *mcuParameter;


@interface ProjectNodeItem : NSObject
    @property int showType;
    
    //------------------------
    @property (nonatomic,copy) NSString* wall_filename;
    @property (nonatomic,copy) NSString* wall_label;
    @property (nonatomic,copy) NSString* wall_description;

    //------------------------
    @property (nonatomic,assign) BOOL msd_depend;
    @property (nonatomic,copy) NSDictionary* dev_json_dict;
    @property (nonatomic,copy) NSString* dev_devUUID;
    @property (nonatomic,copy) NSString* dev_devflag;
    @property (nonatomic,copy) NSString* dev_devname;
    @property (nonatomic,copy) NSString* dev_label;
    @property (nonatomic,copy) NSString* dev_descript;

@end
@implementation ProjectNodeItem
@end


@interface XMapWallList ()<XMapDTRSListener,XWSLeftViewDelegate>
{
    XMapDTRS* xmap;
    NSMutableArray* projNodeData;
    XWSLeftView *leftView;
}

@end

@implementation XMapWallList

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    //
    xmap=(XMapDTRS*)[mcuParameter getParameter:@"+xmap"];
    [xmap.delegateList addObject:self];
    //
    projNodeData=[[NSMutableArray alloc] init];
    //
    //返回键
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"back", nil) style:UIBarButtonItemStyleDone target:self action:@selector(onBackButtonClicked:)]];
    self.navigationItem.hidesBackButton = YES;
    
    //获取工程信息
    [xmap sendPack:[XMapCommand getProjectInfo]];
    
    // 侧边栏view,在获取工程信息后设置
    //[self setUpLeftMenuView];
}

- (void)setUpLeftMenuView{
    //这里传 侧边栏 最上面的文字 和图片
    NSString *account = [NSString stringWithFormat:@"%@ - %@",
                 [NSString stringWithUTF8String:g_XMBaseStatus.ProjectInfo.title] ,
                 [NSString stringWithUTF8String:g_XMBaseStatus.ProjectInfo.version]];
    //@"这是标题,例如：家里";
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"account"] = account;
    //    dic[@"icon"] = @"left_setting";
    if (!leftView){
        leftView = [[XWSLeftView alloc] initWithFrame:CGRectZero withUserInfo:dic];
        [UIApplication sharedApplication].keyWindow.backgroundColor = [UIColor clearColor];
        [[UIApplication sharedApplication].keyWindow addSubview:leftView];
        leftView.delegate = self;
        leftView.hidden = YES;
        [leftView mas_makeConstraints:^(MASConstraintMaker *make) {
         make.bottom.top.mas_equalTo(0);
         make.left.mas_equalTo(ScreenWidth*2);
         make.width.mas_equalTo(ScreenWidth);
        }];
    }
}



//收回左侧侧边栏
- (void)hideLeftMenuView{
    [leftView cancelCoverViewOpacity];
    [UIView animateWithDuration:0.35 animations:^{
        [self->leftView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(ScreenWidth);
        }];
        
        [[UIApplication sharedApplication].keyWindow layoutIfNeeded];
        
    }completion:^(BOOL finished) {
        self->leftView.hidden = YES;
    }];
}

#pragma mark - XWSLeftViewDelegate
- (void)touchLeftView:(XWSLeftView *)leftView byType:(XWSTouchItem)type{
    
    [self hideLeftMenuView];
    
    UIViewController *vc = nil;
    switch (type) {
        case XWSTouchItemUserInfo:
        {
           
        }
            break;
        case XWSTouchItemViewUsers:
        {
             vc = [[XMapMenu_UserList alloc]init];
        }
            break;
        case XWSTouchItemPushManagement:
        {
            vc = [[XMapMenu_PushMagr alloc]init];
        }
            break;
        case XWSTouchItemMSD:
        {
            vc = [[XMapMenu_MSD alloc]init];
        }
            break;
        case XWSTouchItemChangePassword:
        {
            vc = [self.storyboard instantiateViewControllerWithIdentifier:@"XmapPassword"];
        }
            break;
        case XWSTouchItemSwitchingUsers:
        {
            
        }
            break;
            
        default:
            break;
    }
    
    if (vc == nil) {
        return;
    }
    [self.navigationController pushViewController:vc animated:YES];
}

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

-(void)dealloc
{
    NSLog(@"XMapWallList dealloc");
}

- (IBAction)onBackButtonClicked:(id)sender
{
    //返回主界面
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:([self.navigationController.viewControllers count] -3)] animated:YES];
}
    
- (IBAction)showLeftMenuView:(id)sender {
    leftView.hidden = NO;
    [UIView animateWithDuration:0.35 animations:^{
        [self->leftView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
    }];
    [[UIApplication sharedApplication].keyWindow layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
        //设置颜色渐变动画
    [leftView startCoverViewOpacityWithAlpha:0.5 withDuration:0.35];
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ProjectNodeItem*p=(ProjectNodeItem*) sender;
    NSLog(@"segue.identifier=%@",segue.identifier);
    if ([segue.identifier isEqualToString:@"segToWall"])
    {
        XMapWallElement* frm=(XMapWallElement*)segue.destinationViewController;
        frm.wall_filename=p.wall_filename;
    }
    else if ([segue.identifier isEqualToString:@"segToMSD_KG"])
    {
        XMapWallElement* frm=(XMapWallElement*)segue.destinationViewController;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [projNodeData count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Part_XMap_Cell_WallList *cell = [Part_XMap_Cell_WallList loadTableCell:tableView];
    ProjectNodeItem* itm=[projNodeData objectAtIndex:indexPath.row];
    
    if(1==itm.showType)
    {
        cell.img1.image=[UIImage imageNamed:@"xtsys_wall"];
        cell.txt1.text=itm.wall_label;
        cell.txt2.text=itm.wall_description;
        cell.txt3.text=@"";
    }
    else if(2==itm.showType)
    {
        if(itm.msd_depend)
        {
            cell.img1.image=[UIImage imageNamed:@"xtsys_msddev"];
        }
        else
        {
            cell.img1.image=[UIImage imageNamed:@"xtsys_msddev_no_depend"];
        }
        
        if([itm.dev_label isEqualToString:@""]) {
            cell.txt1.text = itm.dev_devname;
            cell.txt2.text = itm.dev_devflag;
        }
        else{
            cell.txt1.text = itm.dev_label;
            cell.txt2.text = [NSString stringWithFormat:@"%@ - %@",itm.dev_devname,itm.dev_devflag];
            cell.txt3.text = itm.dev_descript;
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProjectNodeItem* itm=[projNodeData objectAtIndex:indexPath.row];
    if(1==itm.showType)
    {
        [self performSegueWithIdentifier:@"segToWall" sender:itm];
    }
    else if(2==itm.showType)
    {
        if( [itm.dev_devflag isEqualToString:@"KG1"] ||
           [itm.dev_devflag isEqualToString:@"KG2"] ||
           [itm.dev_devflag isEqualToString:@"KG4"] ||
           [itm.dev_devflag isEqualToString:@"KG8"] ||
           [itm.dev_devflag isEqualToString:@"KG12"] ||
           [itm.dev_devflag isEqualToString:@"KG16"] ||
           [itm.dev_devflag isEqualToString:@"KG24"] )
        {
            [self performSegueWithIdentifier:@"segToMSD_KG" sender:itm];
        }
    }
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
            
            if([jcmd isEqualToString:@"permission_denied"])
            {
            }
            else if([jcmd isEqualToString:@"project_info_rb"])
            {
                NSDictionary* its = [result objectForKey:@"its"];
                BOOL ret = [[its objectForKey:@"ret"] boolValue];
                //
                g_XMBaseStatus.ProjectInfo.isProjectSuccess = (ret?true:false);
                if(false==ret)
                {
                    //项目未正常运行在中控里
                    xmapShowAlert(self,@"项目未正常运行在中控里");
                }
                else
                {
                    //项目其它基本信息
                    strcpy(g_XMBaseStatus.ProjectInfo.create_time,
                                [[its objectForKey:@"create_time"] UTF8String]);
                    strcpy(g_XMBaseStatus.ProjectInfo.version,
                                [[its objectForKey:@"ver"] UTF8String]);
                    strcpy(g_XMBaseStatus.ProjectInfo.title,
                                [[its objectForKey:@"title"] UTF8String]);
                    strcpy(g_XMBaseStatus.ProjectInfo.description,
                                [[its objectForKey:@"desc"] UTF8String]);
                    
                    // 侧边栏view,在获取工程信息后设置
                    [self setUpLeftMenuView];
                    
                    //请求工程WALL信息
                    [xmap sendPack:[XMapCommand getWallList]];
                }
            }
            else if([jcmd isEqualToString:@"wall_list_rb"])
            {
                NSDictionary* its = [result objectForKey:@"its"];
                int cnt = [[its objectForKey:@"cnt"] intValue];
                //
                [projNodeData removeAllObjects];
                //
                //获取列表
                if(cnt>0) {
                    [xmap sendPack:[XMapCommand getWallListCxt :0]];
                }
                NSLog(@"wall文件: %d", cnt);
                
            }
            else if([jcmd isEqualToString:@"wall_list_c_rb"])
            {
                NSDictionary* its = [result objectForKey:@"its"];
                ProjectNodeItem* pn = [[ProjectNodeItem alloc] init];
                //
                int index = [[its objectForKey:@"index"] intValue];
                if(-1==index)
                {
                    NSLog(@"wall文件获取完成");
                    //请求MSD信息
                    [xmap sendPack:[XMapCommand getMSDDevice]];
                }
                else
                {
                    pn.showType=1;
                    pn.wall_filename =[its objectForKey:@"file"];
                    pn.wall_label = [its objectForKey:@"label"];
                    pn.wall_description = [its objectForKey:@"desc"];
                    [projNodeData addObject:pn];
                    [self.tableView reloadData];
                    //继续获取列表
                    [xmap sendPack:[XMapCommand getWallListCxt :index+1]];
                }
            }
            else if([jcmd isEqualToString:@"online_msd_rb"])
            {
                NSDictionary* its = [result objectForKey:@"its"];
                int cnt = [[its objectForKey:@"cnt"] intValue];

                for (int i = (int)projNodeData.count - 1; i >= 0; i--) {
                    
                    ProjectNodeItem * st = projNodeData[i];
                    if (2 == st.showType){
                        
                        [projNodeData removeObjectAtIndex:i];
                    }
                }
                
//                for(ProjectNodeItem * st in projNodeData)
//                {
//                     if (2==st.showType) {
//                         [projNodeData removeObject:st];
//                     }
//                }
                if(cnt>0)
                {
                    [xmap sendPack:[XMapCommand getMSDDeviceCxt :0]];
                }
                
                NSLog(@"MSD设备: %d", cnt);
            }
            else if([jcmd isEqualToString:@"online_msd_c_rb"])
            {
                NSDictionary* its = [result objectForKey:@"its"];
                ProjectNodeItem* pn = [[ProjectNodeItem alloc] init];
                //
                int index = [[its objectForKey:@"index"] intValue];
                if(-1==index)
                {
                    //SortMSDList();
                    NSLog(@"MSD设备获取完成");
                }
                else {
                    pn.dev_devUUID = [its objectForKey:@"uuid"];
                    pn.msd_depend = [[its objectForKey:@"depend"] boolValue];
                    pn.dev_json_dict = [its objectForKey:@"info"];
                    if (![pn.dev_devUUID isEqualToString:@""]) {
                        //解释JSON
                        NSDictionary *result = pn.dev_json_dict;
                        pn.showType = 2;
                        pn.dev_devflag = [result objectForKey:@"f"];
                        pn.dev_devname = [result objectForKey:@"n"];
                        pn.dev_descript = [result objectForKey:@"d"];
                        pn.dev_label = [result objectForKey:@"l"];
                        [projNodeData addObject:pn];
                        [self.tableView reloadData];
                    }
                    //继续获取列表
                    [xmap sendPack:[XMapCommand getMSDDeviceCxt :index+1]];
                }
            }
            else if([jcmd isEqualToString:@"online_msd_income_rb"])
            {
                NSDictionary* its = [result objectForKey:@"its"];
                ProjectNodeItem* pn = [[ProjectNodeItem alloc] init];
                
                pn.dev_devUUID=[its objectForKey:@"uuid"];
                pn.msd_depend=[its objectForKey:@"depend"];
                pn.dev_json_dict = [its objectForKey:@"info"];

                //-----判断是否存在-------
                for(ProjectNodeItem * st in projNodeData)
                {
                     if (st.dev_devUUID != nil && [st.dev_devUUID isEqualToString:pn.dev_devUUID]) {
                         return;
                     }
                }

                //-----添加新设备-------
                if(![pn.dev_devUUID isEqualToString:@""]) {
                    //解释JSON
                    NSDictionary *result = pn.dev_json_dict;
                    pn.showType=2;
                    pn.dev_devflag = [result objectForKey:@"f"];
                    pn.dev_devname = [result objectForKey:@"n"];
                    pn.dev_descript = [result objectForKey:@"d"];
                    pn.dev_label = [result objectForKey:@"l"];
                    [projNodeData addObject:pn];
                    [self.tableView reloadData];
                }
            }
            else if([jcmd isEqualToString:@"online_msd_leave_rb"])
            {
                NSDictionary* its = [result objectForKey:@"its"];
                NSString* dev_devUUID=[its objectForKey:@"uuid"];
                for(ProjectNodeItem * st in projNodeData)
                {
                    if (st.dev_devUUID != nil && [st.dev_devUUID isEqualToString:dev_devUUID]) {
                        [projNodeData removeObject:st];
                    }
                }
                [self.tableView reloadData];
            }
            else if([jcmd isEqualToString:@"dev_label_modify_rb"])
            {
                NSDictionary* its = [result objectForKey:@"its"];
                BOOL ret = [[its objectForKey:@"ret"] intValue];
                if(ret) {
                    NSString* devname = [its objectForKey:@"devname"];
                    NSString* label = [its objectForKey:@"label"];
                    NSString* descript = [its objectForKey:@"desc"];
                    for(ProjectNodeItem * st in projNodeData)
                    {
                        if (st.dev_devname != nil && [st.dev_devname isEqualToString:devname]) {
                            st.dev_label=label;
                            st.dev_descript=descript;
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
