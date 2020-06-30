//
//  CloudManage.m
//  discolor-led
//
//  Created by Han.zh on 15/2/7.
//  Copyright (c) 2015年 Han.zhihong. All rights reserved.
//

#import "WebController.h"
#import <QuartzCore/QuartzCore.h>
#import "DefineHeader.h"
#import "WebController.h"
#import <MJRefresh/MJRefresh.h>
#import <Foundation/Foundation.h>
//! 导入WebKit框架头文件
#import <WebKit/WebKit.h>
#import "AlertCommand.h"

//
#import "WKProcessPool.h"
#import "WKDeviceUtils.h"

@interface WebController ()<WKScriptMessageHandler,WKUIDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (strong ,nonatomic)   WKWebView *wkWebView;
@property (strong ,nonatomic)   UIImagePickerController * cameraPicker ;
@property (nonatomic) AlertCommand* acmd;

-(void) loadWeb:(NSString*)url_str;

@end

@implementation WebController
@synthesize acmd;

-(void)awakeFromNib
{
    [super awakeFromNib];
    acmd=[[AlertCommand alloc] init];
}


-(CGRect) getFrmPos
{
    CGRect f= [ UIScreen mainScreen ].bounds;
    //处理浏览器高度问题,判断是否有导航栏如果有导航栏即加-44高度
    int navh=0;
    NSString*devIfs=[WKDeviceUtils getDeviceIdentifier];
    //devIfs=@"iPhone 11 Pro";
    if([devIfs isEqualToString:@"iPhone 11"] ||
       [devIfs isEqualToString:@"iPhone 11 Pro"] ||
       [devIfs isEqualToString:@"iPhone 11 Pro Max"] )
    {
        int sum=-44+navh;
        f.origin.y+=sum;
        f.size.height-=sum-34;
    }
    else{
        int sum=-20+navh;
        f.origin.y+=sum;
        f.size.height-=sum;
    }

    return f;
}

-(void) loadWeb:(NSString*)url_str
{
#if 0
   //
    NSURL *url = [NSURL URLWithString:url_str];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [self.wkWebView loadRequest:request];
    
#else
    //
  /*  NSURL *url = [NSURL URLWithString:@"https://www.daichepin.com/webphone_ios/webphone/client_register/#/client/register?phone=445566&code=111111"];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [wkweb loadRequest:request];
    */
    //加载调试页面
    //NSURL *url = [[NSBundle mainBundle] URLForResource:@"index_test" withExtension:@"html"];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"selectPhoto" withExtension:@"html"];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [self.wkWebView loadRequest:urlRequest]; // 加载页面
#endif
}

- (void)viewDidLoad {
    [super viewDidLoad];

    //设置标题
    /*NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                        [UIColor whiteColor],NSForegroundColorAttributeName,
                        [UIFont systemFontOfSize:17],NSFontAttributeName,
                        nil];
    self.navigationController.navigationBar.titleTextAttributes=dict;
    */
    [self.navigationController setNavigationBarHidden:YES animated:NO];

    //
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    // 设置偏好设置
    config.preferences = [[WKPreferences alloc] init];
    // 默认为0
    config.preferences.minimumFontSize = 10;
    // 默认认为YES
    config.preferences.javaScriptEnabled = YES;
    // 在iOS上默认为NO，表示不能自动通过窗口打开
    config.preferences.javaScriptCanOpenWindowsAutomatically = NO;
    // web内容处理池，由于没有属性可以设置，也没有方法可以调用，不用手动创建
    config.processPool = [[WKProcessPool alloc] init];
    // 通过JS与webview内容交互
    config.userContentController = [[WKUserContentController alloc] init];
    // 注入JS对象名称AppModel，当JS通过AppModel来调用时，
    // 我们可以在WKScriptMessageHandler代理中接收到
    [config.userContentController addScriptMessageHandler:self name:@"AppModel"];
    
    WKWebView *wkWebView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    wkWebView.UIDelegate = self;
    
    [self.view addSubview:wkWebView];
    self.wkWebView = wkWebView;
    
    //访问页面
   [self loadWeb:self.default_url];//主页
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"AppModel"]) {
        // 打印所传过来的参数，只支持NSNumber, NSString, NSDate, NSArray,
        // NSDictionary, and NSNull类型
        NSLog(@"%@", message.body);
        
        NSDictionary *bodyDic = (NSDictionary *)message.body;
        
        NSString *chooseInfoString = [bodyDic objectForKey:@"body"];
        
        NSDictionary *chooseInfo  = [self dictionaryWithJsonString:chooseInfoString];
        
        [self didClickRightButtonWithChooseInfo:chooseInfo];
    }
}

