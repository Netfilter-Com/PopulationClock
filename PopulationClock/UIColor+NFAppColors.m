//
//  UIColor+NFAppColors.m
//  PopulationClock
//
//  Created by Fernando Lemos on 07/02/13.
//  Copyright (c) 2013 NetFilter. All rights reserved.
//

#import "UIColor+NFAppColors.h"

@implementation UIColor (NFAppColors)

+ (UIColor *)nf_orangeTextColor
{
    return [UIColor colorWithRed:0xfa/255.0 green:0xc4/255.0 blue:0x2a/255.0 alpha:1];
}

+ (UIColor *)nf_mapMaskColor
{
    return [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
}

+ (UIColor *)nf_birthBlinkColor
{
    return [UIColor colorWithRed:1 green:1 blue:0 alpha:0.3];
}

+ (UIColor *)nf_deathBlinkColor
{
    return [UIColor colorWithRed:1 green:0 blue:0 alpha:0.5];
}

+ (UIColor *)nf_birthAndDeathBlinkColor
{
    return [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
}

+ (UIColor *)nf_minGrowthColor
{
    return [UIColor colorWithRed:0xff/255.0 green:0x32/255.0 blue:0 alpha:1];
}

+ (UIColor *)nf_maxGrowthColor
{
    return [UIColor colorWithRed:0xff/255.0 green:0xe1/255.0 blue:0 alpha:1];
}

@end
