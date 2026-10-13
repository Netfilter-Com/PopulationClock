//
//  UIViewController+NFSharing.m
//  PopulationClock
//
//  Created by Fernando Lemos on 07/02/13.
//  Copyright (c) 2013 NetFilter. All rights reserved.
//

#import "UIViewController+NFSharing.h"
#import "DataManager.h"
#import "SimulationEngine.h"
#import "UIColor+NFAppColors.h"
#import "globals.h"

static NSString * const kGameShortURL = @"http://bit.ly/populationclock";

@implementation UIViewController (NFSharing)

// A 4:5 image with the flag, the name and the population of the selected
// country (or the world), read from the simulation at the moment of sharing.
// Returns nil when there is nothing to show yet.
- (UIImage *)nf_shareCardImage
{
    NSString *selection = [[NSUserDefaults standardUserDefaults] stringForKey:SelectedCountryKey] ?: @"world";
    NSDictionary *info = [DataManager sharedDataManager].countryData[selection];
    NSNumber *population = [SimulationEngine sharedInstance].populationPerCountry[selection];
    if (!info || !population)
        return nil;

    BOOL isWorld = [selection isEqualToString:@"world"];
    UIImage *flag = isWorld
        ? [UIImage imageNamed:@"globeVertical"]
        : [UIImage imageNamed:[NSString stringWithFormat:@"country_flag_%@", selection]];

    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    NSString *populationText = [formatter stringFromNumber:@(population.longLongValue)];
    NSString *label = [[NSLocalizedString(@"POPULATION: ", @"") stringByTrimmingCharactersInSet:
                        [NSCharacterSet characterSetWithCharactersInString:@": "]] uppercaseString];
    NSString *appName = [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:(NSString *)kCFBundleNameKey]
        ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleNameKey];

    CGSize size = CGSizeMake(1080, 1350);
    UIGraphicsImageRendererFormat *format = [UIGraphicsImageRendererFormat preferredFormat];
    format.scale = 1;
    format.opaque = YES;
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:size format:format];

    return [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
        CGContextRef ctx = context.CGContext;

        // Background
        CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
        CGFloat components[] = { 0.10, 0.10, 0.10, 1,   0.02, 0.02, 0.02, 1 };
        CGGradientRef gradient = CGGradientCreateWithColorComponents(space, components, NULL, 2);
        CGContextDrawLinearGradient(ctx, gradient, CGPointZero, CGPointMake(0, size.height), 0);
        CGGradientRelease(gradient);
        CGColorSpaceRelease(space);

        NSMutableParagraphStyle *centered = [[NSMutableParagraphStyle alloc] init];
        centered.alignment = NSTextAlignmentCenter;
        centered.lineBreakMode = NSLineBreakByTruncatingTail;
        void (^draw)(NSString *, UIFont *, UIColor *, CGFloat) = ^(NSString *text, UIFont *font, UIColor *color, CGFloat y) {
            CGRect rect = CGRectMake(60, y, size.width - 120, ceil(font.lineHeight));
            [text drawInRect:rect withAttributes:@{
                NSFontAttributeName : font,
                NSForegroundColorAttributeName : color,
                NSParagraphStyleAttributeName : centered
            }];
        };

        // Flag (or globe), fitted in a box with a white border
        if (flag) {
            CGSize box = CGSizeMake(620, 400);
            CGFloat scale = MIN(box.width / flag.size.width, box.height / flag.size.height);
            CGSize fitted = CGSizeMake(round(flag.size.width * scale), round(flag.size.height * scale));
            CGRect frame = CGRectMake((size.width - fitted.width) / 2, 120 + (box.height - fitted.height) / 2,
                                      fitted.width, fitted.height);
            if (!isWorld) {
                [[UIColor whiteColor] setFill];
                UIRectFill(CGRectInset(frame, -6, -6));
            }
            [flag drawInRect:frame];
        }

        draw(info[@"name"], [UIFont systemFontOfSize:78 weight:UIFontWeightBold], [UIColor nf_orangeTextColor], 600);
        draw(label, [UIFont systemFontOfSize:40 weight:UIFontWeightSemibold], [UIColor colorWithWhite:0.7 alpha:1], 740);
        draw(populationText, [UIFont monospacedDigitSystemFontOfSize:112 weight:UIFontWeightBold], [UIColor whiteColor], 800);

        // Footer
        draw(appName, [UIFont systemFontOfSize:44 weight:UIFontWeightSemibold], [UIColor nf_orangeTextColor], 1170);
        draw(kGameShortURL, [UIFont systemFontOfSize:32], [UIColor colorWithWhite:0.7 alpha:1], 1235);
    }];
}

- (void)nf_presentShareViewControllerAnimated:(BOOL)animated
{
    [self nf_presentShareViewControllerFromSender:nil animated:animated];
}

- (void)nf_presentShareViewControllerFromSender:(id)sender animated:(BOOL)animated
{
    // Compose the message
    NSString *message = NSLocalizedString(@"I loved %@, awesome app for iPad! %@", @"");
    NSString *gameName = [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:(NSString *)kCFBundleNameKey];
    if (!gameName)
        gameName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
    message = [NSString stringWithFormat:message, gameName, kGameShortURL];
    
    // Use UIActivityViewController for sharing: the text, plus a card with the
    // flag and the population when there is one. A nil item raises an
    // exception, so the card is only added when it exists
    NSMutableArray *items = [NSMutableArray arrayWithObject:message];
    UIImage *card = [self nf_shareCardImage];
    if (card)
        [items addObject:card];
    NSArray *exclude = @[
        UIActivityTypeAssignToContact,
        UIActivityTypePrint,
        UIActivityTypeCopyToPasteboard
    ];
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    controller.excludedActivityTypes = exclude;
    
    // On iPad the sheet is a popover, which raises an exception unless it has
    // a source
    UIPopoverPresentationController *popover = controller.popoverPresentationController;
    if (popover) {
        if ([sender isKindOfClass:[UIBarButtonItem class]]) {
            popover.barButtonItem = sender;
        }
        else if ([sender isKindOfClass:[UIView class]]) {
            UIView *source = sender;
            popover.sourceView = source;
            popover.sourceRect = source.bounds;
        }
        else {
            // No idea what was touched: point at the middle of the screen
            popover.sourceView = self.view;
            popover.sourceRect = CGRectMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds), 1, 1);
            popover.permittedArrowDirections = 0;
        }
    }
    
    [self presentViewController:controller animated:animated completion:nil];
}

@end
