//
//  LMapView.h
//  XLocation
//
//  Created by Stefan Lage on 17/05/14.
//  Copyright (c) 2014 StefanLage. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface XLMapView : MKMapView

@property (nonatomic) BOOL isEnable;
-(void)resetRegion;

@end
