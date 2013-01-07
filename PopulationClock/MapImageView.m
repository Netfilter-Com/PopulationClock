//
//  MapImageView.m
//  PopulationClock
//
//  Created by Fernando Lemos on 12/12/12.
//  Copyright (c) 2012 NetFilter. All rights reserved.
//

#import "CountryCoordinates.h"
#import "MapImageView.h"

#define TAG_BLINK_LAYER 1
#define TAG_ICON_LAYER 2
#define TAG_MASK_LAYER 3

@implementation MapImageView {
    CountryCoordinates *_coordinates;
    NSMutableDictionary *_countryColors;
    UIImageView *_selectedMask;
    NSMutableData *_bitmap;
    CGSize _bitmapSize;
    CGFloat _bitmapScale;
    dispatch_queue_t _backgroundQueue;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Load the coordinates
        _coordinates = [[CountryCoordinates alloc] init];
        
        // Create a dictionary for reverse lookup
        NSString *path = [[NSBundle mainBundle] pathForResource:@"colormap" ofType:@"plist"];
        NSDictionary *colorCountries = [NSDictionary dictionaryWithContentsOfFile:path];
        _countryColors = [[NSMutableDictionary alloc] initWithCapacity:colorCountries.count];
        for (NSString *key in colorCountries)
            _countryColors[colorCountries[key]] = key;
        
        // Load the image
        UIImage *image = [UIImage imageNamed:@"colormap"];
        _bitmapSize = image.size;
        
        // Correct the bitmap size according to the scale
        _bitmapScale = image.scale;
        _bitmapSize.width *= _bitmapScale;
        _bitmapSize.height *= _bitmapScale;
        
        // Create the context
        _bitmap = [[NSMutableData alloc] initWithLength:_bitmapSize.width * _bitmapSize.height];
        CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceGray();
        CGContextRef context = CGBitmapContextCreate(_bitmap.mutableBytes, _bitmapSize.width, _bitmapSize.height, 8, _bitmapSize.width, colorspace, 0);
        CGColorSpaceRelease(colorspace);
        
        // Draw the image onto the bitmap
        CGContextDrawImage(context, CGRectMake(0, 0, _bitmapSize.width, _bitmapSize.height), image.CGImage);
        CGContextRelease(context);
        
        // Create the background queue
        _backgroundQueue = dispatch_queue_create("br.com.netfilter.MapImageViewBackgroundQueue", NULL);
    }
    return self;
}

- (void)dealloc {
    // Release the background queue
    if (_backgroundQueue)
        dispatch_release(_backgroundQueue);
}

- (uint32_t)RGBAColorValueForColor:(UIColor *)color {
    CGFloat r, g, b, a;
    BOOL res = [color getRed:&r green:&g blue:&b alpha:&a];
    assert(res);
    return ((int)(r * 0xff) << 24) | ((int)(g * 0xff) << 16) | ((int)(b * 0xff) << 8) | (int)(a * 0xff);
}

- (UIImage *)imageFromBitmapData:(void *)data {
    // Create the context
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(data, _bitmapSize.width, _bitmapSize.height, 8, _bitmapSize.width * 4, colorspace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Host);
    CGColorSpaceRelease(colorspace);
    
    // Create and return an image from this context
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage *image = [UIImage imageWithCGImage:imageRef scale:_bitmapScale orientation:UIImageOrientationUp];
    CGImageRelease(imageRef);
    CGContextRelease(context);
    return image;
}

- (UIImage *)tintedImageForCountries:(NSArray *)countryCodes tintColor:(UIColor *)color {
    // Get a list of color values
    NSMutableArray *colors = [NSMutableArray arrayWithCapacity:countryCodes.count];
    for (NSString *countryCode in countryCodes) {
        NSString *colorStr = _countryColors[countryCode];
        if (colorStr)
            [colors addObject:@(colorStr.integerValue)];
    }
    
    // Create a new bitmap
    NSMutableData *newBitmap = [NSMutableData dataWithLength:_bitmapSize.width * _bitmapSize.height * 4];
    
    // Turn the replacement color into an RGBA color value
    uint32_t replacement = [self RGBAColorValueForColor:color];
    
    while (colors.count) {
        // Get the first color into the four variables
        uint8_t c1, c2, c3, c4;
        c1 = c2 = c3 = c4 = [colors[0] integerValue];
        [colors removeObjectAtIndex:0];
        
        // Fetch the remaining colors
        uint8_t *cp[] = { &c2, &c3, &c4 };
        for (int i = 0; i < 3 && colors.count; ++i) {
            *(cp[i]) = [colors[0] integerValue];
            [colors removeObjectAtIndex:0];
        }
        
        // Perform the replacement
        uint8_t *inptr = (uint8_t *)_bitmap.bytes;
        uint32_t *outptr = (uint32_t *)newBitmap.mutableBytes;
        int totalSize = _bitmapSize.width * _bitmapSize.height;
        for (int i = 0; i < totalSize; ++i, ++outptr) {
            uint8_t p = *inptr++;
            if (p == c1 || p == c2 || p == c3 || p == c4)
                *outptr = replacement;
        }
    }
    
    // Generate and return the image
    return [self imageFromBitmapData:newBitmap.mutableBytes];
}

