//
//  DVTFilePath.h
//  LXLocation
//
//  Created by Stefan Lage on 16/05/14.
//  Copyright (c) 2014 Stefan Lage. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DVTFilePath : NSObject

@property (readonly) NSString *fileName;
@property (readonly) NSURL *fileURL;
@property (readonly) NSArray *pathComponents;
@property (readonly) NSString *pathString;

@end
