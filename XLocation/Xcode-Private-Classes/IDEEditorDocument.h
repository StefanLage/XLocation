//
//  IDEEditorDocument.h
//  LXLocation
//
//  Created by Stefan Lage on 16/05/14.
//  Copyright (c) 2014 Stefan Lage. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DVTFilePath;

@interface IDEEditorDocument : NSDocument

@property (retain) DVTFilePath *filePath;

@end
