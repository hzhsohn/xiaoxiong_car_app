//
//  MapPlace.h
//  monitor
//
//  Created by Han Sohn on 12-7-15.
//  Copyright (c) 2012年 Han.zhihong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapPlace : NSObject<MKAnnotation> {
    CLLocationCoordinate2D coordinate;
    NSMutableString* m_sTitle;
    NSMutableString* m_sContent;
}
@property (nonatomic,readonly)CLLocationCoordinate2D coordinate;
- (id)setInfo:(CLLocationCoordinate2D)c :(NSString*)t :(NSString*)str;
- (NSString *)subtitle;
- (NSString *)title;
@end