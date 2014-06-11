//
//  LXLocation.h
//  LXLocation
//
//  Created by Stefan Lage on 16/05/14.
//  Copyright (c) 2014 StefanLage. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <MapKit/MapKit.h>
#import "LWorkspaceView.h"

@interface LXLocation : NSObject <LWorskpaceViewDelegate>

- (IBAction)cancel:(id)sender;
- (IBAction)generateFromMap:(id)sender;
- (IBAction)generateFromAddress:(id)sender;

@end