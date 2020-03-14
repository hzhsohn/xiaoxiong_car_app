//
//  ESPViewController.h
//  EspTouchDemo
//
//  Created by 白 桦 on 3/23/15.
//  Copyright (c) 2015 白 桦. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ESPViewController : UIViewController<UITextFieldDelegate,CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *ssidLabel;
@property (strong, nonatomic) NSString *bssid;
@property (strong, nonatomic) CLLocationManager *locationManager;
@end
