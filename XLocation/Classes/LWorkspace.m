//
//  LWorkspace.m
//  XLocation
//
//  Created by Stefan Lage on 10/06/14.
//  Copyright (c) 2014 StefanLage. All rights reserved.
//

#import "LWorkspace.h"

static NSString * const workspaceContent = @"contents.xcworkspacedata";
static NSString * const fileRefElement   = @"FileRef";
static NSString * const locationKey      = @"location";
static NSString * const locationNoise    = @"group:";

@implementation LWorkspace

-(id)initWithUrl:(NSString*)url currentPath:(NSString*)path{
    self = [super init];
    if(self){
        _currentWorkspacePath   = path;
        NSString *worskpacePath = [NSString stringWithFormat:@"%@/%@", url, workspaceContent];
        NSData *xmlData         = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:worskpacePath]];
        if(xmlData == nil)
            // Can't read the file -> return nil
            return nil;
        NSXMLParser* xmlParser  = [[NSXMLParser alloc] initWithData:xmlData];
        xmlParser.delegate      = self;
        [xmlParser parse];
    }
    return self;
}

// Check if the path has the right format : /Users/....
-(NSString*)checkPath:(NSString*)path{
    NSMutableString *newpath = [[NSMutableString alloc] initWithString:path];
    if([newpath characterAtIndex:0] != '/')
        [newpath insertString:self.currentWorkspacePath
                      atIndex:0];
    return newpath;
}

#pragma mark - NSXMLParser

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    self.projects = [NSMutableArray new];
}

-(void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    // Project found ?
    if([elementName isEqualToString:fileRefElement])
    {
        NSString *location    = [[attributeDict objectForKey:locationKey] stringByReplacingOccurrencesOfString:locationNoise
                                                                                                    withString:@""];
        // correct the path if needed
        location              = [self checkPath:location];
        NSString* projectName = [[location lastPathComponent] stringByDeletingPathExtension];
        NSDictionary *dic     = @{
                                  @"name": projectName,
                                  @"filename": [location lastPathComponent],
                                  @"location": location
                                  };
        // Add project infos
        [self.projects addObject:dic];
    }
}

@end
