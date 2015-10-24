//
//  LWorskpaceController.h
//  XLocation
//
//  Created by Stefan Lage on 10/06/14.
//  Copyright (c) 2014 StefanLage. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XLWorkspace.h"
#import "RMBlurredView.h"


@class XLWorkspaceView;

@protocol XLWorskpaceViewDelegate <NSObject>

-(void)goBack:(XLWorkspaceView *)view;
-(void)projectSelected:(XLWorkspaceView *)view index:(NSInteger)index;

@end

@interface XLWorkspaceView : RMBlurredView

@property (nonatomic, weak) id<XLWorskpaceViewDelegate> delegate;
@property (nonatomic, strong) XLWorkspace *currentWorkspace;
@property (nonatomic, strong) NSButton *continueBtn;

- (id)initWithFrame:(NSRect)frame workspace:(XLWorkspace*)workspace;

@end
