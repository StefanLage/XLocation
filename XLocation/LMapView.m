//
//  LMapView.m
//  XLocation
//
//  Created by Stefan Lage on 17/05/14.
//  Copyright (c) 2014 StefanLage. All rights reserved.
//

#import "LMapView.h"

@interface LMapView ()

@property (nonatomic) MKCoordinateRegion bkRegion;

@end

@implementation LMapView

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        _bkRegion = self.region;
        _isEnable = YES;
    }
    return self;
}

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

-(void)resetRegion{
    self.region = self.bkRegion;
}

-(NSView*)hitTest:(NSPoint)aPoint{
    if(self.isEnable)
        return [super hitTest:aPoint];
    else
        return nil;
}

@end