- (void)asyncCreateTintedImageViewForCountries:(NSArray *)countryCodes color:(UIColor *)color block:(void (^)(UIImageView *imageView))block {
    dispatch_async(_backgroundQueue, ^{
        // Create the image
        UIImage *image = [self tintedImageForCountries:countryCodes tintColor:color];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Create the image view
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            imageView.frame = self.bounds;
            imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            
            // Invoke the completion block
            block(imageView);
        });
    });
}

- (void)blinkCountries:(NSArray *)countryCodes color:(UIColor *)color {
    // Create the image view
    [self asyncCreateTintedImageViewForCountries:countryCodes color:color block:^(UIImageView *imageView) {
        // Add it on top of the map
        imageView.tag = TAG_BLINK_LAYER;
        [self insertSubview:imageView atIndex:0];
        
        // Extract the alpha component
        CGFloat colorAlpha;
        [color getRed:NULL green:NULL blue:NULL alpha:&colorAlpha];
        
        // Animate the image view alpha
        imageView.alpha = 0;
        [UIView animateWithDuration:0.2 animations:^{
            imageView.alpha = colorAlpha;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.4 delay:0.3 options:UIViewAnimationOptionCurveEaseIn animations:^{
                imageView.alpha = 0;
            } completion:^(BOOL finished) {
                [imageView removeFromSuperview];
            }];
        }];
    }];
}

- (UIImage *)maskWithSelectedCountry:(NSString *)countryCode maskColor:(UIColor *)color {
    // Create a new bitmap
    NSMutableData *newBitmap = [NSMutableData dataWithLength:_bitmapSize.width * _bitmapSize.height * 4];
    
    // Turn the replacement color into an RGBA color value
    uint32_t replacement = [self RGBAColorValueForColor:color];
    
    // Fill the bitmap with the replacement color
    assert(sizeof(int) == sizeof(uint32_t));
    memset(newBitmap.mutableBytes, replacement, newBitmap.length);
    
    NSString *colorStr = _countryColors[countryCode];
    if (colorStr) {
        // Get the color value for the selected country
        uint8_t match = colorStr.integerValue;
        
        // Perform the replacement
        uint8_t *inptr = (uint8_t *)_bitmap.bytes;
        uint32_t *outptr = (uint32_t *)newBitmap.mutableBytes;
        int totalSize = _bitmapSize.width * _bitmapSize.height;
        for (int i = 0; i < totalSize; ++i, ++outptr) {
            if (*inptr++ == match)
                *outptr = 0;
        }
    }
    
    // Generate and return the image
    return [self imageFromBitmapData:newBitmap.mutableBytes];
}

- (void)selectCountry:(NSString *)countryCode maskColor:(UIColor *)color {
    dispatch_async(_backgroundQueue, ^{
        // Create the mask
        UIImage *image = [self maskWithSelectedCountry:countryCode maskColor:color];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Create the image view
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            imageView.tag = TAG_MASK_LAYER;
            imageView.frame = self.bounds;
            imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            
            // Remove the current mask
            BOOL hadPreviousSelection = _selectedMask != nil;
            [_selectedMask removeFromSuperview];
            _selectedMask = imageView;
            
            // Add the new one above all others
            [self addSubview:imageView];
            
            // Animate it unless we're replacing the previous mask
            if (!hadPreviousSelection) {
                _selectedMask.alpha = 0;
                [UIView animateWithDuration:0.3 animations:^{
                    _selectedMask.alpha = 1;
                }];
            }
        });
    });
}

- (void)deselectCurrentCountry {
    // Animate the other countries being unmasked
    if (_selectedMask) {
        UIImageView *mask = _selectedMask;
        _selectedMask = nil;
        [UIView animateWithDuration:0.3 animations:^{
            mask.alpha = 0;
        } completion:^(BOOL finished) {
            [mask removeFromSuperview];
        }];
    }
}

- (void)flashIcon:(UIImage *)icon atCountry:(NSString *)countryCode {
    // Get the relative coordinates for this country
    CGPoint coords = [_coordinates relativeCoordinatesForCountry:countryCode];
    if (CGPointEqualToPoint(coords, CountryCoordinatesNotFound))
        return;
    
    // Create an image view
    UIImageView *imageView = [[UIImageView alloc] initWithImage:icon];
    imageView.tag = TAG_ICON_LAYER;
    
    // Insert it between the blink layer and the mask layer
    int index = 0;
    for (UIView *subview in self.subviews) {
        if (subview.tag > TAG_BLINK_LAYER)
            break;
        ++index;
    }
    [self insertSubview:imageView atIndex:index];
    
    // Get absolute coordinates and apply them to the image view
    coords.x *= self.bounds.size.width;
    coords.y *= self.bounds.size.height;
    imageView.center = coords;
    
    // Animate it
    imageView.alpha = 0;
    [UIView animateWithDuration:0.25 delay:0 options:0 animations:^{
        imageView.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.25 delay:0.4 options:0 animations:^{
            imageView.alpha = 0;
        } completion:^(BOOL finished) {
            [imageView removeFromSuperview];
        }];
    }];
}

@end
