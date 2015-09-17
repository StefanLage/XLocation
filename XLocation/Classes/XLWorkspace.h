//
//  LWorkspace.h
//  XLocation
//
//  Created by Stefan Lage on 10/06/14.
//  Copyright (c) 2014 StefanLage. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XLWorkspace : NSObject <NSXMLParserDelegate>

// Get all projects contains in a workspace
//
// Dictionnary :
//  name: projectName
//  filename: filename.extension
//  location : path to the project
//
@property (strong, nonatomic) NSMutableArray *projects;
@property (strong, nonatomic) NSString *currentWorkspacePath;

-(id)initWithUrl:(NSString*)url currentPath:(NSString*)path;

@end
