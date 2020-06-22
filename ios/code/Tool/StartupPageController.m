//
//  StartupPageController.m
//  StartupPage
//
//  Created by user on 16/11/22.
//  Copyright © 2016年 zshuo50. All rights reserved.
//

#import "StartupPageController.h"
#import "MainTabController.h"
#import "AppDelegate.h"
@interface StartupPageController ()<UIScrollViewDelegate>
@property(nonatomic,strong)UIScrollView *myScrollView;
@property(nonatomic,strong)UIPageControl *myPageControl;
@end

@implementation StartupPageController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSInteger PageCount = [_ImageArray count];
    
    _myScrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    _myScrollView.delegate = self;
    _myScrollView.contentSize = CGSizeMake(self.view.frame.size.width*PageCount, 0);
    _myScrollView.pagingEnabled = YES;
    _myScrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_myScrollView];

    
    for (int i=0; i<PageCount; i++) {
        UIImageView *myImageView = [[UIImageView alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width*i, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        [myImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@",_ImageArray[i]]]];
        [_myScrollView addSubview:myImageView];
        
            if (i==PageCount-1) {
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
            //把tapGesture（手势）添加到对应的view
            myImageView.userInteractionEnabled = true;
            [myImageView addGestureRecognizer:tapGesture];
        }
    }
}

//轻击手势触发方法
-(void)tapGesture:(UITapGestureRecognizer *)sender
{
    MainTabController *view = [[MainTabController alloc]init];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.window.rootViewController = view;
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_myPageControl setCurrentPage:_myScrollView.contentOffset.x/[UIScreen mainScreen].bounds.size.width];
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

@end
