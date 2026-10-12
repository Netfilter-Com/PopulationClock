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
    
    // Use UIActivityViewController for sharing. Only the text is shared: the
    // icon this used to add (Icon-72) is not in the bundle any more, and a nil
    // item raises an exception
    NSArray *items = @[ message ];
    NSArray *exclude = @[
        UIActivityTypeAssignToContact,
        UIActivityTypeSaveToCameraRoll,
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
