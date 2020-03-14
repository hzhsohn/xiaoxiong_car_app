//
//  ESPViewController.m
//  EspTouchDemo
//
//  Created by 白 桦 on 3/23/15.
//  Copyright (c) 2015 白 桦. All rights reserved.
//
//  版本: v0.3.5.1

#import "ESPViewController.h"
#import "ESPTouchTask.h"
#import "ESPTouchResult.h"
#import "ESP_NetUtil.h"
#import "ESPTouchDelegate.h"

#import <SystemConfiguration/CaptiveNetwork.h>


// the three constants are used to hide soft-keyboard when user tap Enter or Return
#define HEIGHT_KEYBOARD 216
#define HEIGHT_TEXT_FIELD 30
#define HEIGHT_SPACE (6+HEIGHT_TEXT_FIELD)


@interface EspTouchDelegateImpl : NSObject<ESPTouchDelegate>

@end

@implementation EspTouchDelegateImpl

-(void) dismissAlert:(UIAlertView *)alertView
{
    [alertView dismissWithClickedButtonIndex:[alertView cancelButtonIndex] animated:YES];
}

-(void) showAlertWithResult: (ESPTouchResult *) result
{
    NSString *title = nil;
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"%@ is connected to the wifi",nil) , result.bssid];
    NSTimeInterval dismissSeconds = 3.5;
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"ok",nil)  otherButtonTitles:nil];
    [alertView show];
    [self performSelector:@selector(dismissAlert:) withObject:alertView afterDelay:dismissSeconds];
}

-(void) onEsptouchResultAddedWithResult: (ESPTouchResult *) result
{
    NSLog(@"EspTouchDelegateImpl onEsptouchResultAddedWithResult bssid: %@", result.bssid);
    dispatch_async(dispatch_get_main_queue(), ^{
        //[self showAlertWithResult:result];
    });
}

@end

@interface ESPViewController ()
{
    NSString *ssidName;
}

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *_spinner;
@property (weak, nonatomic) IBOutlet UITextField *_pwdTextView;
@property (weak, nonatomic) IBOutlet UITextField *_taskResultCountTextView;
@property (weak, nonatomic) IBOutlet UIButton *_confirmCancelBtn;
@property (weak, nonatomic) IBOutlet UILabel *_lbSsidIsHidden;

// to cancel ESPTouchTask when
@property (atomic, strong) ESPTouchTask *_esptouchTask;

// the state of the confirm/cancel button
@property (nonatomic, assign) BOOL _isConfirmState;

// without the condition, if the user tap confirm/cancel quickly enough,
// the bug will arise. the reason is follows:
// 0. task is starting created, but not finished
// 1. the task is cancel for the task hasn't been created, it do nothing
// 2. task is created
// 3. Oops, the task should be cancelled, but it is running
@property (nonatomic, strong) NSCondition *_condition;

@property (nonatomic, strong) UIButton *_doneButton;
@property (nonatomic, strong) EspTouchDelegateImpl *_esptouchDelegate;


//
- (NSString *) getDeviceSSID;
//左边插入文字
-(void)leftText:(UITextField*)target :(NSString*)title;@end

@implementation ESPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title =NSLocalizedString(@"Quckly Set", nil);

    
   if(@available(iOS 13.0, *)){
       [self getUserLocation];
   }


    self._confirmCancelBtn.layer.masksToBounds = true;
    self._confirmCancelBtn.layer.cornerRadius = 5;
    self._isConfirmState = NO;
    self._pwdTextView.delegate = self;
    self._pwdTextView.keyboardType = UIKeyboardTypeASCIICapable;
    self._taskResultCountTextView.delegate = self;
    self._taskResultCountTextView.keyboardType = UIKeyboardTypeNumberPad;
    self._condition = [[NSCondition alloc]init];
    self._esptouchDelegate = [[EspTouchDelegateImpl alloc]init];
    [self enableConfirmBtn];
    
    //获取手机当前的SSID
    [self leftText:self.ssidLabel :NSLocalizedString(@"EspWifiSSID", nil)];
    ssidName=[self getDeviceSSID];
    [self.ssidLabel setText:ssidName];
    
    //
    [self leftText:self._pwdTextView :NSLocalizedString(@"EspWifiPwd", nil)];
    [self leftText:self._taskResultCountTextView :NSLocalizedString(@"Task result count", nil)];
    self._lbSsidIsHidden.text=NSLocalizedString(@"SSID is Hidden", nil);
    __spinner.layer.cornerRadius = 10;//设置那个圆角的有多圆
    __spinner.layer.borderWidth = 0;//设置边框的宽度
    //
    UILabel *lbSpinnerTxt=[[UILabel alloc] initWithFrame:CGRectMake(0, 95, 120, 22)];
    [lbSpinnerTxt setFont:[UIFont systemFontOfSize:14]];
    [lbSpinnerTxt setTextAlignment:NSTextAlignmentCenter];
    [lbSpinnerTxt setBackgroundColor:[UIColor clearColor]];
    [lbSpinnerTxt setTextColor:[UIColor whiteColor]];
    [lbSpinnerTxt setText:NSLocalizedString(@"Esptouch Searching", nil)];
    [__spinner addSubview:lbSpinnerTxt];
    lbSpinnerTxt=nil;
    
    //
    [self.view bringSubviewToFront:__spinner];
    [self.view bringSubviewToFront:__confirmCancelBtn];
    
}


