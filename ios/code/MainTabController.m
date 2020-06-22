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


#import "ZipFile.h"
#import "ZipException.h"
#import "FileInZipInfo.h"
#import "ZipWriteStream.h"
#import "ZipReadStream.h"

//! 导入WebKit框架头文件
#import <WebKit/WebKit.h>
#import "AlertCommand.h"
#import "JDDeviceUtils.h"

CLLocationCoordinate2D g_WGS84Location;
CLLocationCoordinate2D g_GoogleLocation;

@interface MainTabController ()<UITabBarControllerDelegate,CLLocationManagerDelegate,MKMapViewDelegate>
{
    //坐标信息
    CLLocationManager *m_locationManager;
    MKMapView *m_map;
    
    
    bool g_iphone_uncompress_thread;
}
@end

@implementation MainTabController



///////////// 解压帮助文档数据 ///////////////////
- (void) uncompress_help_data
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"www" ofType:@"zip"];
    g_iphone_uncompress_thread=true;
    
    //延时效果
    [NSThread sleepForTimeInterval:0.5f];
    @autoreleasepool {
    
        @try {
            NSLog(@"%@",filePath);
            
            ZipFile *unzipFile= [[ZipFile alloc] initWithFileName:filePath mode:ZipFileModeUnzip];
            
            NSLog(@"Opening zip file for reading..");
            
            //开始解压
            NSArray *infos= [unzipFile listFileInZipInfos];
            [unzipFile goToFirstFileInZip];
            for (FileInZipInfo *info in infos) {
                //延时效果
                //[NSThread sleepForTimeInterval:0.01f];
                if (false==g_iphone_uncompress_thread) {
                    [unzipFile close];
                   // [unzipFile release];
                    unzipFile=nil;
                    return;
                }
                
                //生成文件
                ZipReadStream *read1= [unzipFile readCurrentFileInZip];
                
                NSString*str=[NSString stringWithFormat:@"Extract %@...",info.name];
                NSLog(@"%@",str);
                
                //字节数据
                NSMutableData *data1= [[NSMutableData alloc] initWithLength:info.length];
                int bytesRead1= [read1 readDataWithBuffer:data1];
                
                //全部文件解压到同一目录
                //NSString *wfiles= [self documentPath:[info.name lastPathComponent]];
                NSString *wfiles= [self documentPath:info.name];
                NSLog(@"wfiles=%@",wfiles);
                
                //建立目录
                NSString *dir=[wfiles stringByDeletingLastPathComponent];
                if (access([dir UTF8String], 0))
                {
                    //不存在目录就新建
                    [[NSFileManager defaultManager] createDirectoryAtPath:dir
                                              withIntermediateDirectories:YES
                                                               attributes:nil
                                                                    error:nil];
                }
                else
                {
                    //判断存放路径是否是目录
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    BOOL isDir = NO;
                    [fileManager fileExistsAtPath:dir isDirectory:(&isDir)];
                    if (false==isDir) {
                        //如果是文件就删除掉
                        [[NSFileManager defaultManager] removeItemAtPath:dir error:nil];
                        //重新创建目录就新建
                        [[NSFileManager defaultManager] createDirectoryAtPath:dir
                                                  withIntermediateDirectories:YES
                                                                   attributes:nil
                                                                        error:nil];
                    }
                }
                
                BOOL ok=[data1 writeToFile:wfiles atomically:YES];
                //[data1 release];
                data1=nil;
                if (ok)
                {
                    NSString*str=[NSString stringWithFormat:@"Done. bytes=%d",bytesRead1];
                    NSLog(@"%@",str);
                }
                else
                {
                    NSString*str=[NSString stringWithFormat:@"Done. extract fail"];
                    NSLog(@"%@",str);
                }
                [read1 finishedReading];
                [unzipFile goToNextFileInZip];
            }
            [unzipFile close];
            //[unzipFile release];
            unzipFile=nil;
            
        } @catch (ZipException *ze) {
            NSString*str=[NSString stringWithFormat:@"ZipException caught: %ld - %@\r\n", (long)ze.error, [ze reason]];
            NSLog(@"%@",str);
        } @catch (id e) {
            NSString*str=[NSString stringWithFormat:@"Exception caught: %@ - %@\r\n", [[e class] description], [e description]];
            NSLog(@"%@",str);
        }
        
        //写入帮助文档版本号
        NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
        NSString *version =[infoDict valueForKey:@"CFBundleVersion"];
        NSString *versFiles= [self documentPath:@"help_version"];
        NSLog(@"versFiles=%@",versFiles);
        NSData*verData=[NSData dataWithBytes:[version UTF8String] length:[version length]];
        [verData writeToFile:versFiles atomically:YES];
        
        //跳到读取
        [self extractEnd];
    
    }
}

-(void) extractBegin
{
    //解压文档
    [self performSelector:@selector(uncompress_help_data) withObject:nil afterDelay:0.5f];
}


-(void) extractEnd
{
}

-(NSString*) documentPath:(NSString*)str
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    
    if (nil!=str) {
        return [documentsDir stringByAppendingPathComponent:str];
    }
    return documentsDir;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.delegate = self;
    
    /*
    //判断文件是否存在
    NSString *startpage= [self documentPath:@"startpage"];
    NSLog(@"startpage=%@",startpage);
    if(access([startpage UTF8String],0))
    {
        //文件不存在就解压
        g_iphone_uncompress_thread=false;
        [self extractBegin];
    }*/
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
