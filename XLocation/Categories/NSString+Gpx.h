//
//  NSString+Gpx.h
//  XLocation
//
//  Created by Stefan Lage on 16/05/14.
//  Copyright (c) 2014 StefanLage. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Gpx)

+ (NSString *)generateGpxWithFilename:(NSString*) filename latitude:(NSNumber *)lat longitude:(NSNumber *)lng address:(NSString*)address city:(NSString*)city country:(NSString*)country zip:(NSString*)zipCode;

@end