-(void)leftText:(UITextField*)target :(NSString*)title
{
    //左边插入LABEL文字
    UILabel *lb1;
    lb1=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 90, 24)];
    [lb1 setText:title];
    [lb1 setTextAlignment:NSTextAlignmentRight];
    target.leftView = lb1;
    target.leftViewMode = UITextFieldViewModeAlways;
    lb1=nil;
}


- (IBAction)tapConfirmCancelBtn:(UIButton *)sender
{
    [self tapConfirmForResults];
}


- (void) tapConfirmForResults
{
    // do confirm
    if (self._isConfirmState)
    {
        if (ssidName==nil||[ssidName isEqualToString:@""])
        {
            [[[UIAlertView alloc]initWithTitle:nil
                                       message:NSLocalizedString(@"apSsidIsNULL", nil)
                                      delegate:nil
                             cancelButtonTitle:NSLocalizedString(@"ok", nil)
                             otherButtonTitles:nil]show];
            return ;
        }
        
        [self._spinner startAnimating];
        [self enableCancelBtn];
        NSLog(@"ESPViewController do confirm action...");
        dispatch_queue_t  queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            NSLog(@"ESPViewController do the execute work...");
            // execute the task
            NSArray *esptouchResultArray = [self executeForResults];
            // show the result to the user in UI Main Thread
            dispatch_async(dispatch_get_main_queue(), ^{
                [self._spinner stopAnimating];
                [self enableConfirmBtn];
                
                ESPTouchResult *firstResult = [esptouchResultArray objectAtIndex:0];
                // check whether the task is cancelled and no results received
                if (!firstResult.isCancelled)
                {
                    NSMutableString *mutableStr = [[NSMutableString alloc]init];
                    NSUInteger count = 0;
                    // max results to be displayed, if it is more than maxDisplayCount,
                    // just show the count of redundant ones
                    const int maxDisplayCount = 5;
                    if ([firstResult isSuc])
                    {
                        
                        for (int i = 0; i < [esptouchResultArray count]; ++i)
                        {
                            ESPTouchResult *resultInArray = [esptouchResultArray objectAtIndex:i];
                            [mutableStr appendString:[resultInArray description]];
                            [mutableStr appendString:@"\n"];
                            count++;
                            if (count >= maxDisplayCount)
                            {
                                break;
                            }
                        }
                        
                        if (count < [esptouchResultArray count])
                        {
                            [mutableStr appendString:[NSString stringWithFormat:@"\nthere's %lu more result(s) without showing\n",(unsigned long)([esptouchResultArray count] - count)]];
                        }
                        [[[UIAlertView alloc]initWithTitle:nil
                                                   message:mutableStr
                                                  delegate:nil
                                         cancelButtonTitle:NSLocalizedString(@"ok", nil) otherButtonTitles:nil]show];
                    }
                    
                    else
                    {
                        //输入设备密码的框
                        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"not found device", nil)
                                                                      message:NSLocalizedString(@"try to web setting", nil)
                                                                     delegate:self
                                                            cancelButtonTitle:NSLocalizedString(@"cancel", nil)
                                                            otherButtonTitles:NSLocalizedString(@"ok", nil),nil];
                        alert.tag=876;
                        [alert show];
                        alert=NULL;
                    }
                }
                
            });
        });
    }
    // do cancel
    else
    {
        [self._spinner stopAnimating];
        [self enableConfirmBtn];
        NSLog(@"ESPViewController do cancel action...");
        [self cancel];
    }
}

