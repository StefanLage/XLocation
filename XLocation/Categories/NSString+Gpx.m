//
//  NSString+Gpx.m
//  XLocation
//
//  Created by Stefan Lage on 16/05/14.
//  Copyright (c) 2014 StefanLage. All rights reserved.
//

#import "NSString+Gpx.h"

@implementation NSString (Gpx)

+(NSString *)generateGpxWithFilename:(NSString*) filename latitude:(NSNumber *)lat longitude:(NSNumber *)lng address:(NSString *)address city:(NSString *)city country:(NSString *)country zip:(NSString *)zipCode{
    return [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>\n\
            <gpx\n\
            xmlns=\"http://www.topografix.com/GPX/1/1\"\n\
            xmlns:gpxx = \"http://www.garmin.com/xmlschemas/GpxExtensions/v3\"\n\
            xmlns:xsi = \"http://www.w3.org/2001/XMLSchema-instance\"\n\
            xsi:schemaLocation=\"http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd\n\
            http://www.garmin.com/xmlschemas/GpxExtensions/v3\n\
            http://www8.garmin.com/xmlschemas/GpxExtensions/v3/GpxExtensionsv3.xsd\"\n\
            version=\"1.1\"\n\
            creator=\"StefanLage\">\n\
                <wpt lat=\"%@\" lon=\"%@\">\n\
                    <time>%@</time>\n\
                    <name>%@</name>\n\
                    <extensions>\n\
                        <gpxx:WaypointExtension>\n\
                            <gpxx:Address>\n\
                                <gpxx:StreetAddress>%@</gpxx:StreetAddress>\n\
                                <gpxx:City>%@</gpxx:City>\n\
                                <gpxx:Country>%@</gpxx:Country>\n\
                                <gpxx:PostalCode>%@</gpxx:PostalCode>\n\
                            </gpxx:Address>\n\
                        </gpxx:WaypointExtension>\n\
                    </extensions>\n\
                </wpt>\n\
            </gpx>", lat, lng, [NSDate new], filename, address, city, country, zipCode];
}

@end
