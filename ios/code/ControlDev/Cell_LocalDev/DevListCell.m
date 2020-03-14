//
//  DevListCell.m
//  discolor-led
//
//  Created by Han.zh on 15/2/7.
//  Copyright (c) 2015年 Han.zhihong. All rights reserved.
//

#import "DevListCell.h"

@implementation DevListCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

-(void)dealloc
{
}

-(void)setTitle:(NSString*)title
{
    self.lbTitle.text=title;
}

-(void)setUnkonwDev:(BOOL)b
{
    if(b)
    {
        self.lbUnknowDevflag.hidden=FALSE;
        self.lbUnknowDevflag.alpha=1;
    }
    else
    {
        self.lbUnknowDevflag.hidden=TRUE;
        self.lbUnknowDevflag.alpha=0;
    }
}

-(void)setOnline:(BOOL)lanOnline :(BOOL)yunOnline
{
    UIImage*t=[UIImage imageNamed:@"devlst_cell_online1"];
    UIImage*f=[UIImage imageNamed:@"devlst_cell_online0"];
    
    [_imgLANOnline setHidden:TRUE];
    [_imgYUNOnline setHidden:TRUE];
    if(lanOnline)
    { [_imgLANOnline setHidden:FALSE]; }
    if(yunOnline)
    { [_imgYUNOnline setHidden:FALSE]; }
    //////////////////
    if(lanOnline)
    {
        if(self.pDevInfo)
        {
            self.lbRemark.text=self.pDevInfo.ip;
        }
        else
        {
            self.lbRemark.text=NSLocalizedString(@"online", nil);
        }
    }
    else if(yunOnline)
    {
        self.lbRemark.text=NSLocalizedString(@"yunline", nil);
    }
    else
    {
        self.lbRemark.text=NSLocalizedString(@"offline", nil);
    }
    //////////////////
    self.imgOnline.backgroundColor=[UIColor clearColor];
    self.imgOnline.image=(lanOnline||yunOnline)?t:f;
}

//------------------------------
+(DevListCell*)loadTableCell:(char*)flag Table:(UITableView*)tableView
{
    DevListCell* cell = (DevListCell *)[tableView dequeueReusableCellWithIdentifier: @"DevListCell_ID"];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"DevListCell"
                                                     owner:self options:nil];
        // NSLog(@"nib %d",[nib count]);
        for (id oneObject in nib)
            if ([oneObject isKindOfClass:[DevListCell class]])
                cell = (DevListCell *)oneObject;
    }
    
    cell.nAutoID=0;
    cell.indexPathRow=0;
    cell.IndexPathSection=0;
    cell.devflag=[NSString stringWithUTF8String:flag];
    cell.pDevInfo=NULL;
    return cell;
}

@end
