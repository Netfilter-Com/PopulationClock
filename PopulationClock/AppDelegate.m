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
    
    // Pre-load the IAP products and become a transaction observer
    [InAppPurchaseManager sharedInstance];
    
    // Reset the simulation
    [[SimulationEngine sharedInstance] reset];

    // Count this launch towards the review prompt
    [self recordLaunchForReviewPrompt];

    return YES;
}

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}

- (void)recordLaunchForReviewPrompt {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSDate *firstUseDate = [defaults objectForKey:REVIEW_PROMPT_FIRST_USE_DATE_KEY];
    if (!firstUseDate) {
        firstUseDate = [NSDate date];
        [defaults setObject:firstUseDate forKey:REVIEW_PROMPT_FIRST_USE_DATE_KEY];
    }

    NSInteger useCount = [defaults integerForKey:REVIEW_PROMPT_USE_COUNT_KEY] + 1;
    [defaults setInteger:useCount forKey:REVIEW_PROMPT_USE_COUNT_KEY];
    [defaults synchronize];
}

- (void)requestReviewIfAppropriateInScene:(UIWindowScene *)scene {
    // Only ask once per launch
    if (self.reviewRequestedThisLaunch) {
        return;
    }
    self.reviewRequestedThisLaunch = YES;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDate *firstUseDate = [defaults objectForKey:REVIEW_PROMPT_FIRST_USE_DATE_KEY];
    NSInteger useCount = [defaults integerForKey:REVIEW_PROMPT_USE_COUNT_KEY];

    NSTimeInterval daysSinceFirstUse = [[NSDate date] timeIntervalSinceDate:firstUseDate] / (60 * 60 * 24);
    if (firstUseDate && daysSinceFirstUse >= REVIEW_PROMPT_MIN_DAYS && useCount >= REVIEW_PROMPT_MIN_USES) {
        [SKStoreReviewController requestReviewInScene:scene];
    }
}

@end
