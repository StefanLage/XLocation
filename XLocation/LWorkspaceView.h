//
//  LWorskpaceController.h
//  XLocation
//
//  Created by Stefan Lage on 10/06/14.
//  Copyright (c) 2014 StefanLage. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LWorkspace.h"
#import "RMBlurredView.h"


@class LWorkspaceView;

@protocol LWorskpaceViewDelegate <NSObject>

-(void)goBack:(LWorkspaceView *)view;
-(void)projectSelected:(LWorkspaceView *)view index:(NSInteger)index;

@end

@interface LWorkspaceView : RMBlurredView

@property (nonatomic, weak) id<LWorskpaceViewDelegate> delegate;
@property (nonatomic, strong) LWorkspace *currentWorkspace;
@property (nonatomic, strong) NSButton *continueBtn;

- (id)initWithFrame:(NSRect)frame workspace:(LWorkspace*)workspace;

@end
