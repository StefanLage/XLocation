//
//  LXLocation.h
//  LXLocation
//
//  Created by Stefan Lage on 16/05/14.
//  Copyright (c) 2014 StefanLage. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <MapKit/MapKit.h>

@interface LXLocation : NSObject

- (IBAction)cancel:(id)sender;
- (IBAction)generateFromMap:(id)sender;
- (IBAction)generateFromAddress:(id)sender;

@end