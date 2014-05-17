//
//  IDEWorkspace.h
//  LXLocation
//
//  Created by Stefan Lage on 16/05/14.
//  Copyright (c) 2014 Stefan Lage. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IDEIndex;
@class DVTFilePath;

@interface IDEWorkspace : NSObject

@property (retain) IDEIndex *index;
@property (readonly) DVTFilePath *representingFilePath;

- (void)_updateIndexableFiles:(id)arg1;

@end
