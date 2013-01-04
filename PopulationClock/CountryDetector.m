//
//  CountryDetector.m
//  PopulationClock
//
//  Created by Fernando Lemos on 13/12/12.
//  Copyright (c) 2012 NetFilter. All rights reserved.
//

#import "CountryDetector.h"

@implementation CountryDetector {
    NSDictionary *_index;
    NSMutableData *_bitmap;
    CGSize _bitmapSize;
}

- (id)init {
    self = [super init];
    if (self) {
        // Load the index
        _index = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"colormap" ofType:@"plist"]];
        
        // Load the image
        UIImage *image = [UIImage imageNamed:@"colormap"];
        _bitmapSize = image.size;
        
        // Correct the bitmap size according to the scale
        _bitmapSize.width *= image.scale;
        _bitmapSize.height *= image.scale;
        
        // Create the context
        _bitmap = [[NSMutableData alloc] initWithLength:_bitmapSize.width * _bitmapSize.height];
        CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceGray();
        CGContextRef context = CGBitmapContextCreate(_bitmap.mutableBytes, _bitmapSize.width, _bitmapSize.height, 8, _bitmapSize.width, colorspace, 0);
        CGColorSpaceRelease(colorspace);
        
        // Draw the image onto the bitmap
        CGContextDrawImage(context, CGRectMake(0, 0, _bitmapSize.width, _bitmapSize.height), image.CGImage);
        CGContextRelease(context);
    }
    return self;
}

- (NSString *)countryAtNormalizedPoint:(CGPoint)point {
    // The point must be within bounds
    assert(point.x >= 0 && point.x <= 1 && point.y >= 0 && point.y <= 1);
    
    // Adjust the point to the bitmap size
    point = CGPointMake(point.x * _bitmapSize.width, point.y * _bitmapSize.height);
    
    // Get the color at that location
    int color = ((uint8_t *)_bitmap.bytes)[(int)_bitmapSize.width * (int)point.y + (int)point.x];
    
    // Look for the color in the index and return the country
    NSString *colorStr = [NSString stringWithFormat:@"%d", color];
    return _index[colorStr];
}

@end
