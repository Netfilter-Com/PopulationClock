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
