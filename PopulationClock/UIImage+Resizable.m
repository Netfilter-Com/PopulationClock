//
//  UIImage+Resizable.m
//  PopulationClock
//
//  Created by Fernando Lemos on 03/01/13.
//  Copyright (c) 2013 NetFilter. All rights reserved.
//

#import "UIImage+Resizable.h"

@implementation UIImage (Resizable)

- (UIImage *)resizedImageWithSize:(CGSize)size {
    UIGraphicsBeginImageContextWithOptions(size, NO, self.scale);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
