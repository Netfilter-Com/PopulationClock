//
//  AppDelegate.m
//  PopulationClock
//
//  Created by Fernando Lemos on 14/12/12.
//  Copyright (c) 2012 NetFilter. All rights reserved.
//

#import "AppDelegate.h"
#import "InAppPurchaseManager.h"
#import "SimulationEngine.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Style all toolbar buttons
    [[UIBarButtonItem appearance] setBackgroundImage:[UIImage imageNamed:@"barBtn.png"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    NSDictionary *attrs = @{UITextAttributeTextColor : [UIColor colorWithRed:0xfa/255.0 green:0xc4/255.0 blue:0x2a/255.0 alpha:1]};
    [[UIBarButtonItem appearance] setTitleTextAttributes:attrs forState:UIControlStateNormal];
    
    // Pre-load the IAP products
    [InAppPurchaseManager sharedInstance];
    
    // Reset the simulation
    [[SimulationEngine sharedInstance] reset];
    
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Reset the simulation
    [[SimulationEngine sharedInstance] reset];
}

@end