- (void) tapConfirmForResult
{
    // do confirm
    if (self._isConfirmState)
    {
        [self._spinner startAnimating];
        [self enableCancelBtn];
        NSLog(@"ESPViewController do confirm action...");
        dispatch_queue_t  queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            NSLog(@"ESPViewController do the execute work...");
            // execute the task
            ESPTouchResult *esptouchResult = [self executeForResult];
            // show the result to the user in UI Main Thread
            dispatch_async(dispatch_get_main_queue(), ^{
                [self._spinner stopAnimating];
                [self enableConfirmBtn];
                // when canceled by user, don't show the alert view again
                if (!esptouchResult.isCancelled)
                {
                    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Esptouch Success",nil)
                                                message:[esptouchResult description] delegate:nil
                                      cancelButtonTitle:NSLocalizedString(@"ok",nil)
                                      otherButtonTitles: nil] show];
                }
            });
        });
    }
    // do cancel
    else
    {
        [self._spinner stopAnimating];
        [self enableConfirmBtn];
        NSLog(@"ESPViewController do cancel action...");
        [self cancel];
    }
}

#pragma mark - the example of how to cancel the executing task

- (void) cancel
{
    [self._condition lock];
    if (self._esptouchTask != nil)
    {
        [self._esptouchTask interrupt];
    }
    [self._condition unlock];
}

#pragma mark - the example of how to use executeForResults
- (NSArray *) executeForResults
{
    [self._condition lock];
    NSString *apSsid = ssidName;
    NSString *apPwd = self._pwdTextView.text;
    NSString *apBssid = self.bssid;
    BOOL isSsidHidden = TRUE;
    int taskCount = [self._taskResultCountTextView.text intValue];
    self._esptouchTask =
    [[ESPTouchTask alloc]initWithApSsid:apSsid andApBssid:apBssid andApPwd:apPwd andIsSsidHiden:isSsidHidden];
    // set delegate
    [self._esptouchTask setEsptouchDelegate:self._esptouchDelegate];
    [self._condition unlock];
    NSArray * esptouchResults = [self._esptouchTask executeForResults:taskCount];
    NSLog(@"ESPViewController executeForResult() result is: %@",esptouchResults);
    return esptouchResults;
}

#pragma mark - the example of how to use executeForResult

- (ESPTouchResult *) executeForResult
{
    [self._condition lock];
    NSString *apSsid = ssidName;
    NSString *apPwd = self._pwdTextView.text;
    NSString *apBssid = self.bssid;
    BOOL isSsidHidden = TRUE;
    self._esptouchTask =
    [[ESPTouchTask alloc]initWithApSsid:apSsid andApBssid:apBssid andApPwd:apPwd andIsSsidHiden:isSsidHidden];
    // set delegate
    [self._esptouchTask setEsptouchDelegate:self._esptouchDelegate];
    [self._condition unlock];
    ESPTouchResult * esptouchResult = [self._esptouchTask executeForResult];
    NSLog(@"ESPViewController executeForResult() result is: %@",esptouchResult);
    return esptouchResult;
}

// enable confirm button
- (void)enableConfirmBtn
{
    self._isConfirmState = YES;
    [self._confirmCancelBtn setTitle:NSLocalizedString(@"btnESPConfirm", nil) forState:UIControlStateNormal];
}

// enable cancel button
- (void)enableCancelBtn
{
    self._isConfirmState = NO;
    [self._confirmCancelBtn setTitle:NSLocalizedString(@"btnESPCancel", nil) forState:UIControlStateNormal];
}


- (NSString *)getDeviceSSID{
    NSString *wifiName = @"Not Found";
    CFArrayRef myArray = CNCopySupportedInterfaces();
    if (myArray != nil) {
        CFDictionaryRef myDict = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(myArray, 0));
        if (myDict != nil) {
            NSDictionary *dict = (NSDictionary*)CFBridgingRelease(myDict);
            wifiName = [dict valueForKey:@"SSID"];
        }
    }
    NSLog(@"wifiName:%@", wifiName);
    return wifiName;
}

#pragma mark - the follow codes are just to make soft-keyboard disappear at necessary time


// when user tap Enter or Return, disappear the keyboard
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


//重载的函数
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case 876:
        {
            if(1==buttonIndex)
            {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
            break;
    }
}

#pragma mark - 定位授权代理方法
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse ||
        status == kCLAuthorizationStatusAuthorizedAlways) {
        //再重新获取ssid
        ssidName=[self getDeviceSSID];
        [self.ssidLabel setText:ssidName];
    }
}
 
- (void)getUserLocation{
    if (!self.locationManager) {
        self.locationManager = [[CLLocationManager alloc] init];
    }
    //如果用户第一次拒绝了，触发代理重新选择，要用户打开位置权限
    [self.locationManager requestAlwaysAuthorization];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 1.0f;
    [self.locationManager startUpdatingLocation];
    
}

@end

