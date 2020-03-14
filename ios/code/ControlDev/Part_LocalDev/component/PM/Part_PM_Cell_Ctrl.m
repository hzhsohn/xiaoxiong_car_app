//
//  DevListCell.m
//  discolor-led
//
//  Created by Han.zh on 15/2/7.
//  Copyright (c) 2015年 Han.zhihong. All rights reserved.
//

#import "Part_PM_Cell_Ctrl.h"


@interface Part_PM_Cell_Ctrl()
{
    __weak IBOutlet UILabel *txt1;
    __weak IBOutlet UIButton *btn1;
    __weak IBOutlet UIButton *btn2;
    __weak IBOutlet UIButton *btn3;
}
- (IBAction)btnClick:(id)sender;
- (IBAction)btn2Click:(id)sender;
- (IBAction)btn3Click:(id)sender;
@end

@implementation Part_PM_Cell_Ctrl

- (void)awakeFromNib {
    [super awakeFromNib];
}

-(void)setText:(NSString*)str;
{
    txt1.text=str;
}
-(void)setOnOff:(BOOL)b
{
    if(b)
    {txt1.backgroundColor=[UIColor greenColor];}
    else
    {txt1.backgroundColor=[UIColor redColor];}
}
- (IBAction)btnClick:(id)sender {
    [self.delegate Part_PM_Cell_Click:self.cellRow btnIndex:0];
}
- (IBAction)btn2Click:(id)sender {
    [self.delegate Part_PM_Cell_Click:self.cellRow btnIndex:1];
}
- (IBAction)btn3Click:(id)sender {
    [self.delegate Part_PM_Cell_Click:self.cellRow btnIndex:2];
}

//------------------------------
+(Part_PM_Cell_Ctrl*)loadTableCell:(UITableView*)tableView
{
        Part_PM_Cell_Ctrl*cell = (Part_PM_Cell_Ctrl *)[tableView
                                           dequeueReusableCellWithIdentifier: @"Part_PM_Cell_Ctrl"];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"Part_PM_Cell_Ctrl"
                                                         owner:self options:nil];
            // NSLog(@"nib %d",[nib count]);
            for (id oneObject in nib)
                if ([oneObject isKindOfClass:[Part_PM_Cell_Ctrl class]])
                    cell = (Part_PM_Cell_Ctrl *)oneObject;
        }
        return cell;
}

@end
