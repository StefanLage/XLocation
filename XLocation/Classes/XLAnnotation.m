//
//  LAnnotation.m
//  XLocation
//
//  Created by Stefan Lage on 17/05/14.
//  Copyright (c) 2014 StefanLage. All rights reserved.
//

#import "XLAnnotation.h"

@implementation XLAnnotation

-(id)initWithCity:(NSString*)ci country:(NSString*)co address:(NSString*)ad zipCode:(NSString*)zip location:(CLLocationCoordinate2D)loc{
    self = [super init];
    if(self){
        _city                  = ci;
        _country               = co;
        _address               = ad;
        _zipCode               = zip;
        _annotation            = [[MKPointAnnotation alloc] init];
        _annotation.coordinate = loc;
        _annotation.title      = [NSString stringWithFormat:@"%@\n%@", _city, _country];
    }
    return self;
}

/*
 * Concat all properties to get a complete address
 */
-(NSString*)concatAddress{
    NSMutableString *result = [[NSMutableString alloc] init];
    if(![self.address isEqualToString:@""])
        [result appendString:[NSString stringWithFormat:@"%@, ", self.address]];
    if(![self.zipCode isEqualToString:@""])
        [result appendString:[NSString stringWithFormat:@"%@, ", self.zipCode]];
    if(![self.city isEqualToString:@""])
        [result appendString:[NSString stringWithFormat:@"%@, ", self.city]];
    if(![self.country isEqualToString:@""])
        [result appendString:[NSString stringWithFormat:@"%@", self.country]];
    return result;
}

@end
