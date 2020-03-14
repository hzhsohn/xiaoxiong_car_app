//
//  AddrTableCell.m
//  monitor
//
//  Created by Han Sohn on 12-5-31.
//  Copyright (c) 2012年 Han.zhihong. All rights reserved.
//

#import "AddrTableCell_iPhone.h"

@implementation AddrTableCell_iPhone
@synthesize delegate;
@synthesize hostAutoID;
@synthesize imgLogo;
@synthesize lbTitle;
@synthesize lbHost;
@synthesize lbPort;
@synthesize btnModify;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)willTransitionToState:(UITableViewCellStateMask)state {
	[super willTransitionToState:state];

    if (state==3)
    {
        //删除按钮
        for (UIView *subView in self.subviews)
        {
            if ([NSStringFromClass([subView class]) isEqualToString:@"UITableViewCellDeleteConfirmationControl"])
            {
                subView.alpha =0;
                m_fBtnModiftMove=subView.frame.size.width-20;
            }
        }
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    
    //NSLog(@"state =%d",state);

    if (m_eState==1 && state==3)
    {
        [btnModify setFrame:CGRectMake(btnModify.frame.origin.x-m_fBtnModiftMove,
                                       btnModify.frame.origin.y, 
                                       btnModify.frame.size.width,
                                       btnModify.frame.size.height)];
        btnModify.alpha=0.6f;
    }
    else if(m_eState==3 && state==1) {
        [btnModify setFrame:CGRectMake(btnModify.frame.origin.x+m_fBtnModiftMove,
                                       btnModify.frame.origin.y, 
                                       btnModify.frame.size.width,
                                       btnModify.frame.size.height)];
        btnModify.alpha=1.0f;
    }
    [UIView setAnimationTransition:UIViewAnimationTransitionNone 
                           forView:btnModify cache:YES];	
    [UIView commitAnimations];
    
    m_eState=state;
}

- (void)didTransitionToState:(UITableViewCellStateMask)state {
	[super didTransitionToState:state];
	if ((state & UITableViewCellStateShowingDeleteConfirmationMask) == UITableViewCellStateShowingDeleteConfirmationMask)
    {
        //删除按钮
        for (UIView *subView in self.subviews)
        {
            if ([NSStringFromClass([subView class]) isEqualToString:@"UITableViewCellDeleteConfirmationControl"])
            {
                [NSThread sleepForTimeInterval:0.15];
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:0.3];
                subView.alpha = 1.0f;
                [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:subView cache:YES];	
                [UIView commitAnimations];
            }
        }
	}
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    if (editing) {
        btnModify.alpha=1;
    }
    else {
        btnModify.alpha=0;
    }
    
    [UIView setAnimationTransition:UIViewAnimationTransitionNone 
                           forView:btnModify cache:YES];	
    [UIView commitAnimations];
}

- (void)dealloc {
    delegate=nil;
    imgLogo=nil;
    lbTitle=nil;
    lbHost=nil;
    lbPort=nil;
    btnModify=nil;
}

-(IBAction) btnModify_click:(id)sender
{
    [delegate AddrTableCellbtnModify_click:hostAutoID];
}

@end
