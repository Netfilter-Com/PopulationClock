//
//  AppDelegate.m
//  PopulationClock
//
//  Created by Fernando Lemos on 14/12/12.
//  Copyright (c) 2012 NetFilter. All rights reserved.
//

#import "AppDelegate.h"
#import "Appirater.h"
#import "InAppPurchaseManager.h"
#import "NFCarouselViewController.h"
#import "SimulationEngine.h"
#import "UIColor+NFAppColors.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Style all toolbar buttons
    UIImage *barButtonImage = [UIImage imageNamed:@"barBtn"];
    UIEdgeInsets insets = UIEdgeInsetsMake(0, (barButtonImage.size.width - 1) / 2, 0, (barButtonImage.size.width - 1) / 2);
    barButtonImage = [barButtonImage resizableImageWithCapInsets:insets];
    [[UIBarButtonItem appearance] setBackgroundImage:barButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    NSDictionary *attrs = @{UITextAttributeTextColor : [UIColor nf_orangeTextColor]};
    [[UIBarButtonItem appearance] setTitleTextAttributes:attrs forState:UIControlStateNormal];
    
    // On the iPhone, we need to manually create the storyboard
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone" bundle:nil];
        NFCarouselViewController *carousel = [[NFCarouselViewController alloc] initWithViewControllers:@[
            [storyboard instantiateViewControllerWithIdentifier:@"countryInfoViewController"],
            [storyboard instantiateInitialViewController],
            [storyboard instantiateViewControllerWithIdentifier:@"countryListViewController"]
        ]];
        self.window.rootViewController = carousel;
        [self.window makeKeyAndVisible];
    }
    
    // Pre-load the IAP products
    [InAppPurchaseManager sharedInstance];
    
    // Reset the simulation
    [[SimulationEngine sharedInstance] reset];
    
    // Set up appirater
    [Appirater setAppId:@"590689957"];
    [Appirater setDaysUntilPrompt:5];
    [Appirater setUsesUntilPrompt:7];
    [Appirater setTimeBeforeReminding:20];
    [Appirater appEnteredForeground:YES];
    
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Reset the simulation
    [[SimulationEngine sharedInstance] reset];
}

@end
