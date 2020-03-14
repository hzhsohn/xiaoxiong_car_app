//
//  KeyMangr.m
//  home
//
//  Created by Han.zh on 15/10/3.
//  Copyright © 2015年 Han.zhihong. All rights reserved.
//

#import "DevKeyMangrForm.h"
#import "KeyMgrCell.h"
#import "DevKeyMagr.h"
#import "DevPasswdMagr.h"
#import "DefineHeader.h"
#import "ComponentBase.h"

@interface DevKeyMangrForm()
{
    DevKeyMagr* _devmgr;   //数据库操作对象
    NSMutableArray *_aryDevInDB;//搜索到的在线且数据库中有保存的设备

}

- (IBAction)tbEdit_click:(id)sender;

@end

@implementation DevKeyMangrForm

-(void)awakeFromNib
{
    [super awakeFromNib];
    //
    _devmgr=[[DevKeyMagr alloc] init];
    //
    _aryDevInDB=[[NSMutableArray alloc] init];
}

-(void)dealloc
{
    //[super dealloc];
    NSLog(@"KeyMangr dealloc");
    
    _devmgr=NULL;
    _aryDevInDB=NULL;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.editing=YES;
    
    //获取数据库中的数据
    [_devmgr getDevInfoAllKeyMgr:_aryDevInDB];
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


/////////////////////////////////////////////////////////
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_aryDevInDB count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    KeyMgrCell *cell = (KeyMgrCell *)[tableView
                                        dequeueReusableCellWithIdentifier: @"KeyMgrCell_ID"];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"KeyMgrCell"
                                                     owner:self options:nil];
        // NSLog(@"nib %d",[nib count]);
        for (id oneObject in nib)
            if ([oneObject isKindOfClass:[KeyMgrCell class]])
                cell = (KeyMgrCell *)oneObject;
    }
    
    //内容
    TzhKeyMgr *p=(TzhKeyMgr *)[[_aryDevInDB objectAtIndex:indexPath.row] bytes];
    DevPasswdMagr*p2=[[DevPasswdMagr alloc] init];
    TzhPasswdMgr t=[p2 getInfoByUUID:[NSString stringWithUTF8String:p->devUUID]];
    [cell.lbTitleValue setText:[NSString stringWithUTF8String:p->devname]];
    [cell.lbFlag setText:[NSString stringWithUTF8String:p->devflag]];
    //判断密码是否为空
    if (strcmp("",t.passwd) && strcmp([DEFAUT_LOCAL_PASSWD_NULL_VAL UTF8String], t.passwd)) {
        //显示密码 [cell.lbPasswdValue setText:[NSString stringWithUTF8String:p->passwd]];
        [cell.lbPasswdValue setText:[NSString stringWithUTF8String:t.passwd]];
    }
    else{
        [cell.lbPasswdValue setText:NSLocalizedString(@"<NULL>", nil)];
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

//删除
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
        //delete
        TzhKeyMgr *p=(TzhKeyMgr *)[[_aryDevInDB objectAtIndex:indexPath.row] bytes];
        if ([_devmgr deleteDevInfo:p->autoID])
        {
            [DevPasswdMagr deletePasswdByDevUUID: [NSString stringWithUTF8String:p->devUUID]];
            [_aryDevInDB removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert", nil)
                        message:NSLocalizedString(@"keymgr_delfail", nil)
                       delegate:self
              cancelButtonTitle:NSLocalizedString(@"ok", nil)
              otherButtonTitles:nil];
            [alert show];
            alert=NULL;
        }
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString(@"device_magr",nil);
}

- (IBAction)tbEdit_click:(id)sender
{
    self.tableView.editing=!self.tableView.editing;
}
@end
