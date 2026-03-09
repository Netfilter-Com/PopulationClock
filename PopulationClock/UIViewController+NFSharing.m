//
//  UIViewController+NFSharing.m
//  PopulationClock
//
//  Created by Fernando Lemos on 07/02/13.
//  Copyright (c) 2013 NetFilter. All rights reserved.
//

#import "UIViewController+NFSharing.h"

static NSString * const kGameShortURL = @"http://bit.ly/populationclock";

@implementation UIViewController (NFSharing)

- (void)nf_presentShareViewControllerAnimated:(BOOL)animated
{
    // Compose the message
    NSString *message = NSLocalizedString(@"I loved %@, awesome app for iPad! %@", @"");
    NSString *gameName = [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:(NSString *)kCFBundleNameKey];
    if (!gameName)
        gameName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
    message = [NSString stringWithFormat:message, gameName, kGameShortURL];
    
    // Use UIActivityViewController for sharing
    NSArray *items = @[ message, [UIImage imageNamed:@"Icon-72"] ];
    NSArray *exclude = @[
        UIActivityTypeAssignToContact,
        UIActivityTypeSaveToCameraRoll,
        UIActivityTypePrint,
        UIActivityTypeCopyToPasteboard
    ];
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    controller.excludedActivityTypes = exclude;
    [self presentViewController:controller animated:animated completion:nil];
}

@end
