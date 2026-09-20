//
//  AppDelegate.m
//  PopulationClock
//
//  Created by Fernando Lemos on 14/12/12.
//  Copyright (c) 2012 NetFilter. All rights reserved.
//

#import <StoreKit/StoreKit.h>

#import "AppDelegate.h"
#import "InAppPurchaseManager.h"
#import "NFCarouselViewController.h"
#import "SimulationEngine.h"
#import "UIColor+NFAppColors.h"

#define REVIEW_PROMPT_FIRST_USE_DATE_KEY @"ReviewPromptFirstUseDate"
#define REVIEW_PROMPT_USE_COUNT_KEY @"ReviewPromptUseCount"
#define REVIEW_PROMPT_MIN_DAYS 5
#define REVIEW_PROMPT_MIN_USES 7

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Style all toolbar buttons
    NSDictionary *attrs = @{NSForegroundColorAttributeName : [UIColor nf_orangeTextColor]};
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
    
    // Pre-load the IAP products and become a transaction observer
    [InAppPurchaseManager sharedInstance];
    
    // Reset the simulation
    [[SimulationEngine sharedInstance] reset];

    // Ask for a review once the user has had enough time with the app
    [self requestReviewIfAppropriate];

    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Reset the simulation
    [[SimulationEngine sharedInstance] reset];
}

- (void)requestReviewIfAppropriate {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSDate *firstUseDate = [defaults objectForKey:REVIEW_PROMPT_FIRST_USE_DATE_KEY];
    if (!firstUseDate) {
        firstUseDate = [NSDate date];
        [defaults setObject:firstUseDate forKey:REVIEW_PROMPT_FIRST_USE_DATE_KEY];
    }

    NSInteger useCount = [defaults integerForKey:REVIEW_PROMPT_USE_COUNT_KEY] + 1;
    [defaults setInteger:useCount forKey:REVIEW_PROMPT_USE_COUNT_KEY];
    [defaults synchronize];

    NSTimeInterval daysSinceFirstUse = [[NSDate date] timeIntervalSinceDate:firstUseDate] / (60 * 60 * 24);
    if (daysSinceFirstUse >= REVIEW_PROMPT_MIN_DAYS && useCount >= REVIEW_PROMPT_MIN_USES) {
        UIWindowScene *scene = self.window.windowScene;
        if (scene) {
            [SKStoreReviewController requestReviewInScene:scene];
        }
    }
}

@end
