//
//  LMapView.m
//  XLocation
//
//  Created by Stefan Lage on 17/05/14.
//  Copyright (c) 2014 StefanLage. All rights reserved.
//

#import "LMapView.h"

@implementation LMapView

/*
 * Handle right click on the map
 */
- (void) rightMouseDown:(NSEvent*) event{
    // Get point in the current main Window
    NSPoint selfPoint               = [self convertPoint:event.locationInWindow fromView:nil];
    // Adapt it to the mapView
    CLLocationCoordinate2D locCoord = [self convertPoint:selfPoint toCoordinateFromView:self];
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:locCoord.latitude longitude:locCoord.longitude];
    // Broadcast the location to find
    [[NSNotificationCenter defaultCenter] postNotificationName:@"findLocationFromPointNotification"
                                                        object:loc];
}

@end
