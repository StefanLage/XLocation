//
//  XLocation.h
//  XLocation
//
//  Created by Stefan Lage on 17/09/15.
//  Copyright (c) 2015 Stefan Lage. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "XLWorkspaceView.h"

@class XLocation;

static XLocation *sharedPlugin;

@interface XLocation : NSObject <XLWorskpaceViewDelegate>

@property (nonatomic, strong, readonly) NSBundle* bundle;

+ (instancetype)sharedPlugin;
- (id)initWithBundle:(NSBundle *)plugin;
- (IBAction)cancel:(id)sender;
- (IBAction)generateFromMap:(id)sender;
- (IBAction)generateFromAddress:(id)sender;

@end