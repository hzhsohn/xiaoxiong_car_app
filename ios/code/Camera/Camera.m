//
//  ViewController.m
//  monitor
//
//  Created by Han Sohn on 12-5-31.
//  Copyright (c) 2012年 Han.zhihong. All rights reserved.
//

#import "Camera.h"
#import "assist_function.h"
//摄像头窗体
#import "DahuaDvr_iPhone.h"
#import "Canon_c50fsi_iPhone.h"
#import "Mobotix_iPhone.h"
#import "Mjpeg_iPhone.h"

@implementation Camera

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}
- (void)awakeFromNib{
    [super awakeFromNib];
    m_devMage=[[Objc_DeviceMage alloc] init];
    m_hostInfoMage=[[Objc_HostInfoMage alloc] init];
}
-(void)dealloc
{
    m_devMage=nil;
    m_hostInfoMage=nil;
    lbNetwork=nil;
    tbAddr=nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //设置标题
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [UIColor whiteColor],NSForegroundColorAttributeName,
                          [UIFont systemFontOfSize:17],NSFontAttributeName,
                          nil];
    self.navigationController.navigationBar.titleTextAttributes=dict;
    
    //加载声音
    [Objc_AudioPlay loadFile:@"btn_rollover.wav" :&m_soundSelectRow];
    
    //去除UITableView空白的多余的分割线
    tbAddr.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    //
    [m_hostInfoMage reloadHostInDB];
    [tbAddr reloadData];
}

//-------------------------修改设备的回调--------------------------
-(void) ModifyHostInfoResult:(TagHostInfo*)info
{
    [m_hostInfoMage updateHostInfo:info->autoID :info->title :info->host :info->port :info->devID :info->username :info->password :info->parameter];
    
    //更新table
    [tbAddr reloadData];
}

//////////////////////////////////////////////////////
-(void) DeviceControllerSave_callback
{
    //刷新tableview
    [tbAddr reloadData];
}

-(void) AddrTableCellbtnModify_click:(int)hostAutoID
{
    NSLog(@"modify hostAutoID=%d",hostAutoID);
    TagHostInfo *info=[m_hostInfoMage getHostByAutoID:hostAutoID];
    
    ModifyHostInfo *frm=[[ModifyHostInfo alloc] initWithNibName:@"ModifyHostInfo" bundle:nil];
    frm.delegate=self;
    [frm setInfo:info];
    [self.navigationController pushViewController:frm animated:YES];
    frm=nil;
}

////////////////////  普通事件 //////////////////////
-(IBAction) btnAdd_click:(id)sender
{
    UIStoryboard *storyBoard=[UIStoryboard storyboardWithName:@"AddHostInfo" bundle:nil];
    UITableViewController* tt = [storyBoard instantiateViewControllerWithIdentifier:@"CameraSelect"];
    [self.navigationController pushViewController:tt animated:YES];

}
-(IBAction) btnEdit_click:(id)sender
{
    NSLog(@"edit click");
    [tbAddr setEditing:(tbAddr.editing?false:true) animated:YES];
}

//////////////////// table view delegate ///////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    NSInteger nCount=[[m_hostInfoMage getHostInfoList] count];
    if (0==nCount) {
        [btnEdit setEnabled:NO];
    }
    else {
        [btnEdit setEnabled:YES];
    }
    return nCount;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //行高度
    return 80;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @" ";
}

////////////////////////////////////////////////////////////
- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    static NSString * CustomCellIdentifier= @"AddrTableCell_iPhoneIdentifier";

    AddrTableCell_iPhone *cell = (AddrTableCell_iPhone *)[tableView dequeueReusableCellWithIdentifier:CustomCellIdentifier];
    if (cell == nil)  
    {
        NSArray *nib;
        nib= [[NSBundle mainBundle] loadNibNamed:@"AddrTableCell_iPhone" 
                                               owner:self options:nil];

        //NSLog(@"nib %d",[nib count]);
        for (id oneObject in nib)
            if ([oneObject isKindOfClass:[AddrTableCell_iPhone class]])
                cell = (AddrTableCell_iPhone *)oneObject;
    }

    TagHostInfo*hostInfo=(TagHostInfo*)[[[m_hostInfoMage getHostInfoList] 
                                  objectAtIndex:indexPath.row]bytes];
    TagDeviceInfo*devInfo=(TagDeviceInfo*)[m_devMage getByDevID:hostInfo->devID];
    
    cell.delegate=self;
    cell.hostAutoID=hostInfo->autoID;
    cell.lbTitle.text = [NSString stringWithUTF8String:hostInfo->title];
    cell.lbHost.text = [NSString stringWithUTF8String:hostInfo->host];
    cell.lbPort.text = [NSString stringWithFormat:@"%d",hostInfo->port];
    [cell.imgLogo setImage:[UIImage imageNamed:
                            [NSString stringWithUTF8String:devInfo->imgName]]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [Objc_AudioPlay play:m_soundSelectRow];
    NSLog(@"select row");
 
    if (tbAddr.editing) {
        return;
    }
    
    TagHostInfo*hostInfo=(TagHostInfo*)[[[m_hostInfoMage getHostInfoList] 
                                         objectAtIndex:indexPath.row]bytes];
    
    switch (hostInfo->devID) {
            //未知设备
        case MONITOR_DEVICE_ID_UNKNOW: break;
            //大华数字录像机
        case MONITOR_DEVICE_ID_DAHUA_DVR:
        {
            DahuaDvr_iPhone *dev=[[DahuaDvr_iPhone alloc] initWithNibName:@"DahuaDvr_iPhone" bundle:nil];
            [dev setInfo:m_hostInfoMage :hostInfo :&m_network];
            dev.dev_delegate=self;
            [self.navigationController pushViewController:dev animated:YES];
            dev=nil;
        }
            break;

            //canon vb-c50fsi
        case MONITOR_DEVICE_ID_CANON_C50FSI:
        {
            Canon_c50fsi_iPhone *dev=[[Canon_c50fsi_iPhone alloc] initWithNibName:@"Canon_c50fsi_iPhone" bundle:nil];
            [dev setInfo:m_hostInfoMage :hostInfo :&m_network];
            dev.dev_delegate=self;
            [self.navigationController pushViewController:dev animated:YES];
            dev=nil;
        }
            break;
            //mobotix
        case MONITOR_DEVICE_ID_MOBOTIX:
        {
            Mobotix_iPhone *dev=[[Mobotix_iPhone alloc] initWithNibName:@"Mobotix_iPhone" bundle:nil];
            [dev setInfo:m_hostInfoMage :hostInfo :&m_network];
            dev.dev_delegate=self;
            [self.navigationController pushViewController:dev animated:YES];
            dev=nil;
        }    
            break;
            //MJPEG
        case MONITOR_DEVICE_ID_MJPEG:
        {
            Mjpeg_iPhone *dev=[[Mjpeg_iPhone alloc] initWithNibName:@"Mjpeg_iPhone" bundle:nil];
            [dev setInfo:m_hostInfoMage :hostInfo :&m_network];
            dev.dev_delegate=self;
            [self.navigationController pushViewController:dev animated:YES];
            dev=nil;
        }    
            break;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //这里一定要删除相应的数组元素,不然删除会出错
        [m_hostInfoMage deleteHostByIndex:(int)indexPath.row];

        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } 
}

//编辑效果
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //阻止滑动删除
    if (tbAddr.editing) 
    {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}
@end
