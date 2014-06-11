//
//  LWorskpaceController.m
//  XLocation
//
//  Created by Stefan Lage on 10/06/14.
//  Copyright (c) 2014 StefanLage. All rights reserved.
//

#import "LWorkspaceView.h"

static NSString * const defaultMessage = @"It seems you're using a Workspace.\nPlease select in which project you'd like to add the GPX:";
static NSString * const goBackTitle    = @"Go Back";
static NSString * const continueTitle  = @"Continue";

@interface LWorkspaceView ()

@property (nonatomic, strong) NSButton *back;
@property (nonatomic, strong) NSMatrix *projectsMatrix;

@end

@implementation LWorkspaceView

- (id)initWithFrame:(NSRect)frame workspace:(LWorkspace*)workspace
{
    self = [super initWithFrame:frame];
    if(self){
        _currentWorkspace = workspace;
        // Get the mid point of this view
        float x = frame.size.width / 2;
        float y = frame.size.height / 2;
        NSPoint midPoint = NSMakePoint(x, y);
        
        NSTextField *txtField = [[NSTextField alloc] initWithFrame:NSMakeRect((x - 340/2), y + 60, 340, 60)];
        [txtField setStringValue:defaultMessage];
        [txtField setEditable:NO];
        [txtField setBordered:NO];
        [txtField setBackgroundColor:[NSColor clearColor]];
        [self addSubview:txtField];
        
        [self setButtons:midPoint];
        [self setMatrix:midPoint];
    }
    return self;
}

-(void)setButtons:(NSPoint)midPoint{
    
    float x = midPoint.x - 115;
    float y = midPoint.y - 125.0;
    
    _back  = [[NSButton alloc] initWithFrame:NSMakeRect(x, y, 115, 32)];
    [_back setTitle:goBackTitle];
    [_back setTarget:self];
    [_back setAction:@selector(back:)];
    [_back setButtonType:NSMomentaryLightButton];
    [_back setBezelStyle:NSRoundedBezelStyle];
    
    _continueBtn  = [[NSButton alloc] initWithFrame:NSMakeRect(x+125, y, 115, 32)];
    [_continueBtn setTitle:continueTitle];
    [_continueBtn setTarget:self];
    [_continueBtn setAction:@selector(projectSelected:)];
    [_continueBtn setButtonType:NSMomentaryLightButton];
    [_continueBtn setBezelStyle:NSRoundedBezelStyle];
    [_continueBtn setKeyEquivalent:@"\r"];
    
    [self addSubview:_back];
    [self addSubview:_continueBtn];
}

// Create a matrix containing all projects name
-(void) setMatrix:(NSPoint)midPoint{
    // Create a long title sample to be sure it could be contain a long name
    NSMutableString *title  = [[NSMutableString alloc] initWithString:@" "];
    for (int i              = 0; i < 200; i++)
        [title appendString:@" "];
    // Set a prototype of radio button
    NSButtonCell *prototype = [[NSButtonCell alloc] init];
    [prototype setTitle:title];
    [prototype setButtonType:NSRadioButton];
    
    float x = midPoint.x - 125.0/2;
    float y = midPoint.y - 125.0/2;
    NSRect matrixRect       = NSMakeRect(x, y, 200.0, 125.0);
    NSInteger rows          = self.currentWorkspace.projects.count;
    self.projectsMatrix     = [[NSMatrix alloc] initWithFrame:matrixRect
                                                         mode:NSRadioModeMatrix
                                                    prototype:(NSCell *)prototype
                                                 numberOfRows:rows
                                              numberOfColumns:1];
    
    [self addSubview:self.projectsMatrix];
    NSArray *cellArray = [self.projectsMatrix cells];
    for(int i = 0; i < rows ; i++){
        NSDictionary *project = [self.currentWorkspace.projects objectAtIndex:i];
        [[cellArray objectAtIndex:i] setTitle:[project objectForKey:@"name"]];
    }
}

#pragma mark - Handlers

-(void)back:(id)sender{
    if([self.delegate respondsToSelector:@selector(goBack:)])
        [self.delegate goBack:self];
}

-(void)projectSelected:(id)sender{
    if([self.delegate respondsToSelector:@selector(projectSelected:index:)])
        [self.delegate projectSelected:self index:[self.projectsMatrix selectedRow]];
}

@end