#pragma  mark - 相机调用拍照
- (void)didClickRightButtonWithChooseInfo:(NSDictionary *)chooseInfo {
   
    _cameraPicker = [[UIImagePickerController alloc] init];
    _cameraPicker.delegate = self;
    _cameraPicker.allowsEditing = YES;
    
    
    BOOL isPhotoAlbum = [chooseInfo[@"imageLibrary"] boolValue];
    BOOL isCameraType = [chooseInfo[@"camera"] boolValue];
    
    if (!isPhotoAlbum) {
        
        _cameraPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:_cameraPicker animated:YES completion:nil];

    } else {
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            _cameraPicker.sourceType = UIImagePickerControllerSourceTypeCamera;

            //设置相机摄像头默认为前置
            if (!isCameraType) {
                _cameraPicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
            } else {
                _cameraPicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
            }
            //相机的调用为照相模式
            _cameraPicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
            //设置为NO则隐藏了拍照按钮
            _cameraPicker.showsCameraControls = NO;
            //设置相机闪光灯开关
            _cameraPicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
            
            //自定义覆盖图层-->overlayview
            UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0,self.view.frame.size.height - 200, self.view.frame.size.width, 200)];
            customView.backgroundColor = [UIColor greenColor];
            
            UIButton *startButton = [UIButton buttonWithType:UIButtonTypeCustom];
            startButton.frame = CGRectMake(customView.frame.size.width/2-25, 100, 50, 50);
            [startButton setTitle:@"拍照" forState:UIControlStateNormal];
            [startButton setBackgroundColor:[UIColor orangeColor]];
            [startButton addTarget:self action:@selector(startButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            [customView addSubview:startButton];

            UIButton *cleanButton = [UIButton buttonWithType:UIButtonTypeCustom];
            cleanButton.frame = CGRectMake(50, 100, 50, 50);
            [cleanButton setTitle:@"取消" forState:UIControlStateNormal];
            [cleanButton setBackgroundColor:[UIColor redColor]];
            [cleanButton addTarget:self action:@selector(cleanButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            [customView addSubview:cleanButton];
            
            _cameraPicker.cameraOverlayView = customView;
 
            [self presentViewController:_cameraPicker animated:YES completion:nil];

        } else {
            
            UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"提示" message:@"当前设备不支持相机调用" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
            [alertView addAction:action];
            [self presentViewController:alertView animated:YES completion:nil];
        }

    }
    
}

- (void)startButtonClick:(UIButton *)sender {
    
    [_cameraPicker takePicture];
}

- (void)cleanButtonClick:(UIButton *)sender {
    
    [_cameraPicker dismissViewControllerAnimated:YES completion:nil];
 }
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    /*-------------------------------相机拍照--------------------------------------*/
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        
        UIImage * image = [info objectForKey:UIImagePickerControllerEditedImage];
        [self uploadImageWithImage:image];
        [self dismissViewControllerAnimated:YES completion:nil];
        
    } else if (picker .sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        
        UIImage * image = [info objectForKey:UIImagePickerControllerEditedImage];
        [self uploadImageWithImage:image];
                [self dismissViewControllerAnimated:YES completion:nil];
    }

}

//上传图片到H5
- (void)uploadImageWithImage:(UIImage *)image {
    
    
    NSData *imageData =  UIImageJPEGRepresentation(image, 0.2);
    
    
    NSString *encodedImageStr = [imageData base64Encoding];
    
    NSString *jsString = [NSString stringWithFormat:@"changeImage('%@')",encodedImageStr];
    [self.wkWebView evaluateJavaScript:jsString completionHandler:^(id _Nullable sender, NSError * _Nullable error) {
        NSLog(@"%@",error);
        
    }];
    
}

/* 警告框，页面中有调用JS的 alert 方法就会调用该方法 */
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    UIAlertView* customAlert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    
    [customAlert show];
    completionHandler();
}

/*!
 * @brief 把格式化的JSON格式的字符串转换成字典
 * @param jsonString JSON格式的字符串
 * @return 返回字典
 */
- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
