//
//  LAnnotation.h
//  XLocation
//
//  Created by Stefan Lage on 17/05/14.
//  Copyright (c) 2014 StefanLage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface XLAnnotation : NSObject

@property (nonatomic, strong) NSString          * city;
@property (nonatomic, strong) NSString          * country;
@property (nonatomic, strong) NSString          * address;
@property (nonatomic, strong) NSString          * zipCode;
@property (nonatomic, strong) MKPointAnnotation * annotation;

// Custom constructor
-(id)initWithCity:(NSString*)ci country:(NSString*)co address:(NSString*)ad zipCode:(NSString*)zip location:(CLLocationCoordinate2D)loc;
-(NSString*)concatAddress;

@end
