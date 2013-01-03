//
//  AppDelegate.m
//  PopulationClock
//
//  Created by Fernando Lemos on 14/12/12.
//  Copyright (c) 2012 NetFilter. All rights reserved.
//

#import "AppDelegate.h"
#import "InAppPurchaseManager.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Pre-load the IAP products
    [InAppPurchaseManager sharedInstance];
    
    return YES;
}

@end
