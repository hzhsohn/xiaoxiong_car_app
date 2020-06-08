//
//  TestTabController.m
//  hx-home
//
//  Created by Han.zh on 16/4/6.
//  Copyright © 2016年 Han.zhihong. All rights reserved.
//

#import "MainTabController.h"
#import "DefineHeader.h"
#import <MapKit/MapKit.h>

CLLocationCoordinate2D g_WGS84Location;
CLLocationCoordinate2D g_GoogleLocation;

@interface MainTabController ()<UITabBarControllerDelegate,CLLocationManagerDelegate,MKMapViewDelegate>
{
    //坐标信息
    CLLocationManager *m_locationManager;
    MKMapView *m_map;
}
@end

@implementation MainTabController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.delegate = self;
    
}

-(void) viewWillAppear:(BOOL)animated
{
    //开始探测自己的位置//////////////////////
    if (nil==m_locationManager) {
        m_locationManager =[[CLLocationManager alloc] init];
        if ([CLLocationManager locationServicesEnabled])
        {
            m_locationManager.delegate=self;
            m_locationManager.desiredAccuracy=kCLLocationAccuracyBest;
            m_locationManager.distanceFilter=10.0f;
            [m_locationManager startUpdatingLocation];
        }
    }
    
    if(m_map==nil)
    {
        m_map=[[MKMapView alloc] init];
        m_map.showsUserLocation=YES;
        m_map.delegate=self;
    }
    
    /////////////////////////////////////////
    UIStoryboard *frm=NULL;
    UINavigationController *nv1=NULL,*nv2=NULL,*nv3=NULL;
    
    frm = [UIStoryboard storyboardWithName:@"webwk" bundle:nil];
    nv1=(UINavigationController*)frm.instantiateInitialViewController;
    
    frm = [UIStoryboard storyboardWithName:@"webwk2" bundle:nil];
    nv2=(UINavigationController*)frm.instantiateInitialViewController;
    
    frm = [UIStoryboard storyboardWithName:@"webwk3" bundle:nil];
    nv3=(UINavigationController*)frm.instantiateInitialViewController;
    
    NSMutableArray *tabc = [[NSMutableArray alloc] init];//[self viewControllers]
    [tabc addObject:nv1];
    [tabc addObject:nv2];
    [tabc addObject:nv3];
    [self setViewControllers:tabc animated:YES];
    
    UIImage* img1=[[UIImage imageNamed:@"mainItmIcon1"]
                   imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage* img2=[[UIImage imageNamed:@"mainItmIcon2"]
                   imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage* img3=[[UIImage imageNamed:@"mainItmIcon3"]
                   imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    [(UITabBarItem *)[self.tabBar.items objectAtIndex:0] setTitle:NSLocalizedString(@"MainItem1", nil)];
    [(UITabBarItem *)[self.tabBar.items objectAtIndex:0] setImage:img1];
    [(UITabBarItem *)[self.tabBar.items objectAtIndex:1] setTitle:NSLocalizedString(@"MainItem2", nil)];
    [(UITabBarItem *)[self.tabBar.items objectAtIndex:1] setImage:img2];
    [(UITabBarItem *)[self.tabBar.items objectAtIndex:2] setTitle:NSLocalizedString(@"MainItem3", nil)];
    [(UITabBarItem *)[self.tabBar.items objectAtIndex:2] setImage:img3];
    
    for(int i=0;i<[self.tabBar.items count];i++)
    {
        [(UITabBarItem *)[self.tabBar.items objectAtIndex:i] setTag:i];
    }
    
    [tabc removeAllObjects];
    tabc=nil;
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
  
    return YES;
}

-(void) tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


////////////////////////////////

//坐标回调
- (void) locationManager:(CLLocationManager *)manager
     didUpdateToLocation:(CLLocation *)newLocation
            fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"newLocation:%@",[newLocation description]);
    //保存新位置
    g_WGS84Location=newLocation.coordinate;
    
    //获取完坐标后关闭
    [m_locationManager stopUpdatingLocation];
    //[m_locationManager release];
    m_locationManager=nil;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    NSLog(@"didUpdateUserLocation %@",userLocation.location);
    g_GoogleLocation=userLocation.location.coordinate;
    
    m_map.delegate=nil;
    //[m_map release];
    m_map=nil;
}

@end
