//
//  UIViewController+NFSharing.m
//  PopulationClock
//
//  Created by Fernando Lemos on 07/02/13.
//  Copyright (c) 2013 NetFilter. All rights reserved.
//

#import <Twitter/Twitter.h>

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
    
    // If we have the activity view controller, use it
    if (NSClassFromString(@"UIActivityViewController")) {
        NSArray *items = @[ message, [UIImage imageNamed:@"Icon-72"] ];
        NSArray *exclude = @[
            UIActivityTypeAssignToContact,
            UIActivityTypeSaveToCameraRoll,
            UIActivityTypePrint,
            UIActivityTypeCopyToPasteboard
        ];
        UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
        controller.excludedActivityTypes = exclude;
        [self presentViewController:controller animated:animated completion:Nil];
        return;
    }
    
    // No deal, this shouldn't normally happen as we target iOS 6
    assert(NO);
}

@end
